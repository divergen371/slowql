# 実装計画: SlowQL MVP

## ゴール

MySQL および PostgreSQL のスロークエリログを解析し、正規化（Fingerprint）した上で統計情報（実行時間、行数など）を集計し、JSON/CSV 形式で出力する CLI ツールを実装する。

## ユーザーレビューが必要な事項

> [!IMPORTANT] > **Gzip 対応について**: 外部ライブラリ `camlzip` を使用せず、システムにインストールされている `gzip` コマンドを `Unix.open_process_in` 経由で呼び出す方式を提案します。これにより、ビルド時の C ライブラリ依存トラブルを回避できます。

> [!NOTE] > **CLI 引数**: ユーザー要望に合わせて `--in` オプションを追加し、入力ファイルを明示的に指定できるように変更します。

## 提案する変更

### 依存関係の追加

`dune-project` および `slowql.opam` に以下のライブラリを追加します。

- `re`: 正規表現処理（ログパース、Fingerprint 生成）
- `yojson`: JSON 出力

### [src] コアロジックの実装

#### [NEW] [fingerprint.ml](file:///Users/atsushi/OCaml/slowql/slowql/src/fingerprint.ml)

- SQL からリテラル（数値、引用符付き文字列）を除去し、正規化するロジックを実装。
- コメント除去、空白の正規化。

#### [NEW] [parser_mysql.ml](file:///Users/atsushi/OCaml/slowql/slowql/src/parser_mysql.ml)

- MySQL スロークエリログのパース処理。
- `Time`, `Lock_time`, `Rows_sent`, `Rows_examined` ヘッダー行と SQL 文の抽出。

#### [NEW] [parser_pg.ml](file:///Users/atsushi/OCaml/slowql/slowql/src/parser_pg.ml)

- PostgreSQL ログのパース処理。
- `duration: ... ms` および `statement: ...` の抽出。

#### [MODIFY] [stats.ml](file:///Users/atsushi/OCaml/slowql/slowql/src/stats.ml)

- 集計用データ構造（`Entry`）の定義。
- `add` 関数: ログエントリを蓄積。
- `compute` 関数: パーセンタイル（p50, p95, p99）、平均、最大値などを計算。

#### [MODIFY] [report.ml](file:///Users/atsushi/OCaml/slowql/slowql/src/report.ml)

- `Stats` モジュールの集計結果を受け取り、JSON/CSV 形式でファイルに出力する機能の実装。

### [bin] CLI の実装

#### [MODIFY] [slowql.ml](file:///Users/atsushi/OCaml/slowql/slowql/bin/slowql.ml)

- `Cmdliner` の定義を更新。
- `--in` オプションの追加。
- ファイル拡張子（`.gz`）に応じた読み込み処理（`gzip -dc` コマンド利用）。
- 各モジュール（Parser -> Fingerprint -> Stats -> Report）の結合。

## 検証計画

### 自動テスト

- 現状はテストフレームワークが未設定のため、手動検証を主とします。

### 手動検証

1. **PostgreSQL**: 作成済みの `my_slow_dummy.log` を使用してパースと集計が正しく行われるか確認。
2. **MySQL**: ダミーの MySQL スロークエリログを作成し、同様に検証。
3. **Gzip**: ログファイルを gzip 圧縮し、読み込めるか確認。
4. **出力**: 生成された JSON/CSV を開き、期待通りのフィールドと値が含まれているか確認。
