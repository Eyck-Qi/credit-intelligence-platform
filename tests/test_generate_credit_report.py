import csv
from pathlib import Path

from scripts.generate_credit_report import REPORT_COLUMNS, write_credit_report


def test_write_credit_report(tmp_path: Path) -> None:
    rows = [
        {
            "company_id": 3,
            "legal_name": "Juniper Health Systems",
            "industry": "Healthcare",
            "fiscal_year": 2026,
            "revenue_growth_pct": 4.20,
            "net_margin_pct": -1.74,
            "debt_to_asset_ratio": 0.8632,
            "operating_cash_flow_margin": 0.0054,
            "risk_level": "high",
        }
    ]
    output_path = tmp_path / "credit_report.csv"

    write_credit_report(rows, output_path)

    with output_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        actual_rows = list(reader)

    assert reader.fieldnames == list(REPORT_COLUMNS)
    assert len(actual_rows) == 1
    assert actual_rows[0]["risk_level"] == "high"
