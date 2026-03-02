#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$SCRIPT_DIR/dark"
THEME_CONFIG="$THEME_DIR/theme.sh"

if [[ ! -f "$THEME_CONFIG" ]]; then
  echo "Missing theme config: $THEME_CONFIG" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$THEME_CONFIG"

WAYBAR_DIR="$HOME/.config/waybar"
WOFI_DIR="$HOME/.config/wofi"
NVIM_THEME_DIR="$HOME/.config/nvim/themes"

mkdir -p "$WAYBAR_DIR" "$WOFI_DIR" "$NVIM_THEME_DIR"

if command -v kitty >/dev/null 2>&1; then
  kitty +kitten themes --reload-in=all "$KITTY_THEME" || true
fi

ln -sf "$NVIM_THEME" "$NVIM_THEME_DIR/current.lua"

if [[ -n "${WAYBAR_THEME:-}" && -f "$WAYBAR_THEME" ]]; then
  cp -f "$WAYBAR_THEME" "$WAYBAR_DIR/theme.css"
fi

if [[ -n "${WOFI_THEME:-}" && -f "$WOFI_THEME" ]]; then
  cp -f "$WOFI_THEME" "$WOFI_DIR/theme.css"
fi

wallpaper_applied=0

if [[ -n "${SWAYSOCK:-}" ]] && command -v swaymsg >/dev/null 2>&1; then
  if [[ -n "${SWAY_CLIENT_FOCUSED:-}" ]]; then
    swaymsg "client.focused $SWAY_CLIENT_FOCUSED" >/dev/null 2>&1 || true
  fi
  if [[ -n "${SWAY_CLIENT_FOCUSED_INACTIVE:-}" ]]; then
    swaymsg "client.focused_inactive $SWAY_CLIENT_FOCUSED_INACTIVE" >/dev/null 2>&1 || true
  fi
  if [[ -n "${SWAY_CLIENT_UNFOCUSED:-}" ]]; then
    swaymsg "client.unfocused $SWAY_CLIENT_UNFOCUSED" >/dev/null 2>&1 || true
  fi
  if [[ -n "${SWAY_CLIENT_URGENT:-}" ]]; then
    swaymsg "client.urgent $SWAY_CLIENT_URGENT" >/dev/null 2>&1 || true
  fi
  if [[ -n "${SWAY_CLIENT_PLACEHOLDER:-}" ]]; then
    swaymsg "client.placeholder $SWAY_CLIENT_PLACEHOLDER" >/dev/null 2>&1 || true
  fi
  if [[ -n "${SWAY_CLIENT_BACKGROUND:-}" ]]; then
    swaymsg "client.background $SWAY_CLIENT_BACKGROUND" >/dev/null 2>&1 || true
  fi

  wallpaper_ext="${WALLPAPER##*.}"
  wallpaper_base="${WALLPAPER%.*}"
  wallpaper_left="${WALLPAPER_LEFT:-${wallpaper_base}-left.${wallpaper_ext}}"
  wallpaper_right="${WALLPAPER_RIGHT:-${wallpaper_base}-right.${wallpaper_ext}}"

  if command -v jq >/dev/null 2>&1 && [[ -f "$wallpaper_left" && -f "$wallpaper_right" ]]; then
    output_names=()

    while IFS= read -r output_name; do
      output_names+=("$output_name")
    done < <(
      swaymsg -t get_outputs -r 2>/dev/null | jq -r '
        map(select(.active))
        | sort_by(.rect.x, .rect.y)
        | .[].name
      ' 2>/dev/null
    )

    if (( ${#output_names[@]} >= 2 )); then
      if swaymsg output "${output_names[0]}" bg "$wallpaper_left" fill >/dev/null 2>&1 \
        && swaymsg output "${output_names[1]}" bg "$wallpaper_right" fill >/dev/null 2>&1; then
        wallpaper_applied=1
      fi
    fi
  fi

  if (( wallpaper_applied == 0 )) && swaymsg output '*' bg "$WALLPAPER" fill >/dev/null 2>&1; then
    wallpaper_applied=1
  fi
fi

if command -v gsettings >/dev/null 2>&1; then
  if [[ -n "${GTK_THEME:-}" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
  fi
  if [[ -n "${ICON_THEME:-}" ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
  fi
  if [[ -n "${CURSOR_THEME:-}" ]]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true
  fi
  if [[ -n "${GTK_COLOR_SCHEME:-}" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme "$GTK_COLOR_SCHEME" || true
  fi
fi

pkill -USR1 nvim || true

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
fi
