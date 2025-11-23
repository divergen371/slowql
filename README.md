# SlowQL

[日本語](README.ja.md) | English

![CI](https://github.com/divergen371/slowql/workflows/CI/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![OCaml](https://img.shields.io/badge/OCaml-5.2+-orange.svg)

A high-performance slow query log analyzer for MySQL and PostgreSQL, written in OCaml.

## Overview

SlowQL is a command-line tool that parses slow query logs from MySQL and PostgreSQL, normalizes SQL queries by fingerprinting, and generates statistical reports in JSON and CSV formats. It helps database administrators and developers identify performance bottlenecks and optimize database queries.

## Features

### Current (MVP)

- **Multi-database support**: MySQL slow query logs and PostgreSQL logs
- **SQL fingerprinting**: Normalizes queries by replacing literals with placeholders
- **Statistical analysis**: Computes count, total time, average, max, and percentiles (P50, P95, P99)
- **Multiple output formats**: JSON and CSV reports
- **Gzip support**: Reads both plain text and gzip-compressed log files

### Planned Features

- **Time-based filtering**: Filter logs by date/time range (`--since`, `--until`)
- **HTML reports**: Rich visual reports with charts and histograms
- **EXPLAIN integration**: Automatically run EXPLAIN on slow queries
- **Interactive TUI**: Terminal UI for exploring results
- **Anonymization**: Mask sensitive table/column names for sharing
- **Markdown reports**: GitHub-friendly report format

## Installation

### Prerequisites

- OCaml 4.14+ or later
- opam (OCaml package manager)
- dune (build system)

### Install Dependencies

```bash
opam install . --deps-only
```

### Build

```bash
dune build
```

### Run Tests

```bash
dune runtest
```

## Usage

```bash
dune exec -- slowql [OPTIONS] <log-files...>
```

### Options

- `--db <type>`: Database type (`auto`, `mysql`, `postgres`). Default: `auto`
- `--top <N>`: Show top N queries by total time. Default: `20`
- `--json <path>`: JSON output path. Default: `slowql.json`
- `--csv <path>`: CSV output path. Default: `slowql.csv`

### Examples

```bash
# Analyze PostgreSQL log
dune exec -- slowql --db postgres my_slow_dummy.log

# Analyze MySQL log with custom output paths
dune exec -- slowql --db mysql --json report.json --csv report.csv mysql-slow.log

# Analyze gzip-compressed log
dune exec -- slowql --db postgres slow.log.gz
```

## Output Format

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

## Development Status

This project is currently in **MVP (Minimum Viable Product)** phase.

- ✅ Core fingerprinting logic
- ✅ Statistical computation (percentiles, averages)
- ✅ Unit tests with Alcotest
- 🚧 MySQL/PostgreSQL log parsers (in progress)
- 🚧 CLI integration (in progress)
- 🚧 Report generation (in progress)

See [docs/slowql_mvp/task.md](docs/slowql_mvp/task.md) for detailed progress.

## Project Structure

```
slowql/
├── bin/           # CLI entry point
├── src/           # Core library
│   ├── fingerprint.ml   # SQL normalization
│   ├── stats.ml         # Statistical computation
│   ├── parser_mysql.ml  # MySQL log parser
│   ├── parser_pg.ml     # PostgreSQL log parser
│   └── report.ml        # Report generation
├── test/          # Unit tests
└── docs/          # Documentation
    └── slowql_mvp/
        ├── implementation_plan.md
        ├── feature_ideas.md
        └── test_plan.md
```

## Dependencies

### Core

- `re`: Regular expressions for parsing and fingerprinting
- `yojson`: JSON output generation

### Extended (for future features)

- `caqti`, `caqti-lwt`: Database connections for EXPLAIN integration
- `cohttp-lwt-unix`: HTTP server for web UI
- `logs`: Structured logging
- `ptime`: Time/date parsing and filtering
- `tyxml`: HTML report generation
- `digestif`: Hashing for anonymization
- `notty`: Terminal UI

## License

MIT License

## Author

Ishikawa

## Acknowledgments

Inspired by tools like `pt-query-digest` and `pgBadger`.
