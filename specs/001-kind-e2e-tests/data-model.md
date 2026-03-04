# Data Model: Kind-backed Selective E2E

## Entity: TestTarget
- Fields:
  - `id` (string, unique): `core/v1/pods:create` 形式
  - `api_group` (string): `core`, `apps`, `batch` など
  - `version` (string): `v1`, `v1beta1` など
  - `resource` (string): `pods`, `deployments` など
  - `operation` (enum): `create|get|list|update|patch|delete|watch`
  - `namespace_scoped` (boolean)
- Validation:
  - `id` は `apiGroup/version/resource:operation` パターン必須
  - `operation` は定義済み enum のみ

## Entity: TestCase
- Fields:
  - `name` (string)
  - `target_id` (string, FK -> TestTarget.id)
  - `preconditions` (array[string])
  - `steps` (array[string])
  - `assertions` (array[string])
  - `tags` (array[string])
- Relationships:
  - Many TestCase -> One TestTarget
- Validation:
  - `target_id` が未登録なら invalid

## Entity: TestRun
- Fields:
  - `run_id` (string, unique)
  - `mode` (enum): `full|targeted|changed`
  - `requested_targets` (array[string])
  - `resolved_targets` (array[string])
  - `status` (enum): `queued|running|passed|failed|canceled`
  - `started_at` (datetime)
  - `finished_at` (datetime, nullable)
  - `cluster_name` (string)
- State transitions:
  - `queued -> running -> passed|failed|canceled`
- Validation:
  - `targeted` mode では `requested_targets` 非空必須

## Entity: ChangeSet
- Fields:
  - `base_ref` (string)
  - `head_ref` (string)
  - `changed_files` (array[string])
  - `mapped_targets` (array[string])
  - `fallback_strategy` (enum): `minimal-smoke|full`
- Validation:
  - `changed_files` 空のときは `mapped_targets` 空許容、fallback 必須

## Entity: FailureArtifact
- Fields:
  - `run_id` (string, FK -> TestRun.run_id)
  - `target_id` (string, FK -> TestTarget.id)
  - `error_type` (string)
  - `http_status` (integer, nullable)
  - `response_excerpt` (string)
  - `repro_command` (string)
  - `log_path` (string)
- Validation:
  - `repro_command` は常に必須
  - `response_excerpt` は最大長を制限（例 8KB）
