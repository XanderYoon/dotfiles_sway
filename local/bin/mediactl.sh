#!/usr/bin/env bash
set -euo pipefail

command -v playerctl >/dev/null 2>&1 || exit 0

if [[ $# -eq 0 ]]; then
  exit 0
fi

preferred_player=""

while IFS= read -r player; do
  if [[ "$player" == "spotify" ]]; then
    preferred_player="$player"
    break
  fi

  if [[ -z "$preferred_player" && "$player" == *spotify* ]]; then
    preferred_player="$player"
  fi
done < <(playerctl --list-all 2>/dev/null || true)

if [[ -n "$preferred_player" ]]; then
  playerctl --no-messages --player="$preferred_player" "$@" >/dev/null 2>&1 || exit 0
  exit 0
fi

playerctl --no-messages "$@" >/dev/null 2>&1 || exit 0
