#!/usr/bin/env bash

THEME_FILE="$HOME/.config/theme/current"

if [[ ! -f "$THEME_FILE" ]]; then
  printf "%-5s\n" "DARK"
  exit 0
fi

THEME=$(cat "$THEME_FILE")

if [[ "$THEME" == "light" ]]; then
  printf "%-5s\n" "LIGHT"
else
  printf "%-5s\n" "DARK"
fi
