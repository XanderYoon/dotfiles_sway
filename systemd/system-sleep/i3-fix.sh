#!/bin/sh

case "$1" in
post)
  su alexander-yoon -c "DISPLAY=:0 XAUTHORITY=/home/alexander-yoon/.Xauthority /home/alexander-yoon/.dotfiles/local/bin/fix-monitors.sh"
  ;;
esac
