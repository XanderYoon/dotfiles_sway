[Unit]
Description=Re-detect displays after suspend
After=suspend.target

[Service]
Type=oneshot
ExecStart=%h/.config/i3/autorandr.sh

[Install]
WantedBy=suspend.target
