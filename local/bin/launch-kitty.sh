#!/usr/bin/env bash
set -euo pipefail

export XCURSOR_SIZE="${XCURSOR_SIZE:-12}"

exec kitty "$@"
