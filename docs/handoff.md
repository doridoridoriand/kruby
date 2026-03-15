# Handoff

このレポートは、別セッションへ作業を引き継ぐための自動生成スナップショットです。
テンプレート元: https://gist.githubusercontent.com/doridoridoriand/68dc9b4145dd905155a48ffbfdc29c4f/raw/d2b9e7a073f4cf5fa6b60e860341cf8693c39aaa/handoff.md
生成時刻: 2026-03-15 03:22:23 UTC
生成フック: `.githooks/pre-commit`

## 1. Goal

- `update-k8s-latest` 上の staged changes を引き継ぐための handoff スナップショットです。
- issue / ticket / spec などの意図は自動取得できないため、必要ならこのファイルに追記してください。

## 2. Current Status

- `docs/handoff.md` は commit 前に生成され、同じ commit に含める前提です。
- 基点の `HEAD`: `965d9e272af67961c90405e87c66041cf72ed4b1` (`docs: add generated agent context`)
- このスナップショットは `docs/handoff.md` 自身を差分集計から除外しているため、handoff 更新の自己参照を避けています。

## 3. Files Changed

- `.github/workflows/release.yml`: staged modification.
- `CHANGELOG.md`: staged modification.
- `CONTRIBUTING.md`: staged modification.
- `README.md`: staged modification.
- `docs/release-process.md`: staged modification.
- `kubernetes/README.md`: staged modification.
- `kubernetes/lib/kubernetes/release/changelog.rb`: staged modification.
- `kubernetes/spec/release/changelog_spec.rb`: staged modification.
- `scripts/release/tag`: staged modification.

## 4. Branch / Commit

- Branch: `update-k8s-latest`
- Base HEAD: `965d9e272af67961c90405e87c66041cf72ed4b1`
- Recent commits:

```text
965d9e2 docs: add generated agent context
ab05f68 chore: add spec kit scaffolding
4809376 fix: allow generic tmp paths in hook
f7a0329 chore: automate handoff report generation
172def8 release: 1.35.0.4
```

## 5. Commands Run

- `git diff --cached --name-status --no-renames -- . ':(exclude)docs/handoff.md'`: staged file list used for the summary below.
- `git diff --cached --stat --no-renames -- . ':(exclude)docs/handoff.md'`: staged diff size summary.

```text
 .github/workflows/release.yml                  | 17 ++++++++++---
 CHANGELOG.md                                   |  2 +-
 CONTRIBUTING.md                                |  2 +-
 README.md                                      |  2 +-
 docs/release-process.md                        | 16 ++++++------
 kubernetes/README.md                           |  2 +-
 kubernetes/lib/kubernetes/release/changelog.rb |  5 ++--
 kubernetes/spec/release/changelog_spec.rb      | 35 ++++++++++++++++++++++++++
 scripts/release/tag                            | 17 +++++++++++++
 9 files changed, 80 insertions(+), 18 deletions(-)
```

## 6. Verification

- この hook は git metadata だけを使ってレポートを生成します。
- テストや手動確認の実施状況は自動判定しないため、必要ならここに追記してください。
- commit 完了後の SHA はこの時点では未確定です。

## 7. Risks / Blockers

- 設計判断、チケット文脈、レビュー論点などの非 git 情報は自動では埋まりません。
- 実行コマンドや検証結果を詳細に残したい場合は、commit 前に手動追記が必要です。

## 8. Next Step

- このファイルを確認し、必要なら Goal / Verification / Notes を補足する。
- staged changes を commit する。
- 次セッションでは `docs/handoff.md` を起点に差分と直近 commit を確認する。

## 9. Notes For The Next Session

- このレポートは commit 後ではなく commit 前に生成することで、handoff ファイル自身が次の handoff を生み続けるループを防いでいます。
- report path は `docs/handoff.md` に固定し、履歴は git の file history で追跡します。
- commit 後に自動生成を一時停止したい場合は `KRUBY_SKIP_HANDOFF_HOOK=1` を使ってください。
