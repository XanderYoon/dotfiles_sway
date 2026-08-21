if test -d /opt/homebrew/bin
    fish_add_path --global --move --prepend /opt/homebrew/bin
else if test -d /usr/local/bin
    fish_add_path --global --move --prepend /usr/local/bin
end

fish_add_path --global --move --prepend $HOME/.local/bin

# Keep autosuggestions visibly separate from typed input.
set --global fish_color_autosuggestion 6c7086

if status is-interactive
    if command -q micromamba
        micromamba shell hook --shell fish | source
    end

    if command -q starship
        starship init fish | source
    end
end
