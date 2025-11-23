# Git Workflow ガイド

SlowQL プロジェクトにおける日常的な Git 操作のガイドです。

## 目次

1. [基本的な開発フロー](#基本的な開発フロー)
2. [よくある操作](#よくある操作)
3. [トラブルシューティング](#トラブルシューティング)
4. [ベストプラクティス](#ベストプラクティス)

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
