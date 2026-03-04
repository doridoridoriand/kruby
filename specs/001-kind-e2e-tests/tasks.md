# Tasks: Kind-backed Selective E2E Test Framework

**Input**: Design documents from `specs/001-kind-e2e-tests/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/test-runner.openapi.yaml

**Tests**: この feature は E2E テスト実装が主目的のため、各ユーザーストーリーにテストタスクを含める。

**Organization**: タスクはユーザーストーリー単位で独立実装・独立検証できるように分割する。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並列実行可能（別ファイル・未完了依存なし）
- **[Story]**: ユーザーストーリーに紐づくタスク（US1/US2/US3）
- すべてのタスクに正確なファイルパスを含める

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: E2E 実装のための最小ディレクトリ・実行入口を作る

- [ ] T001 Create E2E directory skeleton in kubernetes/spec/e2e/.gitkeep
- [ ] T002 [P] Create E2E support directory skeleton in kubernetes/spec/support/e2e/.gitkeep
- [ ] T003 [P] Create E2E script directory skeleton in scripts/e2e/.gitkeep
- [ ] T004 Add executable entrypoint skeleton for E2E runner in scripts/e2e/run-e2e
- [ ] T005 [P] Add executable entrypoint skeleton for change mapping in scripts/e2e/map-changes
- [ ] T006 [P] Add E2E artifact ignore rules in .gitignore

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべてのストーリーに共通で必要な E2E 実行基盤を実装する

**⚠️ CRITICAL**: このフェーズ完了前にユーザーストーリー実装を開始しない

- [ ] T007 Implement test target registry model from TestTarget entity in kubernetes/spec/support/e2e/target_catalog.rb
- [ ] T008 [P] Implement selector parser/validator (`apiGroup/version/resource:operation`) in kubernetes/spec/support/e2e/target_selector.rb
- [ ] T009 [P] Implement kind cluster lifecycle manager in kubernetes/spec/support/e2e/cluster_manager.rb
- [ ] T010 Implement namespace/resource cleanup helper in kubernetes/spec/support/e2e/resource_cleanup.rb
- [ ] T011 [P] Implement changed-files resolver from ChangeSet entity in kubernetes/spec/support/e2e/change_resolver.rb
- [ ] T012 [P] Implement failure artifact writer from FailureArtifact entity in kubernetes/spec/support/e2e/failure_reporter.rb
- [ ] T013 Add baseline smoke target config for fallback mode in kubernetes/spec/support/e2e/smoke_targets.yml
- [ ] T014 Wire E2E helper loading and mode env defaults in kubernetes/spec/spec_helper.rb
- [ ] T015 Add reusable Rake task namespace (`e2e:*`) in kubernetes/Rakefile

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 修正箇所だけを高速検証する targeted/changed 実行 (Priority: P1) 🎯 MVP

**Goal**: 開発者が API グループ/リソース/操作単位で対象を絞って E2E を実行できる

**Independent Test**: `E2E_MODE=targeted` で `core/v1/pods:create` のみ実行でき、`E2E_MODE=changed` で差分から対象 selector が解決される

### Tests for User Story 1

- [ ] T016 [P] [US1] Create targeted execution spec for core/v1 Pod create/delete in kubernetes/spec/e2e/core_v1_pods_targeted_spec.rb
- [ ] T017 [P] [US1] Create changed-mode selection spec for git diff mapping in kubernetes/spec/e2e/changed_mode_selection_spec.rb
- [ ] T018 [US1] Add fallback behavior spec for unresolved changes (`minimal-smoke|full`) in kubernetes/spec/e2e/changed_mode_selection_spec.rb

### Implementation for User Story 1

- [ ] T019 [P] [US1] Implement core/v1 Pod target definitions in kubernetes/spec/support/e2e/targets/core_v1_pods.rb
- [ ] T020 [P] [US1] Implement apps/v1 Deployment target definitions for selective checks in kubernetes/spec/support/e2e/targets/apps_v1_deployments.rb
- [ ] T021 [US1] Implement targeted run context (`E2E_TARGETS`) resolution in kubernetes/spec/support/e2e/run_context.rb
- [ ] T022 [US1] Implement mode dispatcher logic for `targeted` and `changed` in kubernetes/spec/support/e2e/mode_dispatcher.rb
- [ ] T023 [US1] Implement CLI option parsing for `--mode targeted|changed` in scripts/e2e/run-e2e
- [ ] T024 [US1] Implement changed-file mapping CLI output in scripts/e2e/map-changes

**Checkpoint**: User Story 1 is independently runnable and provides fast, scope-limited E2E feedback

---

## Phase 4: User Story 2 - リリース前に full 実行で回帰検知する (Priority: P2)

**Goal**: 代表 API グループを含む full E2E を一括実行し、回帰を検知できる

**Independent Test**: `E2E_MODE=full` で登録済み target catalog を順次実行し、成功/失敗が集約表示される

### Tests for User Story 2

- [ ] T025 [P] [US2] Create full-mode orchestration spec for catalog expansion in kubernetes/spec/e2e/full_mode_regression_spec.rb
- [ ] T026 [P] [US2] Create apps/v1 Deployment full-mode CRUD E2E spec in kubernetes/spec/e2e/apps_v1_deployments_full_spec.rb
- [ ] T027 [P] [US2] Create batch/v1 Job full-mode create/list/delete E2E spec in kubernetes/spec/e2e/batch_v1_jobs_full_spec.rb

### Implementation for User Story 2

- [ ] T028 [P] [US2] Implement batch/v1 Job target definitions in kubernetes/spec/support/e2e/targets/batch_v1_jobs.rb
- [ ] T029 [US2] Implement full-mode target expansion and execution order in kubernetes/spec/support/e2e/mode_dispatcher.rb
- [ ] T030 [US2] Implement `--mode full` flow in scripts/e2e/run-e2e
- [ ] T031 [US2] Add `e2e:full` rake task in kubernetes/Rakefile
- [ ] T032 [US2] Optimize cluster reuse policy for full run in kubernetes/spec/support/e2e/cluster_manager.rb

**Checkpoint**: User Story 2 is independently runnable as a pre-release regression gate

---

## Phase 5: User Story 3 - 失敗診断とパッケージ安全性を保証する (Priority: P3)

**Goal**: 失敗時に Issue 化しやすい診断情報を出力し、テストコードが gem 同梱されないことを継続的に検証できる

**Independent Test**: 意図的失敗で JSON artifact + 再現コマンドが出力され、package guard で `spec/test/features/docs` が gem に含まれないことを確認できる

### Tests for User Story 3

- [ ] T033 [P] [US3] Create failure artifact emission spec in kubernetes/spec/e2e/failure_artifact_spec.rb
- [ ] T034 [P] [US3] Create packaging safety guard spec in kubernetes/spec/e2e/packaging_safety_spec.rb

### Implementation for User Story 3

- [ ] T035 [US3] Implement structured failure payload (`runId,targetId,errorType,httpStatus,reproCommand`) in kubernetes/spec/support/e2e/failure_reporter.rb
- [ ] T036 [P] [US3] Implement reproducible command builder in kubernetes/spec/support/e2e/repro_command_builder.rb
- [ ] T037 [US3] Implement package guard script for gem contents in scripts/e2e/check-gem-package
- [ ] T038 [US3] Add `e2e:package_guard` rake task in kubernetes/Rakefile
- [ ] T039 [US3] Add issue-template-friendly summary output in scripts/e2e/run-e2e

**Checkpoint**: User Story 3 is independently runnable and provides actionable failure feedback + packaging safety

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリー横断の最終整備

- [ ] T040 [P] Document E2E run modes and selectors in specs/001-kind-e2e-tests/quickstart.md
- [ ] T041 [P] Add contributor-facing E2E usage guide in CONTRIBUTING.md
- [ ] T042 Add troubleshooting runbook for flaky kind startup and cleanup in docs/e2e-kind-testing.md
- [ ] T043 Validate quickstart commands and record reproducible examples in specs/001-kind-e2e-tests/implementation-notes.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 依存なし
- **Phase 2 (Foundational)**: Phase 1 完了後に開始、全ストーリーの前提
- **Phase 3 (US1)**: Phase 2 完了後に開始（MVP）
- **Phase 4 (US2)**: Phase 2 完了後に開始（US1 完了後を推奨）
- **Phase 5 (US3)**: Phase 2 完了後に開始（US1/US2 の実行結果統合のため後続推奨）
- **Phase 6 (Polish)**: US1-3 完了後

### User Story Dependencies

- **US1 (P1)**: Foundational 完了後に独立実装可能
- **US2 (P2)**: Foundational 完了後に実装可能、ただし `mode_dispatcher.rb` 競合回避のため US1 後を推奨
- **US3 (P3)**: Foundational 完了後に実装可能、失敗診断の統合確認のため US1/US2 後を推奨

### Within Each User Story

- テストタスクを先に作成し、実装前に失敗を確認
- `Target/Model` 相当ファイル -> `mode/service` 実装 -> `CLI`/`Rake` 統合の順で進める

### Dependency Graph

- Setup -> Foundational -> US1 -> US2 -> US3 -> Polish
- Setup -> Foundational -> US2 (parallel option)
- Setup -> Foundational -> US3 (parallel option)

---

## Parallel Execution Examples

### US1 Parallel Example

```bash
# Parallelizable test authoring
Task T016: kubernetes/spec/e2e/core_v1_pods_targeted_spec.rb
Task T017: kubernetes/spec/e2e/changed_mode_selection_spec.rb

# Parallelizable target definitions
Task T019: kubernetes/spec/support/e2e/targets/core_v1_pods.rb
Task T020: kubernetes/spec/support/e2e/targets/apps_v1_deployments.rb
```

### US2 Parallel Example

```bash
Task T026: kubernetes/spec/e2e/apps_v1_deployments_full_spec.rb
Task T027: kubernetes/spec/e2e/batch_v1_jobs_full_spec.rb
Task T028: kubernetes/spec/support/e2e/targets/batch_v1_jobs.rb
```

### US3 Parallel Example

```bash
Task T033: kubernetes/spec/e2e/failure_artifact_spec.rb
Task T034: kubernetes/spec/e2e/packaging_safety_spec.rb
Task T036: kubernetes/spec/support/e2e/repro_command_builder.rb
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 (Setup) を完了
2. Phase 2 (Foundational) を完了
3. Phase 3 (US1) を完了
4. `E2E_MODE=targeted` と `E2E_MODE=changed` の独立検証を実施
5. MVP として先に merge 可能

### Incremental Delivery

1. Setup + Foundational 完了
2. US1 をリリース（開発者向け高速検証）
3. US2 を追加（リリース前 full 回帰）
4. US3 を追加（診断強化 + packaging guard）
5. Polish を実施

### Parallel Team Strategy

1. 1名が Phase 1-2 を担当
2. 以降、US1/US2/US3 を担当分割して並行実装
3. `mode_dispatcher.rb` と `Rakefile` は競合しやすいため担当を固定

---

## Notes

- すべてのタスクはチェックリスト形式（`- [ ] Txxx ...`）を満たす
- `[P]` は並行可能タスクのみに付与
- `[USx]` はユーザーストーリーフェーズのタスクにのみ付与
- 各ストーリーは独立テスト基準を明示
