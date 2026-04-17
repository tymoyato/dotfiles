# Plan: Work Directory Git Status Hook

## Context
The user wants a fish function that automatically shows the git status of every repo inside `~/work` whenever they `cd` into that directory. This avoids having to manually check each repo's status.

## Approach

Create a single fish function file that listens on the `PWD` variable change event. When the new directory is `~/work`, it scans all immediate subdirectories that are git repos and prints their status.

### Status logic per repo

For each subdirectory:
1. Skip if not a git repo (no `.git/`)
2. Check for uncommitted changes (staged + unstaged + untracked): `git status --porcelain`
   - If output is non-empty → `reponame: changes not staged`
3. If clean → `reponame: up to date with main`

No remote fetch — local state only (fast).

### Implementation

**File to create:** `/home/tymoyato/.dotfiles/dotfiles/fish/functions/work_status.fish`

```fish
function __work_status --on-variable PWD
    if test "$PWD" != "$HOME/work"
        return
    end

    for dir in $HOME/work/*/
        test -d "$dir/.git" || continue
        set repo (basename $dir)

        set changes (git -C $dir status --porcelain 2>/dev/null)
        if test -n "$changes"
            echo "$repo: changes not staged"
        else
            echo "$repo: up to date with main"
        end
    end
end
```

## Files

| Action | Path |
|--------|------|
| Create | `/home/tymoyato/.dotfiles/dotfiles/fish/functions/work_status.fish` |

No changes to `config.fish` needed — fish autoloads functions from the `functions/` directory.

## Verification

1. Open a new terminal and run `cd ~/work`
2. Each repo subdirectory should print its status line
3. Test edge cases: repo with staged changes, repo with untracked files, clean repo

