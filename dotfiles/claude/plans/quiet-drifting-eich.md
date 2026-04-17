---
# Context

User wants rubocop auto-fix to run automatically after editing auth-api files, to keep code style clean without manual intervention.

# Plan: Add PostToolUse rubocop hook to ~/.claude/settings.json

## Target file
`/home/tymoyato/.claude/settings.json` (user-scoped, applies to all sessions)

No project-level `.claude/settings.json` exists in auth-api.

## What to add

Add a `PostToolUse` hook on `Write|Edit` matcher that:
1. Extracts the edited file path from stdin JSON
2. Guards: only runs if file is under `/home/tymoyato/work/auth-api`
3. Runs `docker-compose exec auth-api bundle exec rubocop -A` from `infrastructure/` dir

## Hook command

```bash
file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty'); \
[[ "$file" == /home/tymoyato/work/auth-api/* ]] && \
cd /home/tymoyato/work/infrastructure && \
docker-compose exec auth-api bundle exec rubocop -A 2>/dev/null || true
```

## Merge into settings.json

Preserve existing keys (`extraKnownMarketplaces`, `enabledPlugins`, `statusLine`), add:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty'); [[ \"$file\" == /home/tymoyato/work/auth-api/* ]] && cd /home/tymoyato/work/infrastructure && docker-compose exec auth-api bundle exec rubocop -A 2>/dev/null || true",
            "timeout": 60,
            "statusMessage": "Running rubocop -A..."
          }
        ]
      }
    ]
  }
}
```

## Verification

After adding hook:
1. Edit any `.rb` file in `auth-api/`
2. Watch for "Running rubocop -A..." status spinner
3. Confirm rubocop ran inside container (may need `docker-compose up auth-api` running)

Note: Hook only fires while auth-api container is running. If container down, `|| true` prevents blocking.
