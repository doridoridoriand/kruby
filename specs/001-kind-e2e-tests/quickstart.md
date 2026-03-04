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

## Run modes

### 1) Full E2E
```bash
cd kubernetes
E2E_MODE=full bundle exec rspec spec/e2e
```

### 2) Targeted E2E (API group/resource/operation)
```bash
cd kubernetes
E2E_MODE=targeted E2E_TARGETS='core/v1/pods:create,apps/v1/deployments:update' bundle exec rspec spec/e2e
```

### 3) Changed-only E2E
```bash
cd kubernetes
E2E_MODE=changed BASE_REF=origin/HEAD bundle exec rspec spec/e2e
```

## Expected output
- 各失敗ケースで `target selector`, `http status`, `response excerpt`, `repro command` を出力
- 任意で JSON artifact を保存（Issue 化用）

## Cleanup expectations
- すべてのモードで終了時に namespace/cluster をクリーンアップ
- 異常終了時も `ensure` で teardown 実行

## Packaging safety check
```bash
cd kubernetes
gem build kubernetes.gemspec
GEM=$(ls -t kruby-*.gem | head -n1)
tar -xOf "$GEM" data.tar.gz | tar -tz | rg '^(spec|test|features|docs)/' || true
```
