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

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  mkdir -p "$(dirname "$tpm_dir")"
  if [[ ! -d "$tpm_dir/.git" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    git -C "$tpm_dir" pull --ff-only
  fi

  TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" "$tpm_dir/bin/install_plugins"
}

ensure_openjdk_wrappers() {
  local java_home="$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk"
  local java_target="/Library/Java/JavaVirtualMachines/openjdk.jdk"

  if [[ -d "$java_home" && ! -e "$java_target" ]]; then
    sudo mkdir -p /Library/Java/JavaVirtualMachines
    sudo ln -sfn "$java_home" "$java_target"
  fi
}

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are required before bootstrapping this setup." >&2
  echo "Run 'xcode-select --install', finish the installer, then run this script again." >&2
  exit 1
fi

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

brew install fish git kitty lazygit micromamba neovim node openjdk ripgrep starship tmux uv yazi
brew install --cask font-jetbrains-mono-nerd-font
npm install --prefix "$HOME/.local" tree-sitter-cli
ensure_openjdk_wrappers

link "$repo_root/config/kitty" "$HOME/.config/kitty"
link "$repo_root/config/nvim" "$HOME/.config/nvim"
link "$repo_root/config/fish" "$HOME/.config/fish"
link "$repo_root/config/starship.toml" "$HOME/.config/starship.toml"
link "$repo_root/config/lazygit/macos" "$HOME/.config/lazygit"
link "$repo_root/config/tmux/macos" "$HOME/.config/tmux"
link "$repo_root/config/tmux/macos/tmux.conf" "$HOME/.tmux.conf"
link "$repo_root/config/yazi" "$HOME/.config/yazi"
install_tpm
echo "Setup complete. Restart Kitty to use JetBrainsMono Nerd Font."
