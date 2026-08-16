#!/usr/bin/env bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".pre-dotfiles-sway-$(date +%Y%m%d%H%M%S)"

shopt -s nullglob

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

case "$(uname -s)" in
  Linux) platform="linux" ;;
  Darwin) platform="macos" ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

# Link shared config directories into ~/.config.
for src in "$DOTFILES_ROOT"/config/*; do
  [[ -e "$src" ]] || continue
  case "$(basename "$src")" in
    lazygit|systemd|tmux) continue ;;
  esac
  link "$src" "$HOME/.config/$(basename "$src")"
done

# Lazygit and tmux use platform-specific keybinding variants.
link "$DOTFILES_ROOT/config/lazygit/$platform" "$HOME/.config/lazygit"
link "$DOTFILES_ROOT/config/tmux/$platform" "$HOME/.config/tmux"
link "$DOTFILES_ROOT/config/tmux/$platform/tmux.conf" "$HOME/.tmux.conf"

# Link top-level dotfiles from home/ into ~, but keep .local granular.
for src in "$DOTFILES_ROOT"/home/* "$DOTFILES_ROOT"/home/.[!.]* "$DOTFILES_ROOT"/home/..?*; do
  [[ -e "$src" ]] || continue
  [[ "$(basename "$src")" == ".local" ]] && continue
  link "$src" "$HOME/$(basename "$src")"
done

# Link files shipped under home/.local individually so we do not replace ~/.local wholesale.
if [[ -d "$DOTFILES_ROOT/home/.local" ]]; then
  while IFS= read -r -d '' src; do
    rel_path="${src#"$DOTFILES_ROOT/home/.local/"}"
    link "$src" "$HOME/.local/$rel_path"
  done < <(find "$DOTFILES_ROOT/home/.local" \( -type f -o -type l \) -print0)
fi

# Link each managed subtree from local/ into ~/.local.
for src in "$DOTFILES_ROOT"/local/*; do
  [[ -e "$src" ]] || continue
  link "$src" "$HOME/.local/$(basename "$src")"
done

# If restore is run from a live Sway session, reload so the current session picks up the linked config.
if [[ -n "${SWAYSOCK:-}" ]] && command -v swaymsg >/dev/null 2>&1; then
  swaymsg reload >/dev/null 2>&1 || true
fi
