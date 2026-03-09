local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
local XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
local XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
local XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Fixup directories for programs that do not currently respect the XDG Base Directories standard
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh

export NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc
export NPM_CONFIG_PREFIX=${XDG_DATA_HOME}/npm
export NPM_CONFIG_CACHE=${XDG_CACHE_HOME}/npm
export NPM_CONFIG_INIT_MODULE=${XDG_CONFIG_HOME}/npm/config/npm-init.js
export NPM_CONFIG_LOGS_DIR=${XDG_STATE_HOME}/npm/logs

export DOCKER_CONFIG=${XDG_CONFIG_HOME}/docker

export LESSHISTFILE=$XDG_CACHE_HOME/lesshst

export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTUP_HOME=$XDG_DATA_HOME/rustup
export GNUPGHOME=$XDG_DATA_HOME/gnupg
export GOPATH=$XDG_DATA_HOME/go
export PULUMI_HOME=${XDG_DATA_HOME}/pulumi
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

export NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc
export NPM_CONFIG_PREFIX=${XDG_DATA_HOME}/npm
export NPM_CONFIG_CACHE=${XDG_CACHE_HOME}/npm
export NPM_CONFIG_INIT_MODULE=${XDG_CONFIG_HOME}/npm/config/npm-init.js
export NPM_CONFIG_LOGS_DIR=${XDG_STATE_HOME}/npm/logs

# Required due to https://github.com/NixOS/nix/issues/8580
export NIX_PATH=$XDG_STATE_HOME/nix/defexpr/channels:$XDG_STATE_HOME/nix/defexpr/channels_root

export VISUAL=nvim
export EDITOR=$VISUAL

typeset -U path
path+="$CARGO_HOME/bin"
path+="$HOME/.local/bin"
path+="$HOME/.local/share/npm/bin"
path+="$HOME/.local/share/go/bin"
path+="$HOME/.opencode/bin"

export GPG_TTY=$(tty)
