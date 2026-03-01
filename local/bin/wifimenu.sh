#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

active_marker="*"

show_menu() {
  local prompt="$1"

  if command -v wofi >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    wofi --dmenu --prompt "$prompt"
  elif command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -i -p "$prompt"
  else
    cat
  fi
}

show_password_prompt() {
  local prompt="$1"

  if command -v wofi >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    wofi --dmenu --password --prompt "$prompt"
  elif command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -password -p "$prompt"
  else
    cat
  fi
}

parse_nmcli_fields() {
  local line="$1"
  local current=""
  local escaped=0
  parsed_fields=()

  for ((i = 0; i < ${#line}; i++)); do
    char="${line:i:1}"

    if ((escaped)); then
      current+="$char"
      escaped=0
      continue
    fi

    if [[ "$char" == '\' ]]; then
      escaped=1
      continue
    fi

    if [[ "$char" == ':' ]]; then
      parsed_fields+=("$current")
      current=""
      continue
    fi

    current+="$char"
  done

  parsed_fields+=("$current")
}

mapfile -t networks < <(
  nmcli --terse -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list
)

choices=()
ssids=()
securities=()

for network in "${networks[@]}"; do
  parse_nmcli_fields "$network"
  in_use="${parsed_fields[0]:-}"
  ssid="${parsed_fields[1]:-}"
  security="${parsed_fields[2]:-}"
  signal="${parsed_fields[3]:-}"
  [[ -n "$ssid" ]] || continue

  marker=" "
  if [[ "$in_use" == "$active_marker" ]]; then
    marker="$active_marker"
  fi

  if [[ -z "$security" ]]; then
    security="open"
  fi

  choices+=("[$marker] ${signal:-0}%  ${ssid}  (${security})")
  ssids+=("$ssid")
  securities+=("$security")
done

if ((${#choices[@]} == 0)); then
  printf 'No Wi-Fi networks found.\n' | show_menu "Wi-Fi" >/dev/null
  exit 0
fi

choice=$(printf '%s\n' "${choices[@]}" | show_menu "Wi-Fi")
[[ -n "$choice" ]] || exit 0

selected_index=-1
for i in "${!choices[@]}"; do
  if [[ "${choices[i]}" == "$choice" ]]; then
    selected_index=$i
    break
  fi
done

((selected_index >= 0)) || exit 1

ssid=${ssids[selected_index]}
security=${securities[selected_index]}

connect_cmd=(nmcli dev wifi connect "$ssid")

if [[ "$security" != "open" && "$security" != "--" ]]; then
  password=$(show_password_prompt "Password for $ssid")
  [[ -n "$password" ]] || exit 0
  connect_cmd+=(password "$password")
fi

"${connect_cmd[@]}"
