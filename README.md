# Credit Intelligence Platform

A SQL and Python portfolio project for analyzing borrower financial information,
assessing credit risk, and supporting lending decisions.

## Technology

- Python 3.12
- PostgreSQL 16
- SQLAlchemy and Psycopg
- Pytest and Ruff
- Microsoft Excel and Power BI Service

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
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day3_staging_schema.sql
python scripts/import_financials.py
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day3_staging_validation.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day3_load_clean_data.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day3_reconciliation.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day4_financial_metrics_view.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day4_latest_credit_risk_view.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day4_portfolio_summary.sql
python scripts/generate_credit_report.py
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day6_credit_decision_view.sql
/opt/homebrew/opt/postgresql@16/bin/psql -U credit_app -d credit_intelligence -f sql/day6_decision_summary.sql
python scripts/generate_excel_report.py
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
- `data/raw/company_financials_sample.csv`: raw sample input with intentional quality issues
- `sql/day3_staging_schema.sql`: permissive raw-data staging table
- `sql/day3_staging_validation.sql`: staging completeness, uniqueness, and validity checks
- `sql/day3_load_clean_data.sql`: validated, deduplicated upsert into the core table
- `sql/day3_reconciliation.sql`: row-level accepted and rejection outcomes
- `sql/day4_financial_metrics_view.sql`: reusable company-year financial metrics view
- `sql/day4_latest_credit_risk_view.sql`: latest company-level risk classification view
- `sql/day4_portfolio_summary.sql`: portfolio summary by credit risk level
- `scripts/generate_credit_report.py`: export the latest risk view to CSV
- `data/processed/latest_credit_risk.csv`: generated company credit risk report
- `sql/day6_credit_decision_view.sql`: explainable application-level decision engine
- `sql/day6_decision_summary.sql`: decision volume and requested-exposure summary
- `scripts/generate_excel_report.py`: create the formatted Excel decision report
- `outputs/day7-credit-report/credit_intelligence_report.xlsx`: Excel portfolio report
- `docs/day8-power-bi.md`: Power BI dashboard design, metrics, and verification notes
- `src/credit_intelligence`: Python package and database connection
- `scripts`: database setup, connection checks, and CSV ingestion
- `tests`: automated environment and ingestion tests

