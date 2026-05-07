#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  private-browser.sh
  private-browser.sh <url>
  private-browser.sh --disposable [url]
  private-browser.sh --reset

This launches a Chromium-family browser session under Firejail.

Default behavior uses a persistent browser profile so extensions and settings
survive across launches.

Notes:
  - This prefers google-chrome-stable on Ubuntu because the Snap Chromium
    build is not supported by Firejail for this style of filesystem isolation.
  - Use --disposable for a one-off temporary profile that is deleted on exit.
  - Use --reset to delete the persistent profile.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

find_browser() {
  if command -v google-chrome-stable >/dev/null 2>&1; then
    echo google-chrome-stable
    return
  fi

  if command -v google-chrome >/dev/null 2>&1; then
    echo google-chrome
    return
  fi

  echo "no supported Chromium-family browser found." >&2
  echo "Install google-chrome-stable or adjust this script for another non-Snap browser." >&2
  exit 1
}

main() {
  local browser
  local sandbox_home="${HOME}/.local/share/private-browser-profile"
  local mode="persistent"
  local url=""

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
    usage
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --disposable)
        mode="disposable"
        shift
        ;;
      --reset)
        rm -rf "$sandbox_home"
        echo "removed persistent browser profile: $sandbox_home"
        exit 0
        ;;
      *)
        if [[ -n "$url" ]]; then
          usage
          exit 1
        fi
        url="$1"
        shift
        ;;
    esac
  done

  require_cmd firejail
  require_cmd mktemp
  browser="$(find_browser)"

  if [[ "$mode" == "disposable" ]]; then
    sandbox_home="$(mktemp -d /tmp/private-browser-home.XXXXXX)"
    trap 'rm -rf "$sandbox_home"' EXIT
  else
    mkdir -p "$sandbox_home"
  fi

  exec firejail \
    --noprofile \
    --private="$sandbox_home" \
    --private-tmp \
    --nonewprivs \
    --hostname=private-browser \
    "$browser" \
    --user-data-dir="$sandbox_home/.config/google-chrome" \
    --disable-gpu \
    --disable-sync \
    --no-first-run \
    --password-store=basic \
    ${url:+"$url"}
}

main "$@"
