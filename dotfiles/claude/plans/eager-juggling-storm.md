# Plan: Replace local `bundle exec rails server` with docker-first instructions

## Context
The project is docker-first, but three documentation files still reference `bundle exec rails server` as a way to run auth-api locally. This is misleading and contradicts the intended docker-first workflow. The goal is to remove those local-run references and replace them with Docker commands.

`infrastructure/docker-compose.yml:156` keeps its `bundle exec rails server -b 0.0.0.0` — that is the entrypoint *inside* the container and must not change.

---

## Changes

### 1. `CLAUDE.md` — line 42
Remove `bundle exec rails server` from the Auth API bash block.
Replace with a docker-first command:
```bash
cd ../infrastructure && docker-compose up auth-api   # Start auth-api in Docker
```

### 2. `auth-api/README.md` — lines 70–72
Replace the "Start server" block:
```bash
# Start server
bundle exec rails server
```
With:
```bash
# Start via Docker (recommended)
cd ../infrastructure && docker-compose up auth-api
```

### 3. `infrastructure/tips/memory-limits.md` — lines 169–172
The snippet suggests running auth-api locally as a memory-saving tip. Remove the `bundle exec rails server` line and keep only the infrastructure-only start as the suggested alternative:
```bash
# Only infrastructure
./start-infrastructure.sh
# Then start auth-api in Docker separately if needed:
docker-compose up auth-api
```

---

## Files to modify
- `/home/tymoyato/work/CLAUDE.md`
- `/home/tymoyato/work/auth-api/README.md`
- `/home/tymoyato/work/infrastructure/tips/memory-limits.md`

## Do NOT touch
- `/home/tymoyato/work/infrastructure/docker-compose.yml` — the `bundle exec rails server -b 0.0.0.0` there is the in-container entrypoint, not a local dev instruction.

## Verification
After edits: `grep -r "bundle exec rails server" /home/tymoyato/work` should only return the docker-compose.yml line.
