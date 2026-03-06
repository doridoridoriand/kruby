# Quickstart: Kind-backed Selective E2E for kruby

## Prerequisites
- Docker
- kind
- kubectl
- ripgrep (`rg`)
- Ruby 3.3+
- Bundler

## Setup
```bash
cd kubernetes
bundle install
```

## Selector format
- Single selector: `apiGroup/version/resource:operation`
  - Example: `core/v1/pods:create`
- Multiple selectors: comma-separated
  - Example: `core/v1/pods:create,apps/v1/deployments:update`
- Supported operations: `create|get|list|update|patch|delete|watch`

## Run modes (`scripts/e2e/run-e2e`)

### 1) Full
```bash
scripts/e2e/run-e2e --mode full
```

### 2) Targeted
```bash
scripts/e2e/run-e2e \
  --mode targeted \
  --targets 'core/v1/pods:create,apps/v1/deployments:update'
```

### 3) Changed-only
```bash
scripts/e2e/run-e2e --mode changed --base-ref origin/HEAD
```

### Optional flags
```bash
scripts/e2e/run-e2e --mode full --fallback minimal-smoke -- --format documentation
```
- `--fallback <minimal-smoke|full>`
- `--` 以降は RSpec オプションとして渡される

## Changed-file mapping (`scripts/e2e/map-changes`)
```bash
scripts/e2e/map-changes --base-ref origin/HEAD --format text
scripts/e2e/map-changes --base-ref origin/HEAD --format json
scripts/e2e/map-changes --changed-file kubernetes/lib/kubernetes/api/core_v1_api.rb --format json
```

## Package safety guard
```bash
scripts/e2e/check-gem-package
cd kubernetes
bundle exec rake e2e:package_guard
```

## Cleanup expectations
- すべてのモードで終了時に namespace/cluster をクリーンアップ
- `E2E_MODE=full` では cluster reuse を有効化可能（`E2E_REUSE_CLUSTER=1`）

## Expected output
- `run-e2e` は実行サマリ（examples/failures/duration）を出力
- 失敗時は issue template に貼り付け可能な summary を追加出力
- `failure_reporter` は JSON artifact を書き出し、`runId/targetId/errorType/httpStatus/reproCommand` を含む
