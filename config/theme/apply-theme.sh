#!/usr/bin/env bash
set -e

THEME_FILE="$HOME/.config/theme/current"
THEME="dark"

if [[ -f "$THEME_FILE" ]]; then
  THEME=$(cat "$THEME_FILE")
else
  echo "$THEME" >"$THEME_FILE"
fi

THEME_DIR="$HOME/.config/theme/$THEME"
THEME_CONFIG="$THEME_DIR/theme.sh"
FONT_CONFIG="$HOME/.config/theme/font.sh"

if [[ ! -f "$THEME_CONFIG" ]]; then
  echo "Missing theme config: $THEME_CONFIG" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$THEME_CONFIG"

if [[ -f "$FONT_CONFIG" ]]; then
  # shellcheck source=/dev/null
  source "$FONT_CONFIG"
fi

ROFI_DIR="$HOME/.config/rofi"
WAYBAR_DIR="$HOME/.config/waybar"
WOFI_DIR="$HOME/.config/wofi"

mkdir -p "$ROFI_DIR" "$WAYBAR_DIR" "$WOFI_DIR"

if [[ -n "${FONT_MONO:-}" && -n "${FONT_MONO_SIZE:-}" ]]; then
  mkdir -p "$HOME/.config/kitty"
  cat >"$HOME/.config/kitty/fonts.conf" <<EOF
font_family ${FONT_MONO}
font_size ${FONT_MONO_SIZE}
EOF
fi

if command -v kitty >/dev/null 2>&1; then
  kitty +kitten themes --reload-in=all "$KITTY_THEME" || true
fi

if [[ -f "$PICOM_OPACITY" ]]; then
  cat "$PICOM_OPACITY" >"$HOME/.config/picom/active-opacity.conf"
fi

ln -sf "$NVIM_THEME" "$HOME/.config/nvim/themes/current.lua"
ln -sf "$YAZI_THEME" "$HOME/.config/yazi/theme.toml"

if [[ -f "$ROFI_THEME" ]]; then
  printf '@import "%s"\n' "$ROFI_THEME" >"$ROFI_DIR/current-theme.rasi"
fi

if [[ -n "${WAYBAR_THEME:-}" && -f "$WAYBAR_THEME" ]]; then
  cp -f "$WAYBAR_THEME" "$WAYBAR_DIR/theme.css"
fi

if [[ -n "${WOFI_THEME:-}" && -f "$WOFI_THEME" ]]; then
  cp -f "$WOFI_THEME" "$WOFI_DIR/theme.css"
fi

POLYBAR_THEME_SRC="$HOME/.dotfiles/config/theme/$THEME/polybar.ini"
if [[ -f "$POLYBAR_THEME_SRC" ]]; then
  cp -f "$POLYBAR_THEME_SRC" "$HOME/.config/polybar/theme.ini"
fi

wallpaper_applied=0

if [[ -n "${SWAYSOCK:-}" ]] && command -v swaymsg >/dev/null 2>&1; then
  if swaymsg output '*' bg "$WALLPAPER" fill >/dev/null 2>&1; then
    wallpaper_applied=1
  fi
fi

if [[ $wallpaper_applied -eq 0 ]] && command -v feh >/dev/null 2>&1; then
  feh --no-xinerama --bg-fill "$WALLPAPER"
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

if [[ -n "${DISPLAY:-}" ]] && command -v picom >/dev/null 2>&1; then
  pkill picom >/dev/null 2>&1 || true
  picom --backend xrender --config "$HOME/.config/picom/picom.conf" -b >/dev/null 2>&1 || true
fi

pkill -USR1 nvim || true

if command -v polybar-msg >/dev/null 2>&1; then
  polybar-msg cmd restart >/dev/null 2>&1 || true
fi

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
fi
