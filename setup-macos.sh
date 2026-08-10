#!/usr/bin/env bash
# Bootstrap Kitty, Tmux, Neovim, and this repository's related configuration on macOS.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must be run on macOS." >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_suffix=".pre-dotfiles-sway-$(date +%Y%m%d%H%M%S)"

link() {
  local source=$1 target=$2
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]]; then
    rm -f "$target"
  elif [[ -e "$target" ]]; then
    mv "$target" "${target}${backup_suffix}"
    echo "Backed up ${target} to ${target}${backup_suffix}"
  fi
  ln -s "$source" "$target"
  echo "Linked ${target} -> ${source}"
}

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew was installed but could not be found in a supported location." >&2
  exit 1
fi

brew install kitty tmux neovim node openjdk ripgrep
brew install --cask font-jetbrains-mono-nerd-font
npm install --prefix "$HOME/.local" tree-sitter-cli

link "$repo_root/config/kitty" "$HOME/.config/kitty"
link "$repo_root/config/nvim" "$HOME/.config/nvim"
if [[ -f "$repo_root/config/tmux/tmux.conf" ]]; then
  link "$repo_root/config/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
echo "Setup complete. Restart Kitty to use JetBrainsMono Nerd Font."
