import csv
from pathlib import Path

from sqlalchemy import text

from credit_intelligence.database import create_database_engine

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "data" / "processed" / "latest_credit_risk.csv"

REPORT_COLUMNS = (
    "company_id",
    "legal_name",
    "industry",
    "fiscal_year",
    "revenue_growth_pct",
    "net_margin_pct",
    "debt_to_asset_ratio",
    "operating_cash_flow_margin",
    "risk_level",
)

# Return the latest company risk results in review-priority order.
LATEST_RISK_QUERY = text(
    """
    SELECT
        company_id,
        legal_name,
        industry,
        fiscal_year,
        revenue_growth_pct,
        net_margin_pct,
        debt_to_asset_ratio,
        operating_cash_flow_margin,
        risk_level
    FROM vw_latest_credit_risk
    ORDER BY
        CASE risk_level
            WHEN 'high' THEN 1
            WHEN 'medium' THEN 2
            WHEN 'low' THEN 3
        END
    """
)


def fetch_latest_risk_rows() -> list[dict[str, object]]:
    engine = create_database_engine()

    with engine.connect() as connection:
        result = connection.execute(LATEST_RISK_QUERY)
        return [dict(row) for row in result.mappings()]


def write_credit_report(
    rows: list[dict[str, object]],
    output_path: Path = DEFAULT_OUTPUT_PATH,
) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=REPORT_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    return output_path

def main() -> None:
    rows = fetch_latest_risk_rows()
    output_path = write_credit_report(rows)
    print(f"Generated {len(rows)} credit risk rows at {output_path}.")


if __name__ == "__main__":
    main()
