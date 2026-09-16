#!/bin/bash

# ----------------------------------------------------------------------------
# Generic tmux repo-session bootstrapper
#
# Lives once in dotfiles, never copied per-project. Point it at a WORKSPACE
# dir (e.g. ~/work/acme-corp) that holds:
#   - repos.conf            (required)
#   - extra-sessions.conf   (optional)
#   - the cloned repo folders themselves, as immediate children
#
# repos.conf format, one repo per line:
#   reponame
#   reponame:prefix        (prefix = fish alias prefix, e.g. "auth" for
#                            auth-logs / auth-menu; omit prefix to skip
#                            logs+menu windows for that repo)
#
# extra-sessions.conf format (optional, non-git scratch sessions):
#   name|path
#   name|path|startup command   (3rd field optional, sent as first command)
#
# Usage:
#   tmux-repos.sh -w ~/work/acme-corp
#   cd ~/work/acme-corp && tmux-repos.sh        (workspace defaults to $PWD)
# ----------------------------------------------------------------------------

set -e

ATTACH_SESSION=""
SHOW_MENU=true
WORKSPACE_DIR="$PWD"

usage() {
  echo "Usage: $0 [-w|--workspace DIR] [-a|--attach SESSION] [-n|--no-menu] [-h|--help]"
  echo "  -w, --workspace DIR    workspace dir holding repos.conf + cloned repos [default: \$PWD]"
  echo "  -a, --attach SESSION   attach directly to SESSION after setup"
  echo "  -n, --no-menu          skip interactive menu (just create sessions)"
  echo "  -h, --help             show this help"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--workspace)
      WORKSPACE_DIR="$2"
      shift 2
      ;;
    -a|--attach)
      ATTACH_SESSION="$2"
      shift 2
      ;;
    -n|--no-menu)
      SHOW_MENU=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo "⚠️  Workspace dir not found: $WORKSPACE_DIR"
  exit 1
fi
WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd)"

REPOS_CONF="$WORKSPACE_DIR/repos.conf"
EXTRA_CONF="$WORKSPACE_DIR/extra-sessions.conf"

if [[ ! -f "$REPOS_CONF" ]]; then
  echo "⚠️  Missing $REPOS_CONF — create it first (one repo per line, see header of this script)."
  exit 1
fi

# Parse repos.conf into parallel arrays: repo name + optional prefix
repo_names=()
repo_prefixes=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  name="${line%%:*}"
  if [[ "$line" == *:* ]]; then
    prefix="${line#*:}"
  else
    prefix=""
  fi
  repo_names+=("$name")
  repo_prefixes+=("$prefix")
done < "$REPOS_CONF"

# Parse extra-sessions.conf (optional): name|path|startup-cmd
extra_session_names=()
extra_session_paths=()
extra_session_cmds=()
if [[ -f "$EXTRA_CONF" ]]; then
  while IFS='|' read -r name path cmd; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    extra_session_names+=("$name")
    extra_session_paths+=("${path:-$HOME}")
    extra_session_cmds+=("$cmd")
  done < "$EXTRA_CONF"
fi

# Check if tmux is running
if ! command -v tmux > /dev/null 2>&1 || ! tmux info > /dev/null 2>&1; then
  echo "Starting tmux server..."
  tmux start-server
fi

# Detach from any existing tmux session if we're in one
if [[ -n "$TMUX" ]]; then
  tmux detach-client 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Create sessions for git repositories
# ---------------------------------------------------------------------------
created_repo_sessions=()
for i in "${!repo_names[@]}"; do
  repo="${repo_names[$i]}"
  prefix="${repo_prefixes[$i]}"
  repo_path="$WORKSPACE_DIR/$repo"

  if [ -d "$repo_path" ]; then
    echo "Creating tmux session for $repo..."

    if ! tmux has-session -t "$repo" 2>/dev/null; then
      tmux new-session -d -s "$repo" -c "$repo_path" -n "files"
      tmux send-keys -t "$repo:files" "nvim" C-m

      if [[ -n "$prefix" ]]; then
        tmux new-window -t "$repo:" -c "$repo_path" -n "logs"
        tmux send-keys -t "$repo:logs" "${prefix}-logs" C-m
        tmux new-window -t "$repo:" -c "$repo_path" -n "menu"
        tmux send-keys -t "$repo:menu" "${prefix}-menu" C-m
      fi

      # git window (lazygit) for all repos
      tmux new-window -t "$repo:" -c "$repo_path" -n "git"
      tmux send-keys -t "$repo:git" "lazygit" C-m

      # general scratch window for all repos
      tmux new-window -t "$repo:" -c "$repo_path" -n "general"

      tmux select-window -t "$repo:files"

      echo "✅ Session created for $repo"
    else
      echo "⏭️  Session for $repo already exists, skipping..."
    fi
    created_repo_sessions+=("$repo")
  else
    echo "⚠️  Repository $repo not found at $repo_path"
  fi
done

# ---------------------------------------------------------------------------
# Create non-git extra sessions
# ---------------------------------------------------------------------------
for i in "${!extra_session_names[@]}"; do
  name="${extra_session_names[$i]}"
  path="${extra_session_paths[$i]}"
  cmd="${extra_session_cmds[$i]}"

  if ! tmux has-session -t "$name" 2>/dev/null; then
    echo "Creating tmux session for $name (non-git)..."
    tmux new-session -d -s "$name" -c "$path" -n "general"
    if [[ -n "$cmd" ]]; then
      tmux send-keys -t "$name:general" "$cmd" C-m
    fi
    echo "✅ Session created: $name → $path"
  else
    echo "⏭️  Session $name already exists, skipping..."
  fi
done

# ---------------------------------------------------------------------------
# Interactive menu — repos section + other section
# ---------------------------------------------------------------------------
show_interactive_menu() {
  local repo_sessions=("$@")
  local other_sessions=()

  for name in "${extra_session_names[@]}"; do
    tmux has-session -t "$name" 2>/dev/null && other_sessions+=("$name")
  done

  local total=$(( ${#repo_sessions[@]} + ${#other_sessions[@]} ))

  if [[ "$total" -eq 0 ]]; then
    echo "No tmux sessions found!"
    exit 1
  fi

  local session_list=()
  local session_count=0

  echo ""
  echo "Select a session to attach to:"
  echo ""

  if [ ${#repo_sessions[@]} -gt 0 ]; then
    echo "  ── Repos ──"
    for name in "${repo_sessions[@]}"; do
      session_count=$((session_count + 1))
      printf "  %2d. %s\n" "$session_count" "$name"
      session_list+=("$name")
    done
    echo ""
  fi

  if [ ${#other_sessions[@]} -gt 0 ]; then
    echo "  ── Other ──"
    for name in "${other_sessions[@]}"; do
      session_count=$((session_count + 1))
      printf "  %2d. %s\n" "$session_count" "$name"
      session_list+=("$name")
    done
    echo ""
  fi

  echo "   q. Exit without attaching"
  echo ""

  read -p "Enter selection [1-$session_count]: " selection

  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$session_count" ]; then
    local selected="${session_list[$((selection-1))]}"
    echo "Attaching to session: $selected"

    if [[ -n "$TMUX" ]]; then
      echo "Already in tmux, switching to $selected..."
      tmux switch-client -t "$selected"
    else
      tmux attach-session -t "$selected"
    fi

    echo ""
    echo "📌 Remember: When inside tmux, you can switch sessions with PREFIX + s"
    echo "   (PREFIX is typically Ctrl+b)"
  elif [[ "$selection" == "q" ]]; then
    echo "Exiting without attaching to any session."
  else
    echo "Invalid selection. Exiting."
  fi
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "🎉 All sessions created! Use the following commands to interact with them:"
echo "  - tmux list-sessions                # List all sessions"
echo "  - tmux attach-session -t NAME       # Attach to a specific session"
echo "  - tmux switch-client -t NAME        # Switch to a specific session while already in tmux"
echo ""
echo "Once inside tmux, you can switch between sessions with:"
echo "  - PREFIX + s                        # Show session list and select (PREFIX is typically Ctrl+b)"
echo "  - PREFIX + (                        # Previous session"
echo "  - PREFIX + )                        # Next session"
echo "  - PREFIX + L                        # Last (previously used) session"
echo "  - PREFIX + d                        # Detach from current session"
echo ""
echo "Current sessions:"
tmux list-sessions

# ---------------------------------------------------------------------------
# Attach / menu
# ---------------------------------------------------------------------------
if [[ -n "$ATTACH_SESSION" ]]; then
  if tmux has-session -t "$ATTACH_SESSION" 2>/dev/null; then
    echo ""
    echo "Attaching to session: $ATTACH_SESSION"
    if [[ -n "$TMUX" ]]; then
      echo "Already in tmux, switching to $ATTACH_SESSION..."
      tmux switch-client -t "$ATTACH_SESSION"
    else
      tmux attach-session -t "$ATTACH_SESSION"
    fi
  else
    echo ""
    echo "⚠️  Session $ATTACH_SESSION not found!"
  fi
elif [[ "$SHOW_MENU" == true ]]; then
  show_interactive_menu "${created_repo_sessions[@]}"
fi
