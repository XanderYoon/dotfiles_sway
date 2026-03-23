#!/usr/bin/env bash
set -euo pipefail

export XCURSOR_SIZE="${XCURSOR_SIZE:-12}"

shell_bin="$(command -v fish || command -v bash)"

exec /home/alexander-yoon/.local/kitty.app/bin/kitty -o "shell=${shell_bin}" "$@"
