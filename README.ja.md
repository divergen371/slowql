# SlowQL

日本語 | [English](README.md)

![CI](https://github.com/divergen371/slowql/workflows/CI/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![OCaml](https://img.shields.io/badge/OCaml-5.2+-orange.svg)

MySQL と PostgreSQL 向けの高性能スロークエリログ解析ツール（OCaml 製）

## 概要

SlowQL は、MySQL および PostgreSQL のスロークエリログを解析し、SQL 文を正規化（フィンガープリント化）して統計レポートを JSON・CSV 形式で出力するコマンドラインツールです。データベース管理者や開発者がパフォーマンスのボトルネックを特定し、クエリを最適化するのに役立ちます。

## 機能

### 現在（MVP）

- **複数データベース対応**: MySQL スロークエリログと PostgreSQL ログをサポート
- **SQL フィンガープリント**: リテラルをプレースホルダーに置換してクエリを正規化
- **統計分析**: 実行回数、合計時間、平均、最大値、パーセンタイル（P50, P95, P99）を計算
- **複数の出力形式**: JSON および CSV レポート
- **Gzip 対応**: プレーンテキストと gzip 圧縮されたログの両方を読み込み可能

### 予定されている機能

- **時間範囲フィルタリング**: 日時範囲でログをフィルタ（`--since`, `--until`）
- **HTML レポート**: グラフやヒストグラムを含むリッチなビジュアルレポート
- **EXPLAIN 統合**: スロークエリに対して自動的に EXPLAIN を実行
- **インタラクティブ TUI**: 結果を探索するためのターミナル UI
- **匿名化**: 共有用にテーブル名・カラム名をマスク
- **Markdown レポート**: GitHub 対応のレポート形式

## インストール

### 前提条件

- OCaml 4.14 以降
- opam（OCaml パッケージマネージャー）
- dune（ビルドシステム）

### 依存ライブラリのインストール

```bash
opam install . --deps-only
```

### ビルド

```bash
dune build
```

### テスト実行

```bash
dune runtest
```

## 使い方

```bash
dune exec -- slowql [オプション] <ログファイル...>
```

### オプション

- `--db <タイプ>`: データベースタイプ（`auto`, `mysql`, `postgres`）。デフォルト: `auto`
- `--top <N>`: 合計時間上位 N 件のクエリを表示。デフォルト: `20`
- `--json <パス>`: JSON 出力パス。デフォルト: `slowql.json`
- `--csv <パス>`: CSV 出力パス。デフォルト: `slowql.csv`

### 使用例

```bash
# PostgreSQLログを解析
dune exec -- slowql --db postgres my_slow_dummy.log

# MySQLログをカスタム出力パスで解析
dune exec -- slowql --db mysql --json report.json --csv report.csv mysql-slow.log

# gzip圧縮されたログを解析
dune exec -- slowql --db postgres slow.log.gz
```

## 出力形式

### JSON

```json
[
  {
    "fingerprint": "select * from users where id = ?",
    "example": "SELECT * FROM users WHERE id = 12345",
    "count": 150,
    "total": 1250.5,
    "avg": 8.34,
    "max": 45.2,
    "p50": 7.1,
    "p95": 20.3,
    "p99": 35.8
  }
]
```

### CSV

```
fingerprint,example,count,total,avg,max,p50,p95,p99
"select * from users where id = ?","SELECT * FROM users WHERE id = 12345",150,1250.5,8.34,45.2,7.1,20.3,35.8
```

## 開発状況

本プロジェクトは現在**MVP（Minimum Viable Product）**フェーズです。

- ✅ コアのフィンガープリントロジック
- ✅ 統計計算（パーセンタイル、平均など）
- ✅ Alcotest による単体テスト
- 🚧 MySQL/PostgreSQL ログパーサー（実装中）
- 🚧 CLI 統合（実装中）
- 🚧 レポート生成（実装中）

詳細な進捗状況は [docs/slowql_mvp/task.md](docs/slowql_mvp/task.md) をご覧ください。

## プロジェクト構成

```
slowql/
├── bin/           # CLIエントリーポイント
├── src/           # コアライブラリ
│   ├── fingerprint.ml   # SQL正規化
│   ├── stats.ml         # 統計計算
│   ├── parser_mysql.ml  # MySQLログパーサー
│   ├── parser_pg.ml     # PostgreSQLログパーサー
│   └── report.ml        # レポート生成
├── test/          # 単体テスト
└── docs/          # ドキュメント
    └── slowql_mvp/
        ├── implementation_plan.md
        ├── feature_ideas.md
        └── test_plan.md
```

## 依存ライブラリ

### コア

- `re`: パースとフィンガープリント用の正規表現
- `yojson`: JSON 出力生成

### 拡張機能用（将来の実装）

- `caqti`, `caqti-lwt`: EXPLAIN 統合のためのデータベース接続
- `cohttp-lwt-unix`: WebUI 用 HTTP サーバー
- `logs`: 構造化ロギング
- `ptime`: 時刻・日付のパースとフィルタリング
- `tyxml`: HTML レポート生成
- `digestif`: 匿名化のためのハッシュ化
- `notty`: ターミナル UI

## ライセンス

MIT License

## 作者

Ishikawa

## 謝辞

`pt-query-digest`や`pgBadger`などのツールからインスピレーションを得ています。
