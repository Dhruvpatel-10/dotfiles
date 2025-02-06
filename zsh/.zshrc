# ~/.zshrc

# Prompt with Starship
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# This ensures your SSH key is available whenever you start a new shell session.
export SSH_AUTH_SOCK=$(ls /run/user/$UID/keyring/ssh 2>/dev/null || echo "$HOME/.ssh-agent.sock")

if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
fi

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Load Zinit
if [[ ! -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
    mkdir -p "$HOME/.zinit/bin"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
fi
source "$HOME/.zinit/bin/zinit.zsh"

# Set plugin installation directory
ZINIT_HOME="$HOME/.zinit/plugins"

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab


# Git, npm, Python, Docker completions
zinit snippet OMZP::git
zinit snippet OMZP::npm
zinit snippet OMZP::python
zinit snippet OMZP::docker
zinit snippet OMZP::conda
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Then keep these in order:
autoload -Uz compinit && compinit

zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


#Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Aliases
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"


