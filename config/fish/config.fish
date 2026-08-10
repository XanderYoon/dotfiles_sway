fish_add_path --move --prepend $HOME/.local/bin

if status is-interactive
    if command -q micromamba
        micromamba shell hook --shell fish | source
    end

    if command -q starship
        starship init fish | source
    end
end
