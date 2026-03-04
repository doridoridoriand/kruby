# Feature Spec: Kind-backed Selective E2E Test Framework for Generated API Functions

## Problem Statement
`kruby` は OpenAPI 生成コードを大量に含むため、単体モックのみでは API 呼び出し実挙動を十分に担保しづらい。一方で全件 E2E は重く、開発サイクルを阻害する。

## Goals
- kind クラスタを使った実 API コール E2E を導入する。
- 生成関数の期待挙動を API グループ/リソース/操作単位で検証できるようにする。
- フル実行と、修正箇所のみの選択実行を両立する。
- 既存の gem パッケージング範囲を維持し、テストコードを同梱しない。

## Non-Goals
- すべての API 関数を毎 PR でフル実行すること。
- 本番クラスター向けの長期 soak test。
- テスト失敗通知の外部 SaaS 連携実装。

## Functional Requirements

### FR-1: Kind E2E Execution
1. テスト実行時に kind クラスタを起動し、`kubectl`/API client で実際の API コールを行えること。
2. 実行後は作成リソースとクラスターをクリーンアップできること。

### FR-2: Selective Targeting by API Scope
1. API グループ、バージョン、リソース、操作（create/get/list/update/patch/delete/watch）でテスト対象を指定できること。
2. 指定対象だけを単体で実行できること。

### FR-3: Changed-only Test Mode
1. 変更ファイルから対象 API スコープを解決し、該当テストのみ実行できること。
2. 解決不能な変更は安全側（最小共通スモーク or フル）にフォールバックできること。

### FR-4: Execution Modes
1. `full` モードで登録済み E2E 全件を実行できること。
2. `targeted` モードで明示指定の対象だけを実行できること。
3. `changed` モードで差分ベースの対象のみを実行できること。

### FR-5: Failure Visibility
1. 失敗時に対象 API スコープ、操作、HTTP ステータス、レスポンス本文、関連ログを出力すること。
2. Issue 起票に必要な最小情報（再現コマンド、対象、失敗要約）を出力できること。

### FR-6: Packaging Safety
1. E2E テストコード・フィクスチャは gem 同梱対象に含まれないこと。
2. 既存 `kubernetes.gemspec` の同梱ホワイトリストポリシーを維持すること。

## User Scenarios

### Scenario A: 開発者が修正箇所だけ検証
- Given API クライアントの特定リソース操作を変更した
- When `changed` または `targeted` モードで E2E を実行する
- Then 該当 API スコープのみ高速に検証できる

### Scenario B: リリース前のフル検証
- Given リリース候補を準備した
- When `full` モードを実行する
- Then 登録済み E2E を網羅実行し、回帰を検知できる

## Acceptance Criteria
- AC-1: kind を用いた E2E がローカルで再現可能である。
- AC-2: `targeted` 実行で API グループ/リソース/操作単位の絞り込みができる。
- AC-3: `changed` 実行で差分に対応したテスト選択が機能する。
- AC-4: 失敗時に Issue 化に十分な診断情報が出力される。
- AC-5: gem 内容に `spec/test/features/docs` が含まれない。
