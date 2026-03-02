# Load fzf if installed.
command -v fzf >/dev/null 2>&1 || return

# Load shell integration if the distro package provides it.
for script in \
  /usr/share/fzf/completion.bash \
  /usr/share/bash-completion/completions/fzf \
  /usr/share/doc/fzf/examples/completion.bash
do
  if [[ -r "$script" ]]; then
    # shellcheck source=/dev/null
    source "$script"
    break
  fi
done

for script in \
  /usr/share/fzf/key-bindings.bash \
  /usr/share/doc/fzf/examples/key-bindings.bash
do
  if [[ -r "$script" ]]; then
    # shellcheck source=/dev/null
    source "$script"
    break
  fi
done

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git . "$PWD"'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git . "$PWD"'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git . "$PWD"'
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git . "$PWD"'
else
  export FZF_DEFAULT_COMMAND='find "$PWD" -type f -not -path "*/.git/*" 2>/dev/null'
  export FZF_ALT_C_COMMAND='find "$PWD" -type d -not -path "*/.git/*" 2>/dev/null'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || head -100 {}'"
