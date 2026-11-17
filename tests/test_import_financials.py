from scripts.import_financials import DEFAULT_CSV_PATH, RAW_COLUMNS, read_csv_rows


def test_sample_csv_has_expected_columns_and_rows() -> None:
    rows = read_csv_rows(DEFAULT_CSV_PATH)

    assert len(rows) == 10
    assert tuple(rows[0]) == RAW_COLUMNS


def test_sample_csv_preserves_raw_quality_issues() -> None:
    rows = read_csv_rows(DEFAULT_CSV_PATH)

    assert any(not row["company_name"].strip() for row in rows)
    assert any(not row["cash_flow_from_operations"].strip() for row in rows)
    assert any(float(row["revenue"]) < 0 for row in rows)
