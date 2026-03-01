#!/usr/bin/env bash
set -e

# Load canonical font definitions
source ~/.dotfiles/config/theme/font.sh

OUT="$HOME/.config/kitty/fonts.conf"

mkdir -p "$(dirname "$OUT")"

cat > "$OUT" <<EOF
font_family ${FONT_MONO}
font_size ${FONT_MONO_SIZE}
EOF
