# Implementation Plan: Kind-backed Selective E2E Test Framework

**Branch**: `001-kind-e2e-tests` | **Date**: 2026-03-04 | **Spec**: `specs/001-kind-e2e-tests/spec.md`
**Input**: Feature specification from `specs/001-kind-e2e-tests/spec.md`

## Summary
kind クラスター上で実 API コールを行う E2E テスト基盤を `kruby` 本体リポジトリに追加する。実行モードは `full` / `targeted` / `changed` を提供し、API グループ・リソース・操作単位で最小実行できる構成にする。差分解決不能時は安全側フォールバックを持たせる。

## Technical Context

**Language/Version**: Ruby 3.3+（CI は 3.3/3.4）  
**Primary Dependencies**: RSpec, kruby client (`Kubernetes::*Api`), kind, kubectl, Docker, bash  
**Storage**: N/A（テスト実行時は一時クラスタと一時 namespace のみ）  
**Testing**: RSpec + kind E2E（既存 unit/spec と分離）  
**Target Platform**: Linux/macOS 開発環境 + CI runner（Docker 利用可能）  
**Project Type**: Ruby library repository with in-repo test harness  
**Performance Goals**: targeted 実行 p95 3分以内、full 実行 20分以内を目標  
**Constraints**: テストは gem 同梱対象外、失敗時に再現情報を必須出力、差分解決不能時は安全側フォールバック  
**Scale/Scope**: 初期は主要 API グループ（core/apps/batch）で 10〜20 の代表リソース操作を E2E 化

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Constitution source: `.specify/memory/constitution.md`
- 現状: 内容がプレースホルダ（未批准）で、厳密な規範条項は未定義。
- Temporary project gates (this feature):
  - Gate A: E2E は選択実行可能で、通常開発を阻害しないこと。
  - Gate B: 失敗時に Issue 化可能な診断情報を標準出力できること。
  - Gate C: gem 同梱範囲を変更しないこと。

Pre-Phase 0 Gate Result: PASS（上記 temporary gates を採用）

## Project Structure

### Documentation (this feature)

```text
specs/001-kind-e2e-tests/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    └── test-runner.openapi.yaml
```

### Source Code (repository root)

```text
kubernetes/
├── spec/
│   ├── e2e/
│   │   ├── core_v1_pod_spec.rb
│   │   ├── apps_v1_deployment_spec.rb
│   │   └── ...
│   ├── support/
│   │   └── e2e/
│   │       ├── cluster_manager.rb
│   │       ├── target_selector.rb
│   │       ├── change_resolver.rb
│   │       └── failure_reporter.rb
│   └── spec_helper.rb
├── Rakefile
└── Gemfile

scripts/
└── e2e/
    ├── run-e2e
    └── map-changes
```

**Structure Decision**: 既存 `kubernetes/spec` を拡張し、E2E を `kubernetes/spec/e2e` に分離。選択実行ロジックは `kubernetes/spec/support/e2e` に集約し、Rake/環境変数から呼び出す。

## Phase 0 Findings Integration

`research.md` により、初期検討項目（selector 仕様、changed モードの解決戦略、kind ライフサイクル、失敗診断フォーマット）をすべて解決済み。未解決の `NEEDS CLARIFICATION` はなし。

## Post-Design Constitution Check (Re-evaluation)

- Gate A (選択実行): `TestTargetSelector` と `ChangeResolver` を設計し達成見込み。
- Gate B (診断情報): `FailureArtifact` モデルと quickstart 手順で運用可能。
- Gate C (gem 同梱): 既存 `kubernetes.gemspec` のホワイトリスト維持を前提に達成可能。

Post-Phase 1 Gate Result: PASS

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| なし | N/A | N/A |
