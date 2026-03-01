#!/usr/bin/env bash
set -euo pipefail

find_busy_file() {
  local vendor_file busy_file vendor_id

  for vendor_file in /sys/class/drm/card*/device/vendor; do
    [[ -r "$vendor_file" ]] || continue
    read -r vendor_id < "$vendor_file"
    if [[ "$vendor_id" == "0x1002" ]]; then
      busy_file="${vendor_file%/vendor}/gpu_busy_percent"
      [[ -r "$busy_file" ]] && printf '%s\n' "$busy_file" && return 0
    fi
  done

  for busy_file in /sys/class/drm/card*/device/gpu_busy_percent; do
    [[ -r "$busy_file" ]] && printf '%s\n' "$busy_file" && return 0
  done

  return 1
}

if busy_file=$(find_busy_file); then
  read -r usage < "$busy_file"
  if [[ "$usage" =~ ^[0-9]+$ ]]; then
    printf '󰢮 %3d%%\n' "$usage"
    exit 0
  fi
fi

printf '󰢮  --\n'
