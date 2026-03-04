#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
  exit 0
fi

# Detect machine-specific absolute file paths and guide contributors
# to use repository-relative paths instead.
pattern_unix='(^|[[:space:]"'"'"'(\[])/(Users|home|private|var/folders|tmp|opt|etc|mnt|Volumes)/[^[:space:]"'"'"'`<>)]*'
pattern_windows='(^|[[:space:]"'"'"'(\[])[A-Za-z]:[\\/][^[:space:]"'"'"'`<>)]*'
pattern_file_uri='file:///'

failed=0

for file in "$@"; do
  [[ -f "$file" ]] || continue

  # Skip likely binary files.
  if ! grep -Iq . "$file"; then
    continue
  fi

  if matches=$(rg -n --no-heading -e "$pattern_unix" -e "$pattern_windows" -e "$pattern_file_uri" "$file"); then
    if [[ -n "$matches" ]]; then
      echo "ERROR: machine-specific absolute path detected in $file"
      echo "$matches"
      failed=1
    fi
  fi
done

if [[ $failed -ne 0 ]]; then
  cat <<'EOF'

Use repository-relative paths from project root, for example:
  specs/001-kind-e2e-tests/plan.md
  kubernetes/spec/e2e/core_v1_pods_targeted_spec.rb
Do not commit /Users/... , /home/... , C:\... , or file:/// paths.
EOF
  exit 1
fi

exit 0
