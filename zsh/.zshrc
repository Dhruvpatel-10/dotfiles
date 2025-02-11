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

# 4. Environment-Specific Initialization Functions
# --------------------------------------------------

# Conda initialization on demand.
function load_conda() {
    if [[ -z "$CONDA_INITIALIZED" ]]; then
        export CONDA_INITIALIZED=1
        __conda_setup="$('/home/stark/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/home/stark/miniforge3/etc/profile.d/conda.sh" ]; then
                . "/home/stark/miniforge3/etc/profile.d/conda.sh"
            else
                export PATH="/home/stark/miniforge3/bin:$PATH"
            fi
        fi
        unset __conda_setup
    fi
}

# Mamba initialization on demand.
function load_mamba() {
    if [[ -z "$MAMBA_INITIALIZED" ]]; then
        export MAMBA_INITIALIZED=1
        export MAMBA_EXE='/home/stark/.local/bin/micromamba'
        export MAMBA_ROOT_PREFIX='/home/stark/micromamba'
        __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__mamba_setup"
        else
            alias micromamba="$MAMBA_EXE"
        fi
        unset __mamba_setup
    fi
}

# Wrapper functions for automatic initialization.
function conda() {
    load_conda
    command conda "$@"
}

function micromamba() {
    load_mamba
    command micromamba "$@"
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
