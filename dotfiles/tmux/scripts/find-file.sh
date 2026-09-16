#!/bin/bash

# ----------------------------------------------------------------------------
# Fuzzy-find a file across all tmux sessions that have a "files" window, and
# open it there via nvim's :e. Self-contained — reads live tmux state only,
# no project-specific repo list needed. Bound to PREFIX + F in tmux.conf.
#
# Convention this relies on: a session's "files" window is nvim, started
# with -c <project_dir> (this is what tmux-repos.sh in dev-setup does).
# ----------------------------------------------------------------------------

set -e

list_files() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
    tmux list-windows -t "$session" -F '#{window_name}' 2>/dev/null | grep -qx "files" || continue
    path="$(tmux display-message -p -t "$session:files" '#{pane_current_path}')"
    [ -d "$path" ] || continue
    (cd "$path" && fd --type f --strip-cwd-prefix) | while IFS= read -r rel; do
      printf '%s/%s\n' "$session" "$rel"
    done
  done
}

selection="$(
  list_files | fzf-tmux -p 85%,85% \
    --ansi --border-label " find file " --prompt "📄  " \
    --preview "path=\$(tmux display-message -p -t \"\$(echo {} | cut -d/ -f1):files\" '#{pane_current_path}')/\$(echo {} | cut -d/ -f2-); bat --style=numbers --color=always \"\$path\" 2>/dev/null || cat \"\$path\"" \
    --preview-window "right:60%"
)" || true

[ -n "$selection" ] || exit 0

session="${selection%%/*}"
relpath="${selection#*/}"
path="$(tmux display-message -p -t "$session:files" '#{pane_current_path}')"
full_path="$path/$relpath"
target="$session:files"

tmux send-keys -t "$target" Escape
tmux send-keys -t "$target" ":e $full_path" Enter

if [[ -n "$TMUX" ]]; then
  tmux switch-client -t "$target"
else
  tmux attach-session -t "$target"
fi
