#!/usr/bin/env bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".pre-dotfiles-sway-$(date +%Y%m%d%H%M%S)"

link () {
  mkdir -p "$(dirname "$2")"
  if [[ -e "$2" && ! -L "$2" ]]; then
    mv "$2" "$2$BACKUP_SUFFIX"
  fi

  if [[ -L "$2" ]]; then
    rm -f "$2"
  fi

  ln -s "$1" "$2"
}

# ~/.config
link "$DOTFILES_ROOT/config/kitty"   "$HOME/.config/kitty"
link "$DOTFILES_ROOT/config/nvim"    "$HOME/.config/nvim"
link "$DOTFILES_ROOT/config/sway"    "$HOME/.config/sway"
link "$DOTFILES_ROOT/config/theme"   "$HOME/.config/theme"
link "$DOTFILES_ROOT/config/waybar"  "$HOME/.config/waybar"
link "$DOTFILES_ROOT/config/wofi"    "$HOME/.config/wofi"

# ~
# ~/.local
link "$DOTFILES_ROOT/local/bin" "$HOME/.local/bin"

# Rebuild generated theme files (kitty fonts, bar themes, wallpaper, etc.)
if [[ -x "$HOME/.config/theme/apply-theme.sh" ]]; then
  "$HOME/.config/theme/apply-theme.sh"
fi

# If restore is run from a live Sway session, reload so the current session picks up the linked config.
if [[ -n "${SWAYSOCK:-}" ]] && command -v swaymsg >/dev/null 2>&1; then
  swaymsg reload >/dev/null 2>&1 || true
fi
