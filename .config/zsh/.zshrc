setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt hist_ignore_space                                        # Do not save command if it begins with whitespace
setopt autocd                                                   # if only directory path is entered, cd there.

disable -p '#'

# Load completions
zstyle ':completion:*' matcher-list 'm:{a-za-z}={a-za-z}'       # case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)ls_colors}"         # colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# speed up completions
zstyle ':completion:*' accept-exact '*(n)'
zstyle ':completion:*' use-cache on

autoload -Uz compinit bashcompinit && compinit && bashcompinit

HISTFILE=${ZDOTDIR}/.zhistory
HISTSIZE=1000
SAVEHIST=500
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word

function source_if_exists() {
	for file in $@; do
		if [[ -e "$file" ]]; then
			source "$file"
		fi
	done
}


source_if_exists /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source_if_exists /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

zmodload zsh/terminfo
#
## Keybindings
bindkey -e # clear all keybindings?

# Open command line in $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line


## Aliases
alias cp="cp -i"                                              
alias df='df -h'                                              
alias free='free -m'                                          
alias ls='ls --color=auto'

if [[ -e /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
	bindkey "$terminfo[kcuu1]" history-substring-search-up
	bindkey "$terminfo[kcud1]" history-substring-search-down
	bindkey '^[[A' history-substring-search-up			
	bindkey '^[[B' history-substring-search-down
fi

function load_persistent_ssh_agent {
	local SSH_ENV="$HOME/.ssh/env"

	function start_agent {
		/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
		chmod 600 "${SSH_ENV}"
		. "${SSH_ENV}" > /dev/null
	}

	# check to see if the stored ssh-agent PID is running, otherwise start the agent again
	if [ -f "${SSH_ENV}" ]; then
		. "${SSH_ENV}" > /dev/null
		ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || start_agent;
	else
		start_agent;
	fi
}

load_persistent_ssh_agent 

# Load extra non-standard completion scripts
export ZSH_COMPLETIONS_FILE="$ZDOTDIR/completions"
if [[ ! -e "$ZSH_COMPLETIONS_FILE" ]]; then
	touch "$ZSH_COMPLETIONS_FILE"
fi
. "$ZSH_COMPLETIONS_FILE"

if which starship > /dev/null 2>&1; then
	unset RPROMPT
	eval "$(starship init zsh)"
fi

if which direnv > /dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

alias dots='/usr/bin/git --git-dir=$HOME/.dots --work-tree=$HOME'
