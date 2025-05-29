#!/usr/bin/env zsh
# ====================================================
# Optimized ~/.zshrc
# ====================================================

# 1. Exit early if not running interactively.
[[ $- != *i* ]] && return

# 2. SSH Agent Setup
# SSH Agent Setup
if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
    export SSH_AUTH_SOCK="$HOME/.ssh-agent.sock"
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        eval "$(ssh-agent -a $SSH_AUTH_SOCK)" >/dev/null
        ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
    fi
fi

# 3. Starship Prompt Initialization
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

devon() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

# 5. History Settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# 6. Zinit Setup & Plugin Loading
# --------------------------------
if [[ ! -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
    mkdir -p "$HOME/.zinit/bin"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
fi
source "$HOME/.zinit/bin/zinit.zsh"
ZINIT_HOME="$HOME/.zinit/plugins"
# Core plugins early
zinit ice silent wait'0'
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Other plugins after prompt shows
zinit ice silent wait'1'
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Snippets deferred
zinit ice silent wait'2'
zinit snippet OMZP::git
zinit snippet OMZP::npm
zinit snippet OMZP::nvm
zinit snippet OMZP::python
zinit snippet OMZP::docker
zinit snippet OMZP::conda
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::tailscale

# 7. Completions Initialization with Caching
autoload -Uz compinit
if [ -f ~/.zcompdump ]; then
    compinit -C -d ~/.zcompdump
else
    compinit
fi
zinit cdreplay -q

# 8. Completion Styling, Keybindings & Aliases
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

alias c='clear'
alias myipv4='curl ipv4.icanhazip.com'
alias myipv6='curl ipv6.icanhazip.com'
# Battery saver
alias bson='echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'   # Battery Save ON
alias bsoff='echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'  # Battery Save OFF
alias bsstat='cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'               # Battery Save STATUS

# 9. Shell Integrations
[[ $- == *i* ]] && {
  eval "$(fzf --zsh)"
  eval "$(zoxide init --cmd cd zsh)"
}

# ====================================================
# End of ~/.zshrc
# ====================================================

# Created by `pipx` on 2025-02-15 14:47:57
export PATH="$PATH:/home/stark/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

