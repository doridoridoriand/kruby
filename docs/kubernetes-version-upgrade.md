# Kubernetes Version Upgrade Runbook

This document describes a repeatable process to upgrade this client to a newer Kubernetes OpenAPI version.
All commands are relative to the repository root and avoid machine-specific paths.

## Goal

- Update the client to a target Kubernetes release branch (for example `release-1.35`).
- Regenerate OpenAPI-based code and docs.
- Keep manual code intact.
- Verify generation quality before creating a PR.

## Prerequisites

- `git`
- `bash`
- `docker`
- Access to the Kubernetes OpenAPI generator repo (`kubernetes-client/gen`)

## 1. Select the target Kubernetes version

1. Check the latest stable Kubernetes release:

```bash
curl -fsSL https://dl.k8s.io/release/stable.txt
```

2. Decide the branch and gem version policy:
- `KUBERNETES_BRANCH`: `release-<major>.<minor>` (example: `release-1.35`)
- `CLIENT_VERSION`: `<major>.<minor>.0` (example: `1.35.0`)

## 2. Update version settings

Edit `settings`:

```bash
export KUBERNETES_BRANCH="release-1.xx"
export CLIENT_VERSION="1.xx.0"
```

## 3. Regenerate from Kubernetes OpenAPI

Run from repository root:

```bash
${GEN_REPO_BASE}/openapi/ruby.sh kubernetes settings
```

Notes:
- `GEN_REPO_BASE` should point to your local clone of `kubernetes-client/gen`.
- Generation will update `kubernetes/swagger.json`, generated Ruby code, docs, and metadata files.

## 4. Keep manual files (must-do)

The following files are maintained manually and must be restored after generation:

```bash
cp kubernetes/src/kubernetes/config/error.rb kubernetes/lib/kubernetes/config/error.rb
cp kubernetes/src/kubernetes/config/incluster_config.rb kubernetes/lib/kubernetes/config/incluster_config.rb
cp kubernetes/src/kubernetes/config/kube_config.rb kubernetes/lib/kubernetes/config/kube_config.rb
cp kubernetes/src/kubernetes/utils.rb kubernetes/lib/kubernetes/utils.rb
```

Confirm `kubernetes/lib/kubernetes.rb` still requires utils:

```bash
rg -n "require 'kubernetes/utils'" kubernetes/lib/kubernetes.rb
```

## 5. Recompute OpenAPI SHA

```bash
shasum -a 256 kubernetes/swagger.json | awk '{print $1}' > kubernetes/.openapi-generator/swagger.json.sha256
```

## 6. Validate OpenAPI operation IDs

Duplicate `operationId` values can break generation quality. Validate both processed and unprocessed specs:

```bash
python3 - <<'PY'
import json
from collections import Counter

for path in ["kubernetes/swagger.json.unprocessed", "kubernetes/swagger.json"]:
    with open(path) as f:
        spec = json.load(f)
    op_ids = []
    for _, methods in spec.get("paths", {}).items():
        for _, op in methods.items():
            if isinstance(op, dict) and "operationId" in op:
                op_ids.append(op["operationId"])
    dup = sum(1 for v in Counter(op_ids).values() if v > 1)
    print(f"{path}: operations={len(op_ids)} duplicate_operation_ids={dup}")
PY
```

Expected: `duplicate_operation_ids=0` for both files.

If duplicates appear after preprocessing:
- Apply deterministic de-duplication in the preprocessing step (in the generator flow), not manually inside generated Ruby files.
- Recommended strategy: append a normalized suffix derived from HTTP method and path for conflicting IDs.

## 7. Build and smoke test

```bash
cd kubernetes
gem build kubernetes.gemspec
ruby -Ilib -e "require 'kubernetes'; puts Kubernetes::VERSION"
```

Optional full test:

```bash
bundle exec rake
```

If local Ruby/Bundler versions are incompatible with this repo, run tests in a compatible containerized Ruby environment and record that in the PR.

## 8. Final review checklist

- `settings` updated to target branch/version.
- Generated files updated (`kubernetes/lib`, `kubernetes/docs`, `kubernetes/swagger.json`).
- Manual files restored from `kubernetes/src`.
- `kubernetes/.openapi-generator/swagger.json.sha256` matches current `swagger.json`.
- `kubernetes/lib/kubernetes/version.rb` has expected version.
- `kubernetes/.travis.yml` gem install target matches `CLIENT_VERSION`.
- OpenAPI duplicate check is clean.
- `gem build` succeeds.

## 9. Commit guidance

Use a commit message that includes:
- target Kubernetes branch/version
- generator run
- any preprocessing fixes required for the target branch

Example:

```text
Update client to release-1.xx (v1.xx.0) and regenerate OpenAPI artifacts
```
