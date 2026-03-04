# Phase 0 Research: Kind-backed Selective E2E

## Research Tasks
- Research selector grammar for API group/resource/operation targeted execution.
- Research changed-files to test-scope mapping strategy.
- Find best practices for kind lifecycle management in CI/local E2E.
- Find best practices for RSpec selective execution patterns.
- Research failure artifact shape suitable for GitHub Issue feedback.

## Decisions

### 1) Test Scope Selector
- Decision: `apiGroup/version/resource:operation` 形式の selector を採用（例: `core/v1/pods:create`）。複数指定はカンマ区切り。
- Rationale: 人間可読で、API グループ単位・リソース単位・操作単位の絞り込みを一貫して扱える。
- Alternatives considered:
  - RSpec tag のみで表現: 粒度の組み合わせ表現が弱い。
  - YAML のみ指定: 柔軟だが単発実行コストが高い。

### 2) Changed-only Resolution
- Decision: `git diff` の変更ファイルを API 定義ファイル・spec ファイル・support ファイルに分類し、`change_resolver` で selector 群へ解決する。
- Rationale: 実装変更とテスト対象を機械的に紐付けられ、開発者の手動判断コストを減らせる。
- Alternatives considered:
  - 常に full 実行: 安全だが遅い。
  - 手動 selector 指定のみ: 速いが取りこぼしリスクが高い。

### 3) kind Lifecycle
- Decision: 1 test-run 1 cluster（`kind create cluster`）を基本とし、`targeted` モードでは単一クラスタ内で複数ケースを実行後に teardown。
- Rationale: テスト分離性と再現性が高く、リーク時の影響範囲が限定される。
- Alternatives considered:
  - 共有長寿命 cluster: 速いが状態汚染リスクが高い。
  - case ごとに cluster 起動: 安全だが遅すぎる。

### 4) RSpec Integration
- Decision: `kubernetes/spec/e2e` 配下に E2E spec を分離し、`E2E_MODE`/`E2E_TARGETS`/`BASE_REF` 環境変数で選択制御する。
- Rationale: 既存 RSpec フローに自然統合でき、導入コストが最小。
- Alternatives considered:
  - 別テストフレームワーク導入: 学習コスト・運用コスト増。
  - 外部専用リポジトリ先行: 本体変更との同期が難しい。

### 5) Failure Artifact
- Decision: 失敗時は JSON 1件を標準出力 + ファイル出力（対象 selector、HTTP status、レスポンス断片、再現コマンド）する。
- Rationale: Issue 起票時の転記容易性と自動収集の両立。
- Alternatives considered:
  - テキストログのみ: 構造化不足で再利用しづらい。
  - 大量ログ常時出力: 可読性が悪化。

## Clarification Resolution Status
- `NEEDS CLARIFICATION` items: 0（全解決）
