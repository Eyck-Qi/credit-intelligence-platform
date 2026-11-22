from pathlib import Path
from typing import Any

import xlsxwriter
from sqlalchemy import text

from credit_intelligence.database import create_database_engine

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "outputs/day7-credit-report/credit_intelligence_report.xlsx"

DETAIL_QUERY = text("""
    SELECT * FROM vw_credit_decisions
    ORDER BY CASE system_recommendation
        WHEN 'decline' THEN 1 WHEN 'review' THEN 2 WHEN 'approve' THEN 3 END,
        application_id
""")

DETAIL_COLUMNS = (
    "application_id", "company_id", "requested_amount", "loan_purpose", "term_months",
    "application_status", "legal_name", "industry", "credit_score", "risk_grade",
    "assessment_recommendation", "fiscal_year", "revenue_growth_pct", "net_margin_pct",
    "debt_to_asset_ratio", "operating_cash_flow_margin", "risk_level",
    "system_recommendation", "decision_reason", "decision_matches_assessment",
)
DETAIL_HEADERS = (
    "Application ID", "Company ID", "Requested Amount", "Loan Purpose", "Term (Months)",
    "Application Status", "Company", "Industry", "Credit Score", "Risk Grade",
    "Assessment Recommendation", "Fiscal Year", "Revenue Growth", "Net Margin",
    "Debt-to-Asset Ratio", "Operating Cash Flow Margin", "Financial Risk",
    "System Decision", "Decision Reason", "Matches Assessment",
)

NAVY, BLUE, LIGHT_BLUE, LIGHT_BORDER = "#17365D", "#1F4E78", "#D9EAF7", "#D9E2F3"
RISK_COLORS = {
    "decline": ("#FDE9E7", "#9C0006"),
    "review": ("#FFF2CC", "#9C6500"),
    "approve": ("#E2F0D9", "#006100"),
}


def fetch_decision_rows() -> list[dict[str, Any]]:
    engine = create_database_engine()
    with engine.connect() as connection:
        return [dict(row) for row in connection.execute(DETAIL_QUERY).mappings()]


def _formats(workbook: xlsxwriter.Workbook) -> dict[str, Any]:
    base = {"font_name": "Arial", "font_size": 10}
    return {
        "title": workbook.add_format({**base, "font_size": 15, "bold": True,
                                      "font_color": NAVY}),
        "subtitle": workbook.add_format({**base, "italic": True, "font_color": "#666666"}),
        "card": workbook.add_format({**base, "bold": True, "font_color": NAVY,
                                     "bg_color": LIGHT_BLUE, "border": 1,
                                     "border_color": LIGHT_BORDER, "valign": "vcenter"}),
        "header": workbook.add_format({**base, "bold": True, "font_color": "#FFFFFF",
                                       "bg_color": NAVY, "align": "center",
                                       "valign": "vcenter", "text_wrap": True}),
        "section": workbook.add_format({**base, "bold": True, "font_color": "#FFFFFF",
                                        "bg_color": BLUE}),
        "body": workbook.add_format({**base, "font_color": "#222222", "valign": "top",
                                     "bottom": 1, "bottom_color": LIGHT_BORDER}),
        "wrap": workbook.add_format({**base, "font_color": "#222222", "valign": "top",
                                     "text_wrap": True, "bottom": 1,
                                     "bottom_color": LIGHT_BORDER}),
        "integer": workbook.add_format({**base, "num_format": "#,##0"}),
        "currency": workbook.add_format({**base, "num_format": "$#,##0"}),
        "percent": workbook.add_format({**base, "num_format": "0.00%"}),
        "share": workbook.add_format({**base, "num_format": "0.0%"}),
        "total": workbook.add_format({**base, "bold": True, "font_color": NAVY, "top": 6}),
        "total_currency": workbook.add_format({**base, "bold": True, "font_color": NAVY,
                                               "num_format": "$#,##0", "top": 6}),
        "total_share": workbook.add_format({**base, "bold": True, "font_color": NAVY,
                                            "num_format": "0.0%", "top": 6}),
    }


def _write_detail(workbook: xlsxwriter.Workbook, rows: list[dict[str, Any]], f: dict) -> None:
    sheet = workbook.add_worksheet("Decision Detail")
    sheet.hide_gridlines(2)
    sheet.set_tab_color("#5B9BD5")
    sheet.merge_range("A2:T2", "Credit Decision Detail", f["title"])
    sheet.merge_range("A3:T3", "Source: PostgreSQL vw_credit_decisions", f["subtitle"])
    sheet.set_row(3, 36)
    for column, header in enumerate(DETAIL_HEADERS):
        sheet.write(3, column, header, f["header"])
    for row_number, row in enumerate(rows, start=4):
        for column, key in enumerate(DETAIL_COLUMNS):
            value, cell_format = row[key], f["body"]
            if key in {"revenue_growth_pct", "net_margin_pct"}:
                value, cell_format = float(value) / 100, f["percent"]
            elif key in {"debt_to_asset_ratio", "operating_cash_flow_margin"}:
                value, cell_format = float(value), f["percent"]
            elif key == "requested_amount":
                value, cell_format = float(value), f["currency"]
            elif key == "decision_reason":
                cell_format = f["wrap"]
            sheet.write(row_number, column, value, cell_format)
        sheet.set_row(row_number, 42)
    last_row = 3 + len(rows)
    sheet.add_table(3, 0, last_row, 19, {
        "name": "DecisionDetailTable", "style": "Table Style Medium 2",
        "columns": [{"header": header} for header in DETAIL_HEADERS],
    })
    for label, colors in {"high": RISK_COLORS["decline"],
                          "medium": RISK_COLORS["review"],
                          "low": RISK_COLORS["approve"]}.items():
        sheet.conditional_format(4, 16, last_row, 16, {
            "type": "text", "criteria": "containing", "value": label,
            "format": workbook.add_format({"bg_color": colors[0], "font_color": colors[1],
                                           "bold": True}),
        })
    for label, colors in RISK_COLORS.items():
        sheet.conditional_format(4, 17, last_row, 17, {
            "type": "text", "criteria": "containing", "value": label,
            "format": workbook.add_format({"bg_color": colors[0], "font_color": colors[1],
                                           "bold": True}),
        })
    widths = [13, 11, 18, 22, 14, 18, 29, 18, 13, 12, 23, 12, 15, 15, 19, 22, 14, 18, 52, 19]
    for column, width in enumerate(widths):
        sheet.set_column(column, column, width)
    sheet.freeze_panes(4, 2)


def _write_summary(workbook: xlsxwriter.Workbook, rows: list[dict[str, Any]], f: dict) -> None:
    sheet = workbook.add_worksheet("Portfolio Summary")
    sheet.hide_gridlines(2)
    sheet.set_tab_color(NAVY)
    sheet.merge_range("A2:H2", "Credit Decision Portfolio", f["title"])
    sheet.merge_range("A3:H3", "Latest application decisions and requested exposure", f["subtitle"])
    detail_last_row = 4 + len(rows)
    total_amount = sum(float(row["requested_amount"]) for row in rows)
    matching = sum(bool(row["decision_matches_assessment"]) for row in rows)
    for cell, label in (("A6", "Applications"), ("D6", "Requested Amount"),
                        ("G6", "Matching Decisions")):
        row, column = xlsxwriter.utility.xl_cell_to_rowcol(cell)
        sheet.write(row, column, label, f["card"])
        sheet.write_blank(row, column + 1, None, f["card"])
    sheet.write_formula("B6", f"=COUNTA('Decision Detail'!$A$5:$A${detail_last_row})",
                        f["integer"], len(rows))
    sheet.write_formula("E6", f"=SUM('Decision Detail'!$C$5:$C${detail_last_row})",
                        f["currency"], total_amount)
    sheet.write_formula("H6", f"=COUNTIF('Decision Detail'!$T$5:$T${detail_last_row},TRUE)",
                        f["integer"], matching)
    for column, header in enumerate(("System Decision", "Applications", "Requested Amount",
                                     "Exposure Share")):
        sheet.write(8, column, header, f["header"])
    for row_number, decision in enumerate(("Decline", "Review", "Approve"), start=9):
        key, excel_row = decision.lower(), row_number + 1
        count = sum(row["system_recommendation"] == key for row in rows)
        amount = sum(float(row["requested_amount"]) for row in rows
                     if row["system_recommendation"] == key)
        share = amount / total_amount if total_amount else 0
        sheet.write(row_number, 0, decision, f["body"])
        sheet.write_formula(row_number, 1,
                            f"=COUNTIF('Decision Detail'!$R$5:$R${detail_last_row},$A{excel_row})",
                            f["integer"], count)
        sheet.write_formula(row_number, 2,
                            f"=SUMIF('Decision Detail'!$R$5:$R${detail_last_row},$A{excel_row},"
                            f"'Decision Detail'!$C$5:$C${detail_last_row})",
                            f["currency"], amount)
        sheet.write_formula(row_number, 3, f'=IF($E$6=0,"n.a.",C{excel_row}/$E$6)',
                            f["share"], share)
        colors = RISK_COLORS[key]
        sheet.conditional_format(row_number, 0, row_number, 3, {
            "type": "formula", "criteria": f'=$A{excel_row}="{decision}"',
            "format": workbook.add_format({"bg_color": colors[0], "font_color": colors[1],
                                           "bold": True}),
        })
    sheet.write("A13", "Total", f["total"])
    sheet.write_formula("B13", "=SUM(B10:B12)", f["total"], len(rows))
    sheet.write_formula("C13", "=SUM(C10:C12)", f["total_currency"], total_amount)
    sheet.write_formula("D13", "=SUM(D10:D12)", f["total_share"], 1)
    sheet.merge_range("A16:D16", "Decision rules", f["section"])
    for row_number, (decision, rule) in enumerate((
        ("Decline", "High financial risk, score below 50, or grade D/E"),
        ("Review", "Medium financial risk, score below 70, or grade C"),
        ("Approve", "Low financial risk with stronger credit profile"),
    ), start=16):
        sheet.write(row_number, 0, decision, f["body"])
        sheet.write(row_number, 1, rule, f["wrap"])
        sheet.set_row(row_number, 34)
    chart = workbook.add_chart({"type": "column"})
    chart.add_series({"name": "Requested Amount",
                      "categories": "='Portfolio Summary'!$A$10:$A$12",
                      "values": "='Portfolio Summary'!$C$10:$C$12",
                      "fill": {"color": "#5B9BD5"}})
    chart.set_title({"name": "Requested Amount by Decision"})
    chart.set_y_axis({"name": "Requested Amount (USD)", "num_format": '$0.0,,"M"'})
    chart.set_legend({"none": True})
    chart.set_style(10)
    sheet.insert_chart("F9", chart, {"x_scale": 1.25, "y_scale": 1.25})
    sheet.set_column("A:A", 20)
    sheet.set_column("B:B", 48)
    sheet.set_column("C:E", 18)
    sheet.set_column("F:H", 16)
    sheet.set_row(1, 24)
    sheet.set_row(5, 26)
    sheet.set_row(8, 28)
    sheet.freeze_panes(8, 0)


def build_excel_report(rows: list[dict[str, Any]], output_path: Path = DEFAULT_OUTPUT_PATH) -> Path:
    if not rows:
        raise ValueError("No credit decision rows were returned.")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    workbook = xlsxwriter.Workbook(output_path)
    workbook.set_calc_mode("auto")
    f = _formats(workbook)
    _write_summary(workbook, rows, f)
    _write_detail(workbook, rows, f)
    workbook.close()
    return output_path


def main() -> None:
    rows = fetch_decision_rows()
    output_path = build_excel_report(rows)
    print(f"Generated Excel report with {len(rows)} applications at {output_path}.")


if __name__ == "__main__":
    main()
