#!/usr/bin/env bash
# Bootstrap Kitty, Tmux, Neovim, and this repository's related configuration on Ubuntu.
set -euo pipefail

if [[ ! -r /etc/os-release ]]; then
  echo "This script must be run on Ubuntu." >&2
  exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "This script must be run on Ubuntu (detected: ${ID:-unknown})." >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_suffix=".pre-dotfiles-sway-$(date +%Y%m%d%H%M%S)"
font_version="v3.4.0"
font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

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

sudo apt-get update
sudo apt-get install -y build-essential ca-certificates curl default-jdk fontconfig git kitty neovim nodejs npm ripgrep tmux unzip wl-clipboard
npm install --prefix "$HOME/.local" tree-sitter-cli

if ! fc-list : family | grep -Fxq "JetBrainsMono Nerd Font"; then
  echo "Installing JetBrainsMono Nerd Font ${font_version}..."
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT
  curl -fL --retry 3 \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/JetBrainsMono.zip" \
    -o "$temp_dir/JetBrainsMono.zip"
  mkdir -p "$font_dir"
  unzip -qo "$temp_dir/JetBrainsMono.zip" -d "$font_dir"
  fc-cache -f "$font_dir"
fi

link "$repo_root/config/kitty" "$HOME/.config/kitty"
link "$repo_root/config/nvim" "$HOME/.config/nvim"
if [[ -f "$repo_root/config/tmux/tmux.conf" ]]; then
  link "$repo_root/config/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
echo "Setup complete. Restart Kitty to use JetBrainsMono Nerd Font."
