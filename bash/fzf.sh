# Load fzf if installed
command -v fzf >/dev/null || return

# Use fd if available, fallback to find
if command -v fdfind >/dev/null; then
  export FZF_DEFAULT_COMMAND='fdfind --type f $(lsblk -nrpo MOUNTPOINT | grep "^/") \
    --exclude proc --exclude sys --exclude dev --exclude run'
else
  export FZF_DEFAULT_COMMAND='find $(lsblk -nrpo MOUNTPOINT | grep "^/") -type f 2>/dev/null'
fi

# Apply to Ctrl-T
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Optional: better preview
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || head -100 {}'"
