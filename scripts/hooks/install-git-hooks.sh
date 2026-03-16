#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ ! -d .githooks ]]; then
  echo "Error: .githooks directory not found at repo root." >&2
  exit 1
fi

git config core.hooksPath .githooks

cat <<'EOF'
Configured git hooks for this repository:
- core.hooksPath = .githooks

The versioned pre-commit hook will:
- generate docs/handoff.md before each commit
- stage the generated report in the same commit
- run pre-commit hooks when the pre-commit CLI is available
- fall back to scripts/hooks/check-no-absolute-paths.sh otherwise
EOF
