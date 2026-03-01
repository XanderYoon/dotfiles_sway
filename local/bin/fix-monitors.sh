#!/usr/bin/env bash
set -euo pipefail

sleep 1

primary_output="DisplayPort-0"
secondary_output="DisplayPort-1"
target_mode="2560x1440"
target_scale="2"

for _ in $(seq 1 8); do
    xrandr --auto || true

    if xrandr --query | grep -q "^${primary_output} connected" && xrandr --query | grep -q "^${secondary_output} connected"; then
        if xrandr \
            --output "$primary_output" --mode "$target_mode" --scale "$target_scale" --primary --pos 0x0 \
            --output "$secondary_output" --mode "$target_mode" --scale "$target_scale" --right-of "$primary_output"; then
            break
        fi
    fi

    if xrandr --query | grep -q "^${primary_output} connected"; then
        if xrandr --output "$primary_output" --mode "$target_mode" --scale "$target_scale" --primary; then
            break
        fi
    fi

    if xrandr --query | grep -q "^${secondary_output} connected"; then
        if xrandr --output "$secondary_output" --mode "$target_mode" --scale "$target_scale" --primary; then
            break
        fi
    fi

    sleep 1
done

# Apply theme (if available) and restart i3 + polybar cleanly
if command -v apply-theme.sh >/dev/null 2>&1; then
    apply-theme.sh
fi

if command -v i3-msg >/dev/null 2>&1; then
    i3-msg restart
fi
