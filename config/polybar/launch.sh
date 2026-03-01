#!/usr/bin/env bash

source ~/.config/theme/font.sh

# kill existing bars
killall -q polybar

# Wait for X/monitors to stabilize
while pgrep -x polybar >/dev/null; do sleep 0.2; done

# Give xrandr time to report final outputs/primary
for _ in $(seq 1 25); do
  if xrandr --query | grep -q " connected" && xrandr --query | grep -q " primary"; then
    break
  fi
  sleep 0.2
done

for m in $(polybar -m | cut -d: -f1); do
  MONITOR=$m polybar main &
done
