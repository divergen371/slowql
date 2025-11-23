# Git Workflow ガイド

SlowQL プロジェクトにおける日常的な Git 操作のガイドです。

## 目次

1. [基本的な開発フロー](#基本的な開発フロー)
2. [Git Worktree（AI 駆動開発）](#git-worktreeai駆動開発)
3. [よくある操作](#よくある操作)
4. [トラブルシューティング](#トラブルシューティング)
5. [ベストプラクティス](#ベストプラクティス)

## 基本的な開発フロー

### 1. 初回セットアップ

```bash
# リポジトリをフォーク（GitHubで「Fork」ボタンをクリック）

# フォークしたリポジトリをクローン
git clone https://github.com/YOUR_USERNAME/slowql.git
cd slowql

# オリジナルリポジトリをupstreamとして追加
git remote add upstream https://github.com/ORIGINAL_OWNER/slowql.git

# 確認
git remote -v
# origin    https://github.com/YOUR_USERNAME/slowql.git (fetch)
# origin    https://github.com/YOUR_USERNAME/slowql.git (push)
# upstream  https://github.com/ORIGINAL_OWNER/slowql.git (fetch)
# upstream  https://github.com/ORIGINAL_OWNER/slowql.git (push)
```

### 2. 新機能の開発

```bash
# 最新のmainを取得
git checkout main
git pull upstream main

# 機能ブランチを作成
git checkout -b feature/parser-mysql

# 開発作業
# ... ファイル編集 ...

# 変更を確認
git status
git diff

# 変更をステージング
git add src/parser_mysql.ml
# または全ての変更をステージング
git add .

# コミット
git commit -m "feat(parser): implement MySQL log parser

- Add header line parsing
- Extract Query_time and Lock_time
- Support multi-line queries"

# 追加の変更
# ... さらに編集 ...
git add .
git commit -m "feat(parser): add error handling for malformed logs"
```

### 3. upstream と同期

```bash
# upstreamの最新を取得
git fetch upstream

# 現在のブランチをupstream/mainでrebase
git rebase upstream/main

# コンフリクトがあれば解決
# ... ファイル編集 ...
git add .
git rebase --continue
```

### 4. プッシュと PR 作成

```bash
# 自分のforkにプッシュ
git push origin feature/parser-mysql

# 初回プッシュ時にupstreamを設定する場合
git push -u origin feature/parser-mysql

# GitHub上でPRを作成
# 1. GitHubのリポジトリページを開く
# 2. "Compare & pull request" ボタンをクリック
# 3. PRのタイトルと説明を記入
# 4. "Create pull request" をクリック
```

### 5. レビュー対応

```bash
# レビューコメントを反映
# ... ファイル編集 ...

git add .
git commit -m "fix: address review comments

- Improve error messages
- Add unit tests
- Fix edge case handling"

git push origin feature/parser-mysql
```

### 6. マージ後のクリーンアップ

```bash
# mainブランチに戻る
git checkout main

# upstream/mainから最新を取得
git pull upstream main

# 自分のfork（origin）も更新
git push origin main

# マージ済みのローカルブランチを削除
git branch -d feature/parser-mysql

# リモートブランチも削除（必要に応じて）
git push origin --delete feature/parser-mysql
```

## Git Worktree（AI 駆動開発）

**Git worktree**は、AI 駆動開発において特に重要なツールです。複数のブランチで並行作業が可能になり、開発効率が大幅に向上します。

### なぜ AI 駆動開発に必須なのか

#### 1. 複数の AI 提案を並行評価

AI が複数の異なるアプローチを提案した場合、それぞれを別の worktree で実装・比較できます。

```bash
# 提案1: 正規表現ベースのパーサー
git worktree add ../slowql-regex feature/parser-regex

# 提案2: パーサーコンビネータベース
git worktree add ../slowql-combinator feature/parser-combinator

# 両方を実装して性能比較
cd ../slowql-regex && dune build && time ./slowql test.log
cd ../slowql-combinator && dune build && time ./slowql test.log
```

#### 2. ビルド状態の保持

ブランチを切り替えると`_build`ディレクトリが無効になりますが、worktree なら各ディレクトリで独立してビルド済み状態を保持できます。

**従来の方法（遅い）**:

```bash
git checkout feature-a
dune build          # 再ビルド（遅い）
git checkout feature-b
dune build          # また再ビルド（遅い）
```

**worktree を使用（速い）**:

```bash
cd ~/slowql-feature-a
dune build          # 一度だけビルド

cd ~/slowql-feature-b
dune build          # 一度だけビルド

# 以降は切り替えてもビルド済み状態を維持
```

#### 3. IDE で複数ウィンドウ

VSCode や Emacs/Vim で、複数の worktree を別ウィンドウで開いて並行開発できます。

```bash
# VSCodeで3つのworktreeを同時に開く
code ~/slowql              # main
code ~/slowql-parser       # feature/parser-mysql
code ~/slowql-report       # feature/html-report
```

#### 4. 実装の比較とテスト

新旧実装を並べて比較・デバッグできます。

```bash
# 古い実装と新しい実装で出力を比較
diff <(~/slowql-old/slowql test.log) \
     <(~/slowql-new/slowql test.log)

# 両方を同時実行してベンチマーク
hyperfine \
  '~/slowql-old/slowql test.log' \
  '~/slowql-new/slowql test.log'
```

### 基本的な使い方

#### worktree の作成

```bash
# 既存のブランチ用のworktreeを作成
git worktree add ../slowql-parser feature/parser-mysql

# 新しいブランチを作成しつつworktreeを追加
git worktree add -b feature/new-feature ../slowql-new

# mainブランチ用のworktreeを作成（読み取り専用参照用）
git worktree add ../slowql-main main
```

#### worktree 一覧の表示

```bash
git worktree list

# 出力例:
# /Users/you/slowql              abc1234 [main]
# /Users/you/slowql-parser       def5678 [feature/parser-mysql]
# /Users/you/slowql-report       ghi9012 [feature/html-report]
```

#### worktree での作業

```bash
# worktreeに移動
cd ../slowql-parser

# 通常通りgit操作
git status
git add .
git commit -m "feat(parser): implement MySQL parser"
git push origin feature/parser-mysql

# 元のディレクトリでも変更が反映される
cd ~/slowql
git fetch
git log feature/parser-mysql
```

#### worktree の削除

```bash
# worktreeを削除（ブランチは削除されない）
git worktree remove ../slowql-parser

# 強制削除（未コミットの変更があっても）
git worktree remove --force ../slowql-parser

# ブランチも一緒に削除したい場合
git worktree remove ../slowql-parser
git branch -d feature/parser-mysql
```

### AI 駆動開発でのワークフロー

#### パターン 1: 複数機能の並行開発

```bash
# プロジェクトルート
~/slowql/                    # main (参照用)

# 各機能ごとにworktree
~/slowql-parser-mysql/       # feature/parser-mysql
~/slowql-parser-postgres/    # feature/parser-postgres
~/slowql-html-report/        # feature/html-report

# 各ディレクトリで独立して開発
cd ~/slowql-parser-mysql && code . &
cd ~/slowql-parser-postgres && code . &
cd ~/slowql-html-report && code . &
```

#### パターン 2: 実験的実装の比較

```bash
# ベースライン
~/slowql/                    # main

# 3つの異なるアプローチを試す
~/slowql-approach-a/         # feature/stats-simple
~/slowql-approach-b/         # feature/stats-streaming
~/slowql-approach-c/         # feature/stats-parallel

# ベンチマーク
for dir in ~/slowql-approach-*/; do
  echo "Testing $dir"
  cd "$dir"
  dune build
  time ./slowql large.log
done
```

#### パターン 3: バグ修正と機能開発の並行

```bash
# メイン開発
~/slowql/                    # main
~/slowql-feature/            # feature/new-analytics

# 緊急バグ修正
~/slowql-hotfix/             # fix/critical-crash

# 機能開発中に緊急バグ報告が来ても、worktreeですぐ対応
cd ~/slowql-hotfix
git checkout -b fix/critical-crash
# バグ修正...
git push origin fix/critical-crash
# 機能開発に戻る
cd ~/slowql-feature
```

### ディレクトリ構成の推奨

```bash
# プロジェクトグループ化
~/projects/slowql/
  ├── main/              # メインworktree (main)
  ├── dev/               # 開発用worktree
  │   ├── parser/        # feature/parser-*
  │   ├── report/        # feature/report-*
  │   └── stats/         # feature/stats-*
  └── fix/               # バグ修正用
      └── issue-123/     # fix/issue-123
```

セットアップ:

```bash
mkdir -p ~/projects/slowql/{main,dev,fix}
cd ~/projects/slowql
git clone https://github.com/username/slowql.git main
cd main

git worktree add ../dev/parser feature/parser-mysql
git worktree add ../dev/report feature/html-report
git worktree add ../fix/issue-123 fix/issue-123
```

### トラブルシューティング

#### worktree が削除できない

```bash
# エラー: worktree contains modified or untracked files

# 未コミットの変更を確認
cd ../slowql-parser
git status

# 変更を保存してから削除
git stash
cd ~/slowql
git worktree remove ../slowql-parser

# または強制削除
git worktree remove --force ../slowql-parser
```

#### ブランチが複数の worktree でチェックアウトされている

```bash
# エラー: 'feature/parser-mysql' is already checked out at ...

# 同じブランチを複数のworktreeで開くことはできない
# 解決策1: 片方のworktreeでブランチを切り替える
cd ../slowql-parser-old
git checkout main

# 解決策2: 新しいブランチを作成
cd ../slowql-parser-new
git checkout -b feature/parser-mysql-v2
```

#### 削除した worktree のゴミが残っている

```bash
# worktreeディレクトリを手動削除してしまった場合

# 残骸を確認
git worktree list
# /path/to/deleted/worktree  abc1234 [feature/branch] (error: missing)

# 残骸を削除
git worktree prune

# または個別に削除
git worktree remove /path/to/deleted/worktree
```

### パフォーマンスへの影響

**メリット**:

- ✅ ブランチ切り替え時の`_build`再構築が不要
- ✅ 並行ビルド・テストが可能
- ✅ IDE のインデックス再構築が不要

**注意点**:

- ⚠️ 各 worktree でディスク容量を消費（`_build`は特に大きい）
- ⚠️ 同じファイルを複数 worktree で編集すると混乱の原因に

**ディスク使用量の目安（slowql の場合）**:

```
main/           : 50MB  (ソース + .git)
worktree-1/     : 100MB (ソース + _build)
worktree-2/     : 100MB (ソース + _build)
```

### VSCode 設定

`.vscode/settings.json`に追加:

```json
{
  "files.watcherExclude": {
    "**/.git/worktrees/**": true
  }
}
```

### おすすめの Git エイリアス

`~/.gitconfig`に追加:

```gitconfig
[alias]
  # worktree一覧を見やすく表示
  wt = worktree list

  # 新しいworktreeを作成（ブランチ名から自動でパス生成）
  wta = "!f() { git worktree add ../${1##*/} $1; }; f"

  # worktreeを削除してブランチも削除
  wtrm = "!f() { git worktree remove $1 && git branch -d ${1##*/}; }; f"
```

使用例:

```bash
git wt                              # worktree一覧
git wta feature/parser-mysql        # ../parser-mysql に作成
git wtrm ../parser-mysql            # worktreeとブランチを削除
```

## よくある操作

### コミットの修正

#### 直前のコミットメッセージを修正

```bash
git commit --amend -m "新しいコミットメッセージ"
```

#### 直前のコミットにファイルを追加

```bash
git add forgotten_file.ml
git commit --amend --no-edit
```

### 複数のコミットを 1 つにまとめる

```bash
# 過去3つのコミットをまとめる
git rebase -i HEAD~3

# エディタが開くので、2番目以降を "pick" から "squash" に変更
# pick abc1234 First commit
# squash def5678 Second commit
# squash ghi9012 Third commit

# 保存して終了すると、新しいコミットメッセージを編集できる
```

### 変更を一時的に退避

```bash
# 変更を退避
git stash

# 他の作業...
git checkout main
git pull

# 退避した変更を戻す
git checkout feature/my-feature
git stash pop
```

### ブランチ名の変更

```bash
# ローカルブランチ名を変更
git branch -m old-name new-name

# リモートの古いブランチを削除
git push origin --delete old-name

# 新しい名前でプッシュ
git push -u origin new-name
```

## トラブルシューティング

### コンフリクトの解決

```bash
# rebase中にコンフリクトが発生
git rebase upstream/main

# コンフリクトしているファイルを確認
git status

# ファイルを編集してコンフリクトを解決
# <<<<<<< HEAD
# =======
# >>>>>>> の部分を修正

# 解決したファイルをステージング
git add resolved_file.ml

# rebaseを続行
git rebase --continue

# rebaseを中断する場合
git rebase --abort
```

### 誤って間違ったブランチにコミットした場合

```bash
# コミットを取り消し（変更は保持）
git reset --soft HEAD~1

# 正しいブランチに切り替え
git checkout correct-branch

# コミット
git commit -m "正しいメッセージ"
```

### プッシュ済みのコミットを削除したい

```bash
# ⚠️ 他の人と共有しているブランチでは使用しないこと！

# 最後のコミットを削除
git reset --hard HEAD~1

# 強制プッシュ
git push -f origin feature-branch
```

### 他の人の変更を取り込みたい

```bash
# 機能ブランチで作業中

# 最新のmainを取得
git fetch upstream

# mainの変更を取り込む（mergeの場合）
git merge upstream/main

# または rebaseの場合（履歴が綺麗）
git rebase upstream/main
```

## ベストプラクティス

### コミットの粒度

✅ **良い例**:

```bash
git commit -m "feat(parser): add MySQL header parsing"
git commit -m "test(parser): add unit tests for MySQL parser"
git commit -m "docs(parser): update parser documentation"
```

❌ **悪い例**:

```bash
git commit -m "WIP"
git commit -m "fix stuff"
git commit -m "update everything"
```

### コミット前のチェック

```bash
# ビルドの確認
dune build

# テストの実行
dune runtest

# フォーマットのチェック
dune build @fmt
```

### .gitignore の活用

不要なファイルをコミットしないようにする：

```gitignore
_build/
*.install
*.merlin
*.swp
.DS_Store
```

### タグの使用

```bash
# リリースタグを作成
git tag -a v1.0.0 -m "Release version 1.0.0"

# タグをプッシュ
git push upstream v1.0.0

# 全てのタグをプッシュ
git push upstream --tags
```

### クリーンな履歴の維持

```bash
# コミット前に変更を確認
git diff

# ステージング前に変更を確認
git diff --staged

# コミット履歴を確認
git log --oneline --graph --decorate

# 特定のファイルの変更履歴を確認
git log --follow src/parser_mysql.ml
```

## Git エイリアスの設定（推奨）

`~/.gitconfig` に以下を追加：

```gitconfig
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  unstage = reset HEAD --
  last = log -1 HEAD
  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
  sync = !git fetch upstream && git rebase upstream/main
```

使用例：

```bash
git co main        # git checkout main
git st             # git status
git lg             # きれいなログ表示
git sync           # upstreamと同期
```

## 参考資料

- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
