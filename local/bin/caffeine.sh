#!/usr/bin/env bash

set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_DIR="$RUNTIME_DIR/polybar-caffeine"
PID_FILE="$STATE_DIR/inhibitor.pid"

mkdir -p "$STATE_DIR"

is_running() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [[ -n "${pid:-}" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

start_inhibitor() {
  if is_running; then
    return 0
  fi

  systemd-inhibit \
    --what=idle:sleep \
    --who="polybar-caffeine" \
    --why="User enabled caffeine mode from polybar" \
    bash -c 'while :; do sleep 3600; done' >/dev/null 2>&1 &

  echo "$!" >"$PID_FILE"
}

stop_inhibitor() {
  if ! is_running; then
    rm -f "$PID_FILE"
    return 0
  fi

  local pid
  pid="$(cat "$PID_FILE")"
  kill "$pid" 2>/dev/null || true
  rm -f "$PID_FILE"
}

print_status() {
  if is_running; then
    printf " ON"
  else
    printf " OFF"
  fi
}

case "${1:-toggle}" in
  toggle)
    if is_running; then
      stop_inhibitor
    else
      start_inhibitor
    fi
    ;;
  on|enable|start)
    start_inhibitor
    ;;
  off|disable|stop)
    stop_inhibitor
    ;;
  status)
    print_status
    ;;
  *)
    echo "Usage: $0 {toggle|on|off|status}" >&2
    exit 2
    ;;
esac
