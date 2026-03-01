My setup:
- linux ubuntu
- x11
- rx 7600 xt
- kitty
- i3wm
- yazi
- rofi
- polybar
- picom

I have setup a ~/.dotfiles repos that stores all my files. my ~/.config are just pointers to my dotfiles.

I have setup a light and dark mode in my setup. In ~/.dotfiles/config i have a theme folder with 
apply-theme.sh:
#!/usr/bin/env bash
set -e

THEME=$(cat ~/.config/i3/theme)

if [ "$THEME" = "light" ]; then
  kitty +kitten themes --reload-in=all Catppuccin-Latte

  ln -sf ~/.config/picom/opacity-light.conf ~/.config/picom/active-opacity.conf

  ln -sf ~/.config/nvim/themes/catppuccin-latte.lua \
    ~/.config/nvim/themes/current.lua

  ln -sf ~/.config/yazi/themes/catppuccin-latte.toml \
    ~/.config/yazi/theme.toml
else
  kitty +kitten themes --reload-in=all Catppuccin-Mocha

  ln -sf ~/.config/picom/opacity-dark.conf ~/.config/picom/active-opacity.conf

  ln -sf ~/.config/nvim/themes/catppuccin-mocha.lua \
    ~/.config/nvim/themes/current.lua

  ln -sf ~/.config/yazi/themes/catppuccin-mocha.toml \
    ~/.config/yazi/theme.toml
fi

pkill -USR1 nvim || true

in my ~/.dotfiles/config/i3/theme is just a global truth file that keeps trakc of which mode (light or dark mode)

in my ~/.dotfiles/config/picom i have active-opacity.conf file that just points to either my opacity-dark.conf file or opacity-light.conf file

opacity-dark.conf file:
opacity-rule = [ "90:class_g = 'kitty'" ];
opacity-light.conf file:
opacity-rule = [ "80:class_g = 'kitty'" ];

picom.conf:
backend = "xrender";
vsync = false;

@include "active-opacity.conf"

# Avoid flickering
use-damage = true;

right now my kitty terminals are stuck a 90 opacity no matter mode (everything else still works, the wallpapers and themes still change and work normally)
