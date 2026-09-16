#!/bin/bash

# ----------------------------------------------------------------------------
# Bootstrap a new company/project workspace: clone repos, build repos.conf,
# launch tmux-repos.sh. Run once per new workspace; safe to re-run to add
# more repos later (existing repos.conf entries are kept, not overwritten).
#
# Repo spec format (positional args or -f FILE, one per line):
#   <git-url>
#   <git-url>|<prefix>     (prefix = fish alias prefix for logs/menu windows)
#
# Usage:
#   workspace-init.sh -w ~/work/acme-corp git@github.com:acme/auth-api.git|auth \
#                                          git@github.com:acme/core-api.git|core \
#                                          git@github.com:acme/frontend.git
#
#   workspace-init.sh -w ~/work/acme-corp -f repos.txt
#
#   workspace-init.sh -w ~/work/acme-corp --no-run ...   # skip auto tmux launch
# ----------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR=""
SPECS_FILE=""
RUN_TMUX=true
positional=()

usage() {
  echo "Usage: $0 -w DIR [-f FILE] [--no-run] [git-url[|prefix] ...]"
  echo "  -w, --workspace DIR    workspace dir to create/use (required)"
  echo "  -f, --file FILE        file of repo specs, one per line (# comments ok)"
  echo "      --no-run           skip launching tmux-repos.sh at the end"
  echo "  -h, --help             show this help"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--workspace)
      WORKSPACE_DIR="$2"
      shift 2
      ;;
    -f|--file)
      SPECS_FILE="$2"
      shift 2
      ;;
    --no-run)
      RUN_TMUX=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$WORKSPACE_DIR" ]]; then
  echo "⚠️  -w/--workspace DIR is required"
  usage
  exit 1
fi

mkdir -p "$WORKSPACE_DIR"
WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd)"
REPOS_CONF="$WORKSPACE_DIR/repos.conf"
touch "$REPOS_CONF"

# Collect specs: file lines + positional args
specs=()
if [[ -n "$SPECS_FILE" ]]; then
  if [[ ! -f "$SPECS_FILE" ]]; then
    echo "⚠️  Specs file not found: $SPECS_FILE"
    exit 1
  fi
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    specs+=("$line")
  done < "$SPECS_FILE"
fi
specs+=("${positional[@]}")

if [[ ${#specs[@]} -eq 0 ]]; then
  echo "⚠️  No repo specs given (positional args or -f FILE)"
  usage
  exit 1
fi

# Existing repo names already in repos.conf, so re-runs don't duplicate/clobber
existing_names=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  existing_names+=("${line%%:*}")
done < "$REPOS_CONF"

already_listed() {
  local target="$1"
  for n in "${existing_names[@]}"; do
    [[ "$n" == "$target" ]] && return 0
  done
  return 1
}

for spec in "${specs[@]}"; do
  url="${spec%%|*}"
  if [[ "$spec" == *"|"* ]]; then
    prefix="${spec#*|}"
  else
    prefix=""
  fi

  name="$(basename "$url")"
  name="${name%.git}"
  repo_path="$WORKSPACE_DIR/$name"

  if [[ -d "$repo_path" ]]; then
    echo "⏭️  $name already cloned, skipping clone..."
  else
    echo "Cloning $url → $repo_path"
    git clone "$url" "$repo_path"
  fi

  if already_listed "$name"; then
    echo "⏭️  $name already in repos.conf, leaving as-is"
  else
    if [[ -n "$prefix" ]]; then
      echo "$name:$prefix" >> "$REPOS_CONF"
    else
      echo "$name" >> "$REPOS_CONF"
    fi
    existing_names+=("$name")
    echo "✅ Added $name to repos.conf"
  fi
done

echo ""
echo "Workspace ready: $WORKSPACE_DIR"
echo "repos.conf:"
cat "$REPOS_CONF"

if [[ "$RUN_TMUX" == true ]]; then
  echo ""
  echo "Launching tmux-repos.sh..."
  exec "$SCRIPT_DIR/tmux-repos.sh" -w "$WORKSPACE_DIR"
fi
