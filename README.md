# Dotfiles

My personal dotfiles managed with GNU Stow.

## Prerequisites

```bash
# Fedora
sudo dnf install stow

# Ubuntu/Debian
sudo apt install stow

# Arch
sudo pacman -S stow
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Backup existing configs:
```bash
mkdir ~/dotfiles_backup
mv ~/.zshrc ~/dotfiles_backup/
mv ~/.config/starship.toml ~/dotfiles_backup/
mv ~/.config/mpv ~/dotfiles_backup/
```

3. Create symlinks using stow:
```bash
cd ~
stow -v -d ~/.dotfiles -t ~ zsh
stow -v -d ~/.dotfiles -t ~ config
stow -v -d ~/.dotfiles -t ~ gitconfig
stow -v -d ~/.dotfiles -t ~ conda
stow -v -d ~/.dotfiles -t ~ config
```

## Directory Structure

```
~/.dotfiles/
├── zsh/
│   ├── .zshrc
│   └── .zsh_history
└── config/
    └── .config/
        ├── starship.toml
        └── mpv/
            ├── input.conf
            └── scripts/
```

## Managing Dotfiles

- Add new configs: Move file to appropriate directory in ~/.dotfiles and re-run stow
- Remove symlinks: `stow -D -d ~/.dotfiles -t ~ [package]`
- Restow all: `stow -R -d ~/.dotfiles -t ~ */`

## Notes

- SSH keys should be generated per device, not symlinked
- Use `stow -v` for verbose output to see what's being linked
- Check symlinks: `ls -la ~/.config/`

## Troubleshooting

If you get conflicts:
```bash
# Remove existing file
rm ~/.config/starship.toml

# Or adopt existing files into stow
stow -v -d ~/.dotfiles -t ~ --adopt [package]
```
