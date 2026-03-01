#!/usr/bin/env bash

set -euo pipefail

show_menu() {
  if command -v wofi >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    wofi --dmenu --prompt Power
  elif command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -p Power
  else
    cat
  fi
}

logout_session() {
  if command -v swaymsg >/dev/null 2>&1 && [[ -n "${SWAYSOCK:-}" ]]; then
    swaymsg exit
  elif command -v i3-msg >/dev/null 2>&1; then
    i3-msg exit
  elif command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl dispatch exit
  elif command -v loginctl >/dev/null 2>&1 && [[ -n "${XDG_SESSION_ID:-}" ]]; then
    loginctl terminate-session "${XDG_SESSION_ID}"
  else
    return 1
  fi
}

choice=$(printf "  Lock\n  Sleep\n  Logout\n  Shutdown" | show_menu)

case "$choice" in
"  Lock")
  if command -v swaylock >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    swaylock -f
  elif command -v i3lock >/dev/null 2>&1; then
    i3lock
  fi
  ;;
"  Sleep") systemctl suspend ;;
"  Logout") logout_session ;;
"  Shutdown") systemctl poweroff ;;
esac
