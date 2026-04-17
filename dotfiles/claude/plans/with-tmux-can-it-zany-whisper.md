# Plan: Desktop Notification When Claude Finishes

## Context

User runs Claude Code in a tmux window, switches to another session, and wants a desktop notification when Claude finishes its work. `notify-send` and tmux are both present. Claude Code already has hooks configured in `~/.claude/settings.json`.

## Approach

Use Claude Code's **`Stop` hook** — fires exactly when Claude finishes a response/task. Hook runs `notify-send` to pop a desktop notification.

This is better than tmux's `monitor-silence` (which triggers on any silence, not just Claude finishing).

## Changes

### `~/.claude/settings.json` — add `Stop` hook

Add to the `hooks` array:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send -i dialog-information -t 5000 'Claude Code' 'Finished work in session: '\"$TMUX_PANE\""
          }
        ]
      }
    ]
  }
}
```

The `$TMUX_PANE` env var (e.g. `%3`) identifies which pane finished. Can also use `$TMUX` to detect if inside tmux at all.

## Critical File

- `~/.claude/settings.json` — only file to edit

## Verification

1. Start Claude in a tmux window
2. Give Claude a task (e.g. "search for X in repo")
3. Switch to another tmux session/window
4. When Claude finishes → desktop notification appears
5. Check notification shows correct pane ID
