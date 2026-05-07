#!/usr/bin/env bash
set -euo pipefail

geometry="$(
  swaymsg -t get_tree \
    | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
)"

[ -n "$geometry" ] || exit 1

grim -g "$geometry" - | wl-copy
