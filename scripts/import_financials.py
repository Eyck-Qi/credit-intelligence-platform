import argparse
import csv
from pathlib import Path

from sqlalchemy import text

from credit_intelligence.database import create_database_engine

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV_PATH = PROJECT_ROOT / "data" / "raw" / "company_financials_sample.csv"

RAW_COLUMNS = (
    "company_name",
    "fiscal_year",
    "revenue",
    "net_income",
    "total_assets",
    "total_liabilities",
    "cash_flow_from_operations",
)


def read_csv_rows(csv_path: Path) -> list[dict[str, str]]:
    with csv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != list(RAW_COLUMNS):
            raise ValueError(
                f"Unexpected CSV columns. Expected {list(RAW_COLUMNS)}, "
                f"received {reader.fieldnames}."
            )
        return list(reader)


def load_staging_table(csv_path: Path) -> int:
    rows = read_csv_rows(csv_path)
    source_file = csv_path.name
    staged_rows = [{**row, "source_file": source_file} for row in rows]
    engine = create_database_engine()

    delete_existing = text(
        "DELETE FROM stg_financial_statements WHERE source_file = :source_file"
    )
    insert_row = text(
        """
        INSERT INTO stg_financial_statements (
            company_name,
            fiscal_year,
            revenue,
            net_income,
            total_assets,
            total_liabilities,
            cash_flow_from_operations,
            source_file
        )
        VALUES (
            :company_name,
            :fiscal_year,
            :revenue,
            :net_income,
            :total_assets,
            :total_liabilities,
            :cash_flow_from_operations,
            :source_file
        )
        """
    )

    with engine.begin() as connection:
        connection.execute(delete_existing, {"source_file": source_file})
        connection.execute(insert_row, staged_rows)

    return len(staged_rows)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Load raw financial CSV data into staging.")
    parser.add_argument(
        "csv_path",
        nargs="?",
        type=Path,
        default=DEFAULT_CSV_PATH,
        help="CSV file to import",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    csv_path = args.csv_path.expanduser().resolve()
    loaded_count = load_staging_table(csv_path)
    print(f"Loaded {loaded_count} rows from {csv_path.name} into staging.")


if __name__ == "__main__":
    main()
