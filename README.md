# Dotfiles

## Private Browser

Use [private-browser.sh](/home/alexander-yoon/.dotfiles_sway/local/bin/private-browser.sh:1) to launch a disposable Firejail browser session with a fresh temporary profile.

## Revert one config
rm ~/.bashrc
cp ~/.dotfiles/home/.bashrc ~/.bashrc

## Nuke all symlinks (emergency)
find ~ -maxdepth 2 -type l -delete


## Symlink Helper Script
cat << 'EOF' > ~/.dotfiles/bin/link.sh
#!/usr/bin/env bash
set -e

ln -svf ~/.dotfiles/home/.bashrc ~/.bashrc
EOF

chmod +x ~/.dotfiles/bin/link.sh
