from pathlib import Path

from openpyxl import load_workbook

from scripts.generate_excel_report import build_excel_report


def test_build_excel_report(tmp_path: Path) -> None:
    rows = [
        {
            "application_id": 1,
            "company_id": 1,
            "requested_amount": 1500000,
            "loan_purpose": "Equipment expansion",
            "term_months": 60,
            "application_status": "pending",
            "legal_name": "Northstar Components LLC",
            "industry": "Manufacturing",
            "credit_score": 84,
            "risk_grade": "A",
            "assessment_recommendation": "approve",
            "fiscal_year": 2026,
            "revenue_growth_pct": 8.65,
            "net_margin_pct": 7.86,
            "debt_to_asset_ratio": 0.5091,
            "operating_cash_flow_margin": 0.0955,
            "risk_level": "low",
            "system_recommendation": "approve",
            "decision_reason": "Low financial risk and strong credit profile",
            "decision_matches_assessment": True,
        }
    ]
    output_path = tmp_path / "credit_report.xlsx"

    build_excel_report(rows, output_path)
    workbook = load_workbook(output_path, data_only=False)

    assert workbook.sheetnames == ["Portfolio Summary", "Decision Detail"]
    assert workbook["Decision Detail"]["G5"].value == "Northstar Components LLC"
    assert workbook["Decision Detail"]["R5"].value == "approve"
    assert workbook["Portfolio Summary"]["E6"].value == "=SUM('Decision Detail'!$C$5:$C$5)"
    assert len(workbook["Portfolio Summary"]._charts) == 1
