Review all uncommitted changes, write a commit message, commit, and push — no co-author line.

## Steps

1. Run these in parallel:
   - `git status` — see untracked and modified files
   - `git diff` — see unstaged changes
   - `git diff --cached` — see staged changes
   - `git log -5 --oneline` — learn commit message style of this repo

2. Analyze all changes. Understand what changed and why (infer from context).

3. Stage changed files by name (not `git add -A` or `git add .` — be precise, skip anything that looks like secrets or large binaries).

4. Write a commit message:
   - First line: imperative mood, under 72 chars, lowercase verb (e.g. "add", "fix", "refactor")
   - Body if needed: explain the why, not the what
   - **No `Co-Authored-By` line. No Claude attribution. Nothing about AI.**

5. Commit using a HEREDOC so formatting is preserved:
   ```
   git commit -m "$(cat <<'EOF'
   <message here>
   EOF
   )"
   ```

6. Push to the current branch's remote tracking branch:
   ```
   git push
   ```
   If no upstream set: `git push -u origin <branch>`.

7. Report: what was committed, the commit hash, push result. One short paragraph, no fluff.

## Constraints

- Never use `--no-verify`
- Never add `Co-Authored-By: Claude` or any AI attribution
- Never commit `.env`, credential files, or secrets
- If nothing to commit, say so and stop
