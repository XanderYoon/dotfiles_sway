#!/usr/bin/env bash
set -e

link () {
  mkdir -p "$(dirname "$2")"
  ln -sf "$1" "$2"
}

# ~/.config
link "$HOME/.dotfiles/config/i3"      "$HOME/.config/i3"
link "$HOME/.dotfiles/config/kitty"   "$HOME/.config/kitty"
link "$HOME/.dotfiles/config/nvim"    "$HOME/.config/nvim"
link "$HOME/.dotfiles/config/polybar" "$HOME/.config/polybar"
link "$HOME/.dotfiles/config/rofi"    "$HOME/.config/rofi"
link "$HOME/.dotfiles/config/sway"    "$HOME/.config/sway"
link "$HOME/.dotfiles/config/theme"   "$HOME/.config/theme"
link "$HOME/.dotfiles/config/waybar"  "$HOME/.config/waybar"
link "$HOME/.dotfiles/config/wofi"    "$HOME/.config/wofi"
link "$HOME/.dotfiles/config/yazi"    "$HOME/.config/yazi"

# ~
link "$HOME/.dotfiles/home/.Xresources" "$HOME/.Xresources"
link "$HOME/.dotfiles/home/.xprofile"   "$HOME/.xprofile"

# ~/.local
link "$HOME/.dotfiles/local/bin" "$HOME/.local/bin"
