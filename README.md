# Credit Intelligence Platform

A SQL and Python portfolio project for analyzing borrower financial information,
assessing credit risk, and supporting lending decisions.

## Technology

- Python 3.12
- PostgreSQL 16
- SQLAlchemy and Psycopg
- Pytest and Ruff

## Local database

- Database: `credit_intelligence`
- Development role: `credit_app`
- Connection settings: `.env`

## Project commands

Run these commands from the project folder:

```bash
source .venv/bin/activate
python scripts/init_database.py
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/seed.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/analysis_queries.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day2_trend_analysis.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day2_risk_screening.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day2_data_quality.sql
pytest
ruff check .
```

The schema and seed scripts are safe to run more than once.

## Structure

- `sql/schema.sql`: database tables, constraints, and indexes
- `sql/seed.sql`: repeatable sample data
- `sql/analysis_queries.sql`: initial portfolio analysis
- `sql/day2_trend_analysis.sql`: multi-year growth and profitability trends
- `sql/day2_risk_screening.sql`: latest-year review flags and risk levels
- `sql/day2_data_quality.sql`: missing, duplicate, and unusual-record checks
- `src/credit_intelligence`: Python package and database connection
- `scripts`: database setup and connection checks
- `tests`: automated environment tests

