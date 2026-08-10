#!/usr/bin/env bash

set -euo pipefail

status() {
  local controller powered connected_count

  controller="$(bluetoothctl show 2>/dev/null || true)"
  powered="$(awk -F': ' '/^[[:space:]]*Powered:/{print $2; exit}' <<<"$controller")"

  if [[ "$powered" != "yes" ]]; then
    printf '%s\n' '{"text":"󰂲","tooltip":"Bluetooth is off","class":"off"}'
    return
  fi

  connected_count="$(bluetoothctl devices Connected 2>/dev/null | wc -l)"
  if (( connected_count > 0 )); then
    printf '%s\n' '{"text":"󰂱","tooltip":"Bluetooth connected","class":"connected"}'
  else
    printf '%s\n' '{"text":"","tooltip":"Bluetooth is on","class":"on"}'
  fi
}

toggle() {
  local powered
  powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/^[[:space:]]*Powered:/{print $2; exit}')"

  if [[ "$powered" == "yes" ]]; then
    bluetoothctl power off >/dev/null
  else
    bluetoothctl power on >/dev/null
  fi
}

show_menu() {
  if command -v wofi >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    wofi --dmenu --normal-window --location center --width 640 --height 560 \
      --cache-file /dev/null --prompt Bluetooth
  else
    cat
  fi
}

menu() {
  local controller powered choice selected_index line mac name
  local -a choices=() devices=() connected_devices=()
  local -A connected=()

  if command -v wofi >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]] && pgrep -x wofi >/dev/null 2>&1; then
    pkill -x wofi >/dev/null 2>&1 || true
    exit 0
  fi

  controller="$(bluetoothctl show 2>/dev/null || true)"
  powered="$(awk -F': ' '/^[[:space:]]*Powered:/{print $2; exit}' <<<"$controller")"

  if [[ "$powered" != "yes" ]]; then
    choice="$(printf '%s\n' '󰂲  Enable Bluetooth' | show_menu)"
    [[ "$choice" == '󰂲  Enable Bluetooth' ]] && bluetoothctl power on >/dev/null
    exit 0
  fi

  while read -r _ mac name; do
    [[ -n "${mac:-}" ]] && connected["$mac"]=1
  done < <(bluetoothctl devices Connected 2>/dev/null)

  while read -r _ mac name; do
    [[ -n "${mac:-}" ]] || continue
    devices+=("$mac")
    if [[ -n "${connected[$mac]:-}" ]]; then
      choices+=("[connected]  $name")
    else
      choices+=("[disconnected]  $name")
    fi
  done < <(bluetoothctl paired-devices 2>/dev/null)

  choices+=("󰂲  Turn Bluetooth off")
  choice="$(printf '%s\n' "${choices[@]}" | show_menu)"
  [[ -n "$choice" ]] || exit 0

  if [[ "$choice" == '󰂲  Turn Bluetooth off' ]]; then
    bluetoothctl power off >/dev/null
    exit 0
  fi

  selected_index=-1
  for i in "${!choices[@]}"; do
    if [[ "${choices[i]}" == "$choice" ]]; then
      selected_index=$i
      break
    fi
  done
  ((selected_index >= 0 && selected_index < ${#devices[@]})) || exit 0

  mac="${devices[selected_index]}"
  if [[ -n "${connected[$mac]:-}" ]]; then
    bluetoothctl disconnect "$mac" >/dev/null
  else
    bluetoothctl connect "$mac" >/dev/null
  fi
}

case "${1:-status}" in
  status) status ;;
  toggle) toggle ;;
  menu) menu ;;
  *)
    printf 'Usage: %s {status|toggle|menu}\n' "$0" >&2
    exit 2
    ;;
esac
