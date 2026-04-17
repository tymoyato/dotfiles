---
name: Container-first development
description: Never install deps or run commands locally — always use Docker containers
type: feedback
originSessionId: dc480647-8246-4c23-9bec-347e1e031038
---
Never run `bundle install`, `npm install`, `go get`, or any dep install on local machine. Never invoke local runtimes (ruby, node, go) directly.

**Why:** User wants clean local machine — all runtimes and deps live in containers only.

**How to apply:** All commands (tests, linters, migrations, builds) must go through `docker-compose exec <service> <cmd>`. If a command would install or invoke local tooling, stop and rewrite as container exec instead.
