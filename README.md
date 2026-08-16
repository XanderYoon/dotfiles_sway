# Dotfiles

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
