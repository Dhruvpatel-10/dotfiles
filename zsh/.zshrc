#!/usr/bin/env zsh
# ====================================================
# Optimized ~/.zshrc - Performance & Usability Focus
# ====================================================

# 1. Exit early if not interactive
[[ $- != *i* ]] && return

# 2. Performance optimizations
# Disable unnecessary zsh features that slow things down
setopt NO_GLOBAL_RCS
setopt NO_AUTO_CD
setopt NO_BEEP

# 3. History settings (moved early for better performance)
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# 4. Essential keybindings (fix deletion issues)
# Enable emacs-style keybindings
bindkey -e
# Fix backspace and delete keys
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[f" forward-word
bindkey "^[b" backward-word
# History search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# 5. SSH Agent Setup (optimized)
if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
    SSH_AGENT_FILE="$HOME/.ssh-agent-info"
    if [[ -f "$SSH_AGENT_FILE" ]]; then
        source "$SSH_AGENT_FILE" > /dev/null
    fi
    if ! pgrep -u "$USER" ssh-agent > /dev/null 2>&1; then
        ssh-agent > "$SSH_AGENT_FILE"
        source "$SSH_AGENT_FILE" > /dev/null
        ssh-add ~/.ssh/id_ed25519 2>/dev/null
    fi
fi

# 6. Devon function (lazy loading for better startup time)
devon() {
    if [[ -z "$DEVON_LOADED" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        command -v pyenv >/dev/null && eval "$(pyenv init --path)"

        export NVM_DIR="$HOME/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

        export DEVON_LOADED=1
        echo "Development environment loaded."
    fi
}

# 7. Zinit setup (optimized loading)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# 8. Essential plugins only (reduced for performance)
# Syntax highlighting - load early
zinit ice wait"0a" lucid
zinit load zsh-users/zsh-syntax-highlighting

# Autosuggestions
zinit ice wait"0b" lucid atload"_zsh_autosuggest_start"
zinit load zsh-users/zsh-autosuggestions

# Completions
zinit ice wait"0c" lucid blockf
zinit load zsh-users/zsh-completions

# FZF tab completion
zinit ice wait"1" lucid
zinit load Aloxaf/fzf-tab

# Selected OMZ plugins (only the most useful ones)
zinit ice wait"2" lucid
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# 9. Completions setup (cached)
autoload -Uz compinit
# Check if .zcompdump is older than 24 hours
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# 10. Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'

# 11. Aliases (essential ones only)
alias c='clear'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias myipv4='curl -s ipv4.icanhazip.com'
alias myipv6='curl -s ipv6.icanhazip.com'

# Battery management aliases
alias bson='echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'
alias bsoff='echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'
alias bsstat='cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'

# tmux Shortcuts
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tk='tmux kill-session -t'
alias tkall='tmux ls | cut -d: -f1 | xargs -n1 tmux kill-session -t'
alias trc='tmux source-file ~/.tmux.conf && echo "Reloaded tmux config."'
alias td='tmux detach'
alias t='tmux attach || tmux new'
alias tfresh='tkall && tmux new -s fresh'
alias tmux-setup='echo -e "unbind C-b\nset-option -g prefix C-a\nbind C-a send-prefix" > ~/.tmux.conf && trc'

# Other aliases
alias apt="apt-fast"

# 12. Shell integrations (lazy loaded)

# FZF integration - FIXED to show latest history first
__fzf_history__() {
  local output
  # Changed: Removed --tac flag to show most recent first (fc -rl already shows reverse chronological)
  output=$(fc -rl 1 | fzf --height=50% --reverse --query="$LBUFFER")
  if [[ -n "$output" ]]; then
    BUFFER=${output#*[0-9]*[[:space:]]}
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N __fzf_history__
bindkey '^r' __fzf_history__

# Load FZF if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fnm
FNM_PATH="/home/stark/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# Zoxide integration
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# 13. Starship prompt (load last)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# 14. PATH management (centralized and efficient)
# ====================================================
# Function to add directories to PATH only if they exist and aren't already in PATH
add_to_path() {
    for dir in "$@"; do
        # Expand ~ to home directory
        dir="${dir/#\~/$HOME}"
        # Check if directory exists and is not already in PATH
        if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
            export PATH="$dir:$PATH"
        fi
    done
}

# Add paths in priority order (highest priority first)
add_to_path \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin" \
    "/usr/local/go/bin"

# To add new paths in the future, just add them to the list above like this:
# add_to_path "/opt/myapp/bin" "$HOME/custom/bin" "/another/path"
# ====================================================


# ====================================================
# End of optimized ~/.zshrc
# ====================================================
