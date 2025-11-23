# ブランチ戦略

SlowQL プロジェクトの Git ブランチ管理戦略について説明します。

## 概要

本プロジェトは**GitHub Flow 変形版**を採用しています。これはシンプルで、小規模〜中規模のプロジェクトに適した戦略です。

## ブランチの種類

### 1. `main` ブランチ（本番）

- **役割**: プロジェクトの安定版、常にビルド可能な状態
- **保護**: 直接コミット禁止、PR 経由でのみマージ可能
- **リリース**: このブランチからリリースタグを打つ

**ルール**:

- ✅ 全テストが通過している
- ✅ レビューが完了している
- ✅ ドキュメントが更新されている
- ❌ WIP（作業中）コードは含まない

### 2. `feature/*` ブランチ（機能開発）

新機能の開発に使用します。

**命名規則**:

```
feature/<機能名>
```

**例**:

- `feature/parser-mysql` - MySQL パーサーの実装
- `feature/html-report` - HTML レポート機能
- `feature/real-time-profiling` - リアルタイムプロファイリング

**ライフサイクル**:

```bash
# 作成
git checkout main
git pull
git checkout -b feature/parser-mysql

# 開発
# ... コーディング ...

# mainと同期（定期的に）
git fetch origin
git rebase origin/main

# PR作成・マージ後
git checkout main
git pull
git branch -d feature/parser-mysql
```

### 3. `fix/*` ブランチ（バグ修正）

バグ修正に使用します。

**命名規則**:

```
fix/<バグの内容>
```

**例**:

- `fix/fingerprint-crash-on-empty` - 空クエリでのクラッシュ修正
- `fix/p99-calculation-error` - P99 計算のバグ修正

**優先度**: 緊急度が高い場合は優先的にレビュー・マージ

### 4. `docs/*` ブランチ（ドキュメント）

ドキュメントの更新に使用します。

**命名規則**:

```
docs/<ドキュメント名>
```

**例**:

- `docs/update-readme` - README の更新
- `docs/api-documentation` - API ドキュメント追加

**軽微な修正**: タイポ修正など軽微な変更は`main`に直接コミット可

### 5. `refactor/*` ブランチ（リファクタリング）

コードのリファクタリングに使用します。

**命名規則**:

```
refactor/<対象モジュール>
```

**例**:

- `refactor/stats-module` - Stats モジュールの最適化
- `refactor/extract-common-utils` - 共通ユーティリティの抽出

## ワークフロー詳細

### 1. 新機能開発の開始

```bash
# 最新のmainを取得
git checkout main
git pull origin main

# 機能ブランチを作成
git checkout -b feature/my-new-feature
```

### 2. 開発とコミット

```bash
# 変更をステージング
git add .

# コミット（Conventional Commitsに従う）
git commit -m "feat(parser): implement PostgreSQL log parser"
```

### 3. 定期的な main との同期

```bash
# mainの最新を取得
git fetch origin

# rebaseで同期（推奨）
git rebase origin/main

# または mergeで同期
git merge origin/main
```

### 4. PR 作成前の準備

```bash
# ビルド確認
dune build

# テスト実行
dune runtest

# フォーマット確認
dune build @fmt

# mainと最終同期
git fetch origin
git rebase origin/main
```

### 5. PR の作成

```bash
# GitHubにプッシュ
git push origin feature/my-new-feature

# GitHub上でPRを作成
# - 説明を記入
# - レビュアーを指定
# - ラベルを付与
```

### 6. レビュー・修正

```bash
# レビューコメントに対応
git add .
git commit -m "fix: address review comments"
git push origin feature/my-new-feature
```

### 7. マージ後のクリーンアップ

```bash
# ローカルのmainを更新
git checkout main
git pull origin main

# マージ済みブランチを削除
git branch -d feature/my-new-feature

# リモートブランチも削除（GitHub上で自動削除されない場合）
git push origin --delete feature/my-new-feature
```

## マージ戦略

### Squash and Merge（推奨）

PR の全コミットを 1 つにまとめてマージ。履歴がシンプルになります。

**使用ケース**:

- 機能開発（複数の WIP コミットがある場合）
- 小規模なバグ修正

### Rebase and Merge

PR のコミットを個別に保持しつつ、履歴を一直線にします。

**使用ケース**:

- コミットが既に整理されている場合
- 各コミットが意味のある単位である場合

### Merge Commit

マージコミットを作成します。

**使用ケース**:

- 大規模な機能ブランチ
- 履歴を保持したい場合

## CI/CD 連携

GitHub Actions で以下を自動実行：

- ✅ ビルド確認
- ✅ テスト実行
- ✅ フォーマットチェック
- ✅ Lint

PR がマージされる前に、これらが全て成功している必要があります。

## 将来の拡張: Release ブランチ

プロジェクトが成熟したら、リリース管理のために`release/*`ブランチを導入することを検討します。

```
main (開発最新)
├── release/v1.0 (安定版リリース)
├── release/v1.1
└── hotfix/v1.0.1 (緊急修正)
```

## ブランチ保護ルール

`main`ブランチには以下の保護ルールを設定することを推奨：

- ✅ レビュー必須（最低 1 名）
- ✅ CI 通過必須
- ✅ 最新の main との同期必須
- ✅ 直接プッシュ禁止
- ✅ 履歴の書き換え禁止

## トラブルシューティング

### コンフリクトが発生した場合

```bash
# rebase中のコンフリクト
git rebase origin/main
# コンフリクトを解決
git add .
git rebase --continue

# merge中のコンフリクト
git merge origin/main
# コンフリクトを解決
git add .
git commit
```

### 誤って main に直接コミットした場合

```bash
# コミットを取り消し
git reset --soft HEAD~1

# 機能ブランチを作成
git checkout -b feature/accidentally-committed

# プッシュ
git push origin feature/accidentally-committed
```

## 参考資料

- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Branching Model](https://nvie.com/posts/a-successful-git-branching-model/)
