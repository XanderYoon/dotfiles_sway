#!/usr/bin/env bash
set -e

THEME_FILE="$HOME/.config/theme/current"

if [[ ! -f "$THEME_FILE" ]]; then
  echo "dark" >"$THEME_FILE"
fi

CURRENT=$(cat "$THEME_FILE")

if [[ "$CURRENT" == "dark" ]]; then
  echo "light" >"$THEME_FILE"
else
  echo "dark" >"$THEME_FILE"
fi

~/.config/theme/apply-theme.sh
