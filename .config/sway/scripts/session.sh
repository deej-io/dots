#!/bin/sh
# SPDX-License-Identifier: MIT
# Based on sway-systemd's session lifecycle:
# https://github.com/alebastr/sway-systemd

SESSION_TARGET=sway-session.target
SHUTDOWN_TARGET=sway-session-shutdown.target

# Sway's launcher normally supplies these. Defaults keep systemd and D-Bus
# activation correct when a minimal launcher omits them.
XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"
XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-sway}"
XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE

# Import only session variables. In particular, never import the complete
# process environment into the long-lived user manager.
VARIABLES="XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE"
for variable in DESKTOP_SESSION DISPLAY I3SOCK SWAYSOCK WAYLAND_DISPLAY XCURSOR_THEME XCURSOR_SIZE; do
    eval "value=\${$variable-}"
    if [ -n "$value" ]; then
        VARIABLES="$VARIABLES $variable"
    fi
done

if ! command -v systemctl >/dev/null 2>&1; then
    printf '%s\n' 'sway-session: systemctl is required' >&2
    exit 1
fi

if [ -z "${SWAYSOCK:-}" ] || ! command -v swaymsg >/dev/null 2>&1; then
    printf '%s\n' 'sway-session: SWAYSOCK and swaymsg are required' >&2
    exit 1
fi

# A systemd user manager is shared by all login sessions for the user. Do not
# overwrite its display variables if another full Sway session is active.
if systemctl --user --quiet is-active "$SESSION_TARGET"; then
    printf '%s\n' 'sway-session: another Sway session is already active' >&2
    exit 1
fi

# shellcheck disable=SC2086 # VARIABLES intentionally expands to variable names.
if ! systemctl --user import-environment $VARIABLES; then
    printf '%s\n' 'sway-session: failed to update the systemd user environment' >&2
    exit 1
fi

# Some D-Bus services are not activated through systemd, so update the D-Bus
# activation environment separately when the helper is available.
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    # shellcheck disable=SC2086 # VARIABLES intentionally expands to variable names.
    dbus-update-activation-environment --systemd $VARIABLES ||
        printf '%s\n' 'sway-session: failed to update the D-Bus activation environment' >&2
fi

if ! systemctl --user start "$SESSION_TARGET"; then
    printf '%s\n' "sway-session: failed to start $SESSION_TARGET" >&2
    exit 1
fi
session_started=1

session_cleanup() {
    [ "${session_started:-0}" -eq 1 ] || return
    session_started=0

    systemctl --user start --job-mode=replace-irreversibly "$SHUTDOWN_TARGET" ||
        printf '%s\n' "sway-session: failed to start $SHUTDOWN_TARGET" >&2

    # shellcheck disable=SC2086 # VARIABLES intentionally expands to variable names.
    systemctl --user unset-environment $VARIABLES ||
        printf '%s\n' 'sway-session: failed to clean the systemd user environment' >&2
}

trap session_cleanup 0
trap 'exit 0' HUP INT TERM

# The subscription returns when Sway shuts down; the EXIT trap then tears down
# graphical-session.target and all services tied to it.
swaymsg -t subscribe '["shutdown"]' >/dev/null
