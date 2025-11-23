# GitHub Actions ガイド

SlowQL プロジェクトの CI/CD（継続的インテグレーション/継続的デリバリー）について説明します。

## 目次

1. [概要](#概要)
2. [CI ワークフロー](#ci-ワークフロー)
3. [リリースワークフロー](#リリースワークフロー)
4. [ローカルでの検証](#ローカルでの検証)
5. [トラブルシューティング](#トラブルシューティング)

## 概要

GitHub Actions を使用して、以下を自動化しています：

- **CI（継続的インテグレーション）**

  - コードのビルド
  - テストの実行
  - フォーマットチェック
  - Lint

- **リリース（継続的デリバリー）**
  - バイナリのビルド
  - リリースパッケージの作成
  - GitHub リリースの公開

## CI ワークフロー

### トリガー条件

CI は以下の場合に自動実行されます：

1. `main`ブランチへのプッシュ
2. `main`ブランチへの PR 作成・更新

### ワークフローの内容

#### 1. Build and Test ジョブ

```yaml
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Set up OCaml 4.14.x
      - Install dependencies
      - Build
      - Run tests
      - Check formatting
```

**実行内容**:

- OCaml 4.14.x の環境構築
- `opam install . --deps-only --with-test` で依存関係をインストール
- `dune build` でプロジェクトをビルド
- `dune runtest` でテストを実行
- `dune build @fmt` でフォーマットをチェック

#### 2. Lint ジョブ

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Set up OCaml
      - Install OCaml tools
      - Run ocamlformat check
```

**実行内容**:

- `ocamlformat`、`ocamllint`をインストール
- コードのフォーマットをチェック

### PR 時の動作

PR を作成すると、以下のチェックが自動実行されます：

![GitHub Actions Status](https://img.shields.io/github/actions/workflow/status/username/slowql/ci.yml?branch=main)

**チェック項目**:

- ✅ ビルドが成功する
- ✅ 全てのテストが通過する
- ✅ コードが正しくフォーマットされている

**マージ条件**:

- 全てのチェックが成功している
- 最低 1 名のレビュアーが承認している

### ステータスバッジ

README.md にステータスバッジを追加：

```markdown
![CI](https://github.com/username/slowql/workflows/CI/badge.svg)
```

## リリースワークフロー

### トリガー条件

`v*.*.*`形式のタグをプッシュすると、リリースワークフローが実行されます。

```bash
# リリースタグを作成
git tag -a v1.0.0 -m "Release version 1.0.0"

# タグをプッシュ
git push origin v1.0.0
```

### ワークフローの内容

```yaml
jobs:
  create-release:
    steps:
      - Build release binary
      - Create release archive
      - Create GitHub Release
```

**実行内容**:

1. リリース版バイナリをビルド（`--release`フラグ付き）
2. tar.gz アーカイブを作成
3. GitHub リリースを作成し、アーカイブを添付

### リリース成果物

リリースには以下が含まれます：

- `slowql-v1.0.0-linux-x64.tar.gz` - Linux 用バイナリ

### リリースプロセス

1. **バージョン番号の決定**

   - セマンティックバージョニング（SemVer）に従う
   - `MAJOR.MINOR.PATCH` (例: `1.2.3`)

2. **CHANGELOG の更新**

   ```bash
   # CHANGELOG.mdを編集
   vim CHANGELOG.md
   git add CHANGELOG.md
   git commit -m "docs: update CHANGELOG for v1.0.0"
   ```

3. **タグの作成とプッシュ**

   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

4. **GitHub Actions の確認**

   - https://github.com/username/slowql/actions
   - リリースワークフローが成功したことを確認

5. **リリースノートの編集**
   - GitHub のリリースページで説明を追加
   - 主な変更点を記載

## ローカルでの検証

### CI と同じ環境でテスト

GitHub Actions で実行されるコマンドをローカルで実行：

```bash
# ビルド
opam exec -- dune build

# テスト
opam exec -- dune runtest

# フォーマットチェック
opam exec -- dune build @fmt

# フォーマット自動修正
opam exec -- dune build @fmt --auto-promote
```

### act を使用したローカル実行

[act](https://github.com/nektos/act)を使うと、GitHub Actions をローカルで実行できます：

```bash
# actのインストール（macOS）
brew install act

# CIワークフローをローカルで実行
act pull_request

# 特定のジョブだけ実行
act -j build-and-test
```

## トラブルシューティング

### CI が失敗する場合

#### 1. ビルドエラー

```
Error: Unbound module Foo
```

**対処法**:

- ローカルで `dune build` を実行して同じエラーを再現
- 依存関係が正しく設定されているか確認
- `.opam` ファイルを再生成: `dune build`

#### 2. テスト失敗

```
Test "my_test" failed
```

**対処法**:

- ローカルで `dune runtest` を実行
- 失敗したテストを確認
- テストを修正してコミット

#### 3. フォーマットエラー

```
Error: Files are not formatted
```

**対処法**:

```bash
# フォーマットを自動修正
dune build @fmt --auto-promote

# 変更をコミット
git add .
git commit -m "style: apply ocamlformat"
git push
```

### ワークフローが実行されない

**確認事項**:

1. `.github/workflows/` ディレクトリが存在するか
2. YAML ファイルの構文が正しいか
3. トリガー条件が満たされているか

**デバッグ方法**:

```bash
# ワークフローファイルの構文チェック
yamllint .github/workflows/ci.yml
```

### リリースワークフローが失敗

**よくある原因**:

1. タグの形式が間違っている（`v*.*.*`でない）
2. ビルドエラー
3. GitHub Token の権限不足

**対処法**:

```bash
# タグを削除して再作成
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# 正しい形式で再作成
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## ワークフローのカスタマイズ

### 追加のチェックを実行

`.github/workflows/ci.yml`に追加：

```yaml
- name: Run additional checks
  run: |
    opam exec -- dune build @check
```

### 複数の OCaml バージョンでテスト

```yaml
strategy:
  matrix:
    ocaml-version: ["4.14", "5.0"]

steps:
  - name: Set up OCaml
    uses: ocaml/setup-ocaml@v2
    with:
      ocaml-compiler: ${{ matrix.ocaml-version }}
```

### キャッシュの利用

ビルド時間を短縮するために、依存関係をキャッシュ：

```yaml
- name: Cache opam
  uses: actions/cache@v3
  with:
    path: ~/.opam
    key: ${{ runner.os }}-opam-${{ hashFiles('*.opam') }}
```

## セキュリティ

### シークレットの使用

機密情報は GitHub Secrets に保存：

1. リポジトリの Settings → Secrets and variables → Actions
2. "New repository secret" をクリック
3. シークレットを追加

ワークフローで使用：

```yaml
env:
  MY_SECRET: ${{ secrets.MY_SECRET }}
```

### セキュリティのベストプラクティス

- ✅ シークレットをコードにハードコードしない
- ✅ 最小限の権限を使用
- ✅ サードパーティアクションのバージョンを固定

## 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [OCaml Setup Action](https://github.com/ocaml/setup-ocaml)
- [Semantic Versioning](https://semver.org/)
