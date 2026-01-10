# SlowQL MVP Implementation Tasks

## Project Setup
- [x] Add dependencies (`re`, `yojson`, `caqti`, `cohttp`, `logs`, etc.) to `dune-project` and `slowql.opam`
- [x] Update `dune` files
- [x] Create test infrastructure with `alcotest`

## Core Logic Implementation
- [x] Implement `Fingerprint` module (SQL normalization with lowercase, number/string replacement)
- [x] Implement `Stats` module (P1, P50, P95, P99, Min, Max, Avg, STD)
  - [x] Define `row` type with all statistical fields
  - [x] Implement `compute_stats` function
  - [x] Calculate percentiles (P1, P50, P95, P99)
  - [x] Calculate standard deviation (STD)
- [x] Create skeleton for `Parser_mysql` module (only function signature)
- [x] Create skeleton for `Parser_pg` module (only function signature)
- [ ] Implement `Parser_mysql` module (full implementation)
  - [ ] Parse MySQL slow query log header lines (Query_time, Lock_time, Rows_sent, Rows_examined)
  - [ ] Extract SQL statements from MySQL logs
  - [ ] Handle multi-line queries
- [ ] Implement `Parser_pg` module (full implementation)
  - [ ] Parse PostgreSQL log format (duration, statement)
  - [ ] Extract user, database, host information
  - [ ] Handle multi-line queries
- [ ] Implement `Log_reader` module
  - [ ] Read plain text log files
  - [ ] Handle gzip-compressed files (via `gzip -dc` command)
  - [ ] Auto-detect file format

## Aggregation & Statistics
- [ ] Implement aggregation logic in `Stats` or separate `Aggregator` module
  - [ ] Group queries by fingerprint
  - [ ] Collect timing data for each fingerprint
  - [ ] Store example query for each fingerprint
  - [ ] Compute statistics using `compute_stats` function
  - [ ] Return list of `Stats.row`
- [ ] Add support for tracking query context (user, database, session ID - future)

## Reporting
- [x] Create skeleton for `Report` module
  - [x] `to_json_file` function signature (currently outputs empty array)
  - [x] `to_csv_file` function signature (currently outputs header only)
- [ ] Implement full JSON output in `Report` module
  - [ ] Format stats as JSON array using Yojson
  - [ ] Include all statistical metrics (count, total, min, avg, max, p1, p50, p95, p99, std)
  - [ ] Write to specified file path
- [ ] Implement full CSV output in `Report` module
  - [ ] Format stats as CSV with header row
  - [ ] Include all statistical metrics (min, p1, std are missing from current header)
  - [ ] Write data rows to file

## CLI & Integration
- [x] Create basic CLI structure with `Cmdliner`
  - [x] Add `--db` option (auto, mysql, postgres)
  - [x] Add positional `FILES` argument (multiple files supported)
  - [x] Add `--top` option for top-N queries
  - [x] Add `--json` option for JSON output path
  - [x] Add `--csv` option for CSV output path
- [ ] Update `bin/slowql.ml` CLI implementation
  - [ ] Add `--in` option for explicit input file specification (currently uses positional arguments)
  - [ ] Implement `--db` auto-detection based on file content/extension
  - [ ] Wire Parser -> Fingerprint -> Stats -> Report pipeline (currently just prints arguments)
- [ ] Implement main execution flow
  - [ ] Read log files (with gzip support via `gzip -dc`)
  - [ ] Parse logs based on detected/specified DB type
  - [ ] Aggregate statistics by calling fingerprint and stats modules
  - [ ] Generate reports by calling report module with data

## Testing

### Test Data Preparation
- [x] Create `my_slow_dummy.log` (PostgreSQL format) in project root
- [ ] Create `test/data/pg_dummy.log` with edge cases
  - [ ] Simple queries
  - [ ] Multi-line queries
  - [ ] Parameterized queries
- [ ] Create `test/data/mysql_dummy.log`
  - [ ] Standard slow query log format
  - [ ] Various Query_time values
  - [ ] Lock_time and row metrics
- [ ] Create `test/data/large.log.gz` (gzip compressed)

### Unit Tests
- [x] Fingerprint tests (F-01, F-02, F-03) in `test/main.ml`
  - [x] Number replacement
  - [x] String replacement
  - [x] Space normalization
- [x] Stats tests (basic, percentiles) in `test/main.ml`
  - [x] Count, sum, avg, max
  - [x] P50, P95, P99
- [ ] Add tests for new Stats fields (min, p1, std are computed but not tested)
- [ ] Parser tests
  - [ ] PostgreSQL parser (P-01, P-02)
  - [ ] MySQL parser (P-03, P-04)
- [ ] Report tests
  - [ ] JSON format validation
  - [ ] CSV format validation

### Integration Tests
- [ ] CLI argument parsing tests (C-02)
- [ ] Gzip file reading test (C-01)
- [ ] End-to-end test with PostgreSQL log
- [ ] End-to-end test with MySQL log
- [ ] JSON output validation (C-03)
- [ ] CSV output validation (C-03)

## Verification & Validation
- [ ] Manual verification with `my_slow_dummy.log`
- [ ] Compare output with expected results
- [ ] Performance testing with large log files
- [ ] Edge case testing (empty logs, malformed entries)

## Documentation
- [x] Create README.md (English)
- [x] Create README.ja.md (Japanese)
- [x] Create LICENSE (MIT)
- [x] Create .gitignore
- [x] Update feature_ideas.md with comprehensive feature roadmap
- [x] Create implementation_plan.md in docs/slowql_mvp
- [x] Create test_plan.md in docs/slowql_mvp
- [x] Create task.md in docs/slowql_mvp
- [ ] Create usage examples in README
- [ ] Document output format specifications in README

## Current Status Summary

### Completed (基本構造は完成)
- プロジェクトのセットアップとビルド環境
- Fingerprintモジュール（完全実装）
- Statsモジュール（統計計算ロジックは完全実装、集約機能は未実装）
- Reportモジュール（スケルトンのみ）
- CLI基本構造（Cmdlinerベース、引数定義のみ）
- 基本的な単体テスト（Fingerprint、Stats）

### In Progress / Next Steps (次に取り組むべき項目)
1. **Parser_mysqlとParser_pgの実装** - ログファイルを解析する核心機能
2. **集約ロジックの実装** - FingerprintとStatsを組み合わせてクエリごとに統計を集計
3. **Reportモジュールの完全実装** - JSON/CSV形式で実データを出力
4. **CLI main関数の実装** - Parser -> Aggregator -> Report のパイプライン
5. **統合テストとE2Eテスト** - 実際のログファイルでの動作確認
