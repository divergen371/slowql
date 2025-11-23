# コントリビューションガイド

SlowQL へのコントリビューションをありがとうございます！このドキュメントでは、プロジェクトへの貢献方法について説明します。

## 開発環境のセットアップ

### 必要なツール

- OCaml 4.14 以降
- opam（OCaml パッケージマネージャー）
- dune（ビルドシステム）
- Git

### セットアップ手順

```bash
# リポジトリのクローン
git clone https://github.com/[username]/slowql.git
cd slowql

# 依存関係のインストール
opam install . --deps-only

# ビルド
dune build

# テスト実行
dune runtest
```

## ブランチ戦略

SlowQL は**GitHub Flow 変形版**を採用しています。詳細は [docs/BRANCHING_STRATEGY.md](docs/BRANCHING_STRATEGY.md) を参照してください。

### ブランチの種類

- **`main`**: 本番ブランチ（常にビルド可能な状態）
- **`feature/*`**: 新機能開発
- **`fix/*`**: バグ修正
- **`docs/*`**: ドキュメント更新
- **`refactor/*`**: リファクタリング

### 基本ワークフロー

```bash
# 1. mainから機能ブランチを作成
git checkout main
git pull
git checkout -b feature/your-feature-name

# 2. 開発・コミット
git add .
git commit -m "feat: add your feature"

# 3. mainと同期
git checkout main
git pull
git checkout feature/your-feature-name
git rebase main

# 4. プッシュ & PR作成
git push origin feature/your-feature-name
```

## コミットメッセージ規約

[Conventional Commits](https://www.conventionalcommits.org/) に従ってください。

### フォーマット

```
<type>(<scope>): <subject>

<body>

<footer>
```

### タイプ

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `test`: テスト追加・修正
- `refactor`: リファクタリング
- `perf`: パフォーマンス改善
- `chore`: ビルド・設定変更

### 例

```
feat(parser): add MySQL slow query log parser

- Implement header line parsing
- Extract Query_time, Lock_time metrics
- Handle multi-line queries

Closes #123
```

## Pull Request プロセス

### PR 作成前のチェックリスト

- [ ] `dune build` が成功する
- [ ] `dune runtest` が全て通過する
- [ ] コードが適切にフォーマットされている（`ocamlformat`）
- [ ] 新機能にはテストが追加されている
- [ ] ドキュメントが更新されている（該当する場合）

### PR 作成

1. GitHub で PR を作成
2. テンプレートに従って説明を記入
3. レビュアーを指定（optional）
4. CI が通過するのを待つ

### レビュープロセス

- 最低 1 名のレビュアーの承認が必要
- レビューコメントに対応
- 必要に応じてコミットを追加
- 承認後、メンテナーがマージ

## コーディング規約

### OCaml スタイル

- `.ocamlformat` の設定に従う
- モジュール名は大文字始まりのキャメルケース（`MyModule`）
- 関数名は小文字始まりのスネークケース（`parse_log_entry`）
- 型名は小文字のスネークケース（`query_record`）

### ファイル構成

```
slowql/
├── src/           # ライブラリコード
├── bin/           # CLIエントリーポイント
├── test/          # テストコード
└── docs/          # ドキュメント
```

## テスト

### 単体テスト

`test/main.ml` に `alcotest` を使用したテストを追加してください。

```ocaml
let test_my_feature () =
  let input = "test input" in
  let expected = "expected output" in
  check string "test description" expected (my_function input)
```

### 統合テスト

実際のログファイルを使用したエンドツーエンドテストを追加してください。

## 質問・サポート

- GitHub Issues: バグ報告・機能リクエスト
- GitHub Discussions: 質問・議論

## ライセンス

このプロジェクトへのコントリビューションは、MIT ライセンスの下で提供されます。
