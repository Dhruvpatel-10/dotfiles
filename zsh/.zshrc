#!/usr/bin/env zsh
# ====================================================
# Optimized ~/.zshrc
# ====================================================

# 1. Exit early if not running interactively.
[[ $- != *i* ]] && return

# 2. SSH Agent Setup
export SSH_AUTH_SOCK=$(ls /run/user/$UID/keyring/ssh 2>/dev/null || echo "$HOME/.ssh-agent.sock")
if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
fi

# 3. Starship Prompt Initialization
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# 4. Asynchronous Conda & Mamba Initialization Without Job Notifications
# ------------------------------------------------------------------
# Disable job notifications
# Initialize conda directly
if [ -f "/home/stark/miniforge3/etc/profile.d/conda.sh" ]; then
    . "/home/stark/miniforge3/etc/profile.d/conda.sh"
else
    export PATH="/home/stark/miniforge3/bin:$PATH"
fi

# Initialize micromamba directly
if [ -f "/home/stark/.local/bin/micromamba" ]; then
    export MAMBA_EXE='/home/stark/.local/bin/micromamba'
    export MAMBA_ROOT_PREFIX='/home/stark/micromamba'
    eval "$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
fi

# Only disable background job notifications, keep important system notifications
setopt NO_NOTIFY

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

# Load plugins with silent and asynchronous options.
zinit ice silent wait'0'
zinit light zsh-users/zsh-autosuggestions

zinit ice silent wait'0'
zinit light zsh-users/zsh-syntax-highlighting

zinit ice silent wait'0'
zinit light zsh-users/zsh-completions

zinit ice silent wait'0'
zinit light Aloxaf/fzf-tab

# Load helper snippets (e.g. completions for git, npm, etc.)
zinit ice silent wait'0'
zinit snippet OMZP::git

zinit ice silent wait'0'
zinit snippet OMZP::npm

zinit ice silent wait'0'
zinit snippet OMZP::python

zinit ice silent wait'0'
zinit snippet OMZP::docker

zinit ice silent wait'0'
zinit snippet OMZP::conda

zinit ice silent wait'0'
zinit snippet OMZP::sudo

zinit ice silent wait'0'
zinit snippet OMZP::command-not-found

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

# 9. Shell Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ====================================================
# End of ~/.zshrc
# ====================================================
