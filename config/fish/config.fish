fish_add_path --move --prepend $HOME/.local/bin

if status is-interactive
    eval "$(micromamba shell hook --shell fish)"
    starship init fish | source
end
