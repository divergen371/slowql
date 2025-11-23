# SlowQL MVP Implementation Tasks

## Project Setup
- [x] Add dependencies (`re`, `yojson`, `caqti`, `cohttp`, `logs`, etc.) to `dune-project` and `slowql.opam`
- [x] Update `dune` files
- [x] Create test infrastructure with `alcotest`

## Core Logic Implementation
- [x] Implement `Fingerprint` module (SQL normalization with lowercase, number/string replacement)
- [x] Implement `Stats` module (P1, P50, P95, P99, Min, Max, Avg, STD)
- [ ] Implement `Parser_mysql` module
  - [ ] Parse MySQL slow query log header lines (Query_time, Lock_time, Rows_sent, Rows_examined)
  - [ ] Extract SQL statements from MySQL logs
  - [ ] Handle multi-line queries
- [ ] Implement `Parser_pg` module
  - [ ] Parse PostgreSQL log format (duration, statement)
  - [ ] Extract user, database, host information
  - [ ] Handle multi-line queries
- [ ] Implement `Log_reader` module
  - [ ] Read plain text log files
  - [ ] Handle gzip-compressed files (via `gzip -dc` command)
  - [ ] Auto-detect file format

## Aggregation & Statistics
- [ ] Implement aggregation logic in `Stats` module
  - [ ] Group queries by fingerprint
  - [ ] Collect timing data for each fingerprint
  - [ ] Compute additional metrics (CV, IQR, MAD - future)
- [ ] Add support for tracking query context (user, database, session ID)

## Reporting
- [ ] Implement JSON output in `Report` module
  - [ ] Format stats as JSON array
  - [ ] Include all statistical metrics (count, total, min, avg, max, p1, p50, p95, p99, std)
  - [ ] Write to specified file path
- [ ] Implement CSV output in `Report` module
  - [ ] Format stats as CSV with header row
  - [ ] Include all statistical metrics
  - [ ] Write to specified file path

## CLI & Integration
- [ ] Update `bin/slowql.ml` CLI interface
  - [ ] Add `--in` option for input files
  - [ ] Support multiple input files
  - [ ] Implement `--db` auto-detection
  - [ ] Wire Parser -> Fingerprint -> Stats -> Report pipeline
- [ ] Implement main execution flow
  - [ ] Read log files (with gzip support)
  - [ ] Parse logs based on detected/specified DB type
  - [ ] Aggregate statistics
  - [ ] Generate reports

## Testing

### Test Data Preparation
- [x] Create `my_slow_dummy.log` (PostgreSQL format)
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
- [x] Fingerprint tests (F-01, F-02, F-03)
  - [x] Number replacement
  - [x] String replacement
  - [x] Space normalization
- [x] Stats tests (basic, percentiles)
  - [x] Count, sum, avg, max
  - [x] P50, P95, P99
- [ ] Add tests for new Stats fields (min, p1, std)
- [ ] Parser tests
  - [ ] PostgreSQL parser (P-01, P-02)
  - [ ] MySQL parser (P-03, P-04)

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
- [ ] Create usage examples in README
- [ ] Document output format specifications
