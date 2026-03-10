# Implementation Plan: Real API-call-based E2E Coverage Expansion

**Branch**: `update-k8s-latest` | **Date**: 2026-03-06  
**Target**: `kubernetes/lib/kubernetes/api/*_api.rb` の実 API 呼び出し網羅を段階的に拡大

## 1. Summary

現在の E2E は `targeted/changed/full` の選択実行基盤を検証できている一方、
「実 API 呼び出しで生成関数が期待通り動くか」の網羅は限定的。

この計画では、`kind` 上で実際に `Kubernetes::*Api` メソッドを呼び出す E2E を段階拡張し、
最終的に「候補メソッド群に対する網羅率」を CI で可視化・ゲート化する。

## 2. Baseline (2026-03-06)

- API クラスファイル数: `65`
- API メソッド総数: `1847`
- `_with_http_info` を除くメソッド数: `956`
- CRUD/Watch 系候補メソッド数（`create/read/list/replace/patch/delete/watch_*`）: `771`
- 現在の E2E selector 登録数: `21`
  - `core/v1/pods:*`
  - `apps/v1/deployments:*`
  - `batch/v1/jobs:*`

## 3. Coverage Definition

網羅は次の 3 レイヤで定義する。

1. **Selector Coverage**
- `apiGroup/version/resource:operation` 単位で実行可能なターゲット定義が存在する割合。

2. **Real Call Coverage**
- selector に紐づく E2E が、実際に `Kubernetes::*Api` の対象メソッドを呼び出す割合。

3. **CI Gate Coverage**
- Coverage レポートが CI で計測され、閾値未達を fail にできる状態。

## 4. Scope / Non-Scope

### In Scope
- CRUD + watch の実 API 呼び出し E2E
- namespaced / cluster-scoped リソース双方
- `changed` モードで差分に応じた selector 解決
- カバレッジレポート（JSON + 人間可読サマリ）

### Out of Scope (初期)
- `exec/attach/portforward/proxy` 系の接続 API
- 環境依存が強い API（クラウド依存ストレージ・LB 前提）
- 全 query option 組み合わせの総当たり

## 5. Architecture Changes

1. **Target Catalog 自動生成補助**
- `kubernetes/lib/kubernetes/api/*_api.rb` からメソッドを収集し、
  selector 候補と API メソッド名のマッピングを生成。
- 手動登録は「除外理由」「前提条件」のみ持つ最小差分方式に変更。

2. **Executor 層の導入**
- `kubernetes/spec/support/e2e/executor.rb` を追加し、selector ごとの実行器を統一インターフェース化。
- 実行器は `setup -> api_call -> assert -> cleanup` の4段階。

3. **Fixture/Factory 標準化**
- リソースごとに body 生成を `kubernetes/spec/support/e2e/factories/*` に集約。
- ランダム名、namespace、ownerReferences の共通ユーティリティを導入。

4. **Coverage Reporter**
- 実行対象、成功/失敗、未対応、除外理由を JSON で出力。
- `run-e2e` 終了時に coverage サマリを表示。

## 6. Delivery Phases

### Phase 0: Inventory & Policy (1週間)
- API メソッド棚卸しスクリプトを追加。
- 対象/除外ポリシーを `kubernetes/spec/support/e2e/coverage_policy.yml` で明文化。
- 成果物:
  - `coverage_inventory.json`
  - 除外カテゴリ一覧（理由付き）

### Phase 1: Harness Upgrade (1週間)
- `executor`, `factory`, `coverage_reporter` を実装。
- 既存3リソース（pods/deployments/jobs）を実 API 呼び出し実行へ移行。
- 成果物:
  - 既存 E2E が selector 検証だけでなく実 call を実施
  - 失敗 artifact に selector + method 名を追加

### Phase 2: Core Workload Expansion (2週間)
- `core/apps/batch` の主要ワークロード系を追加:
  - ConfigMap, Secret, Service, StatefulSet, ReplicaSet, CronJob
- `targeted` と `changed` の両モードで新規 selector を運用。
- マイルストーン:
  - selector 数: `21 -> 120+`

### Phase 3: Cluster-scoped & Subresource (2週間)
- Namespace, Node(read-only), PV/PVC, status/scale サブリソースを追加。
- watch 系の安定化（タイムアウト/リトライ/中断処理）。
- マイルストーン:
  - selector 数: `120+ -> 250+`

### Phase 4: CI Gate & Performance (1週間)
- CI で `changed`（PR）/ `full`（nightly）を分離。
- coverage 閾値を段階導入:
  - Step A: レポートのみ
  - Step B: warning gate
  - Step C: hard fail gate
- マイルストーン:
  - PR 実行時間の目標 p95: 15 分以内

### Phase 5: Stabilization (継続)
- flaky target を quarantine 管理。
- 再現性向上のため失敗時 `kubectl describe/logs/events` を自動収集。
- 週次で除外リストを棚卸し。

## 7. CI Strategy

- **PR**
  - `run-e2e --mode changed`
  - `e2e:package_guard`
  - coverage report upload（失敗時も保持）

- **Nightly**
  - `run-e2e --mode full --fallback full`
  - 全 selector の実 call 検証

- **Release Candidate**
  - full + strict coverage gate

## 8. Test Strategy

- 1 selector = 1 実 API call シナリオを原則。
- create 系は必ず read/list の後続検証を行う。
- delete 系は存在確認 API で消失を検証する。
- watch 系は短時間 window + label selector で deterministic 化。

## 9. Risks & Mitigations

1. **実行時間増大**
- 対策: changed モード優先、full は nightly、リソース並列を段階導入。

2. **kind 環境依存の flaky**
- 対策: preflight check、リトライ、artifact 収集強化、quarantine 運用。

3. **API 多様性による保守負荷**
- 対策: factory 共通化、catalog 自動生成、除外理由の明文化。

4. **壊れやすい watch テスト**
- 対策: timeout 明示、イベント待機条件の標準化、失敗時ログ拡張。

## 10. Definition of Done

- `changed`/`targeted`/`full` のすべてで、対象 selector が実 API 呼び出しを行う。
- coverage レポートに `covered / unsupported / excluded / failed` が出る。
- CI に coverage gate が導入され、基準未達を検知できる。
- `kubernetes/kubernetes.gemspec` の同梱ポリシーを維持（`spec/test/features/docs` 非同梱）。

## 11. First Implementation Slice (次に着手する最小単位)

1. `coverage_inventory` 生成スクリプト追加
2. `executor` + `coverage_reporter` の最小実装
3. `pods/deployments/jobs` の3系統を「実 API call 検証」に置換
4. `run-e2e` に coverage summary 出力を追加
