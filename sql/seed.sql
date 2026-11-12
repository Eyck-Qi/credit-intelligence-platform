BEGIN;

INSERT INTO companies (legal_name, industry, country_code, founded_year)
VALUES
    ('Northstar Components LLC', 'Manufacturing', 'US', 2008),
    ('Harborview Logistics Inc.', 'Transportation', 'US', 2014),
    ('Juniper Health Systems', 'Healthcare', 'US', 2011)
ON CONFLICT (legal_name) DO NOTHING;

INSERT INTO financial_statements (
    company_id,
    fiscal_year,
    revenue,
    net_income,
    total_assets,
    total_liabilities,
    cash_flow_from_operations
)
VALUES
    ((SELECT company_id FROM companies WHERE legal_name = 'Northstar Components LLC'),
     2023, 15200000, 980000, 10400000, 5860000, 1210000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Northstar Components LLC'),
     2024, 16800000, 1180000, 11200000, 6080000, 1460000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Northstar Components LLC'),
     2025, 18500000, 1420000, 12100000, 6350000, 1750000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Harborview Logistics Inc.'),
     2023, 8300000, 420000, 7100000, 4860000, 610000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Harborview Logistics Inc.'),
     2024, 9100000, 370000, 7800000, 5580000, 580000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Harborview Logistics Inc.'),
     2025, 9700000, 310000, 8400000, 6210000, 540000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Juniper Health Systems'),
     2023, 12700000, 460000, 9300000, 6890000, 720000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Juniper Health Systems'),
     2024, 13600000, 140000, 10100000, 8010000, 410000),
    ((SELECT company_id FROM companies WHERE legal_name = 'Juniper Health Systems'),
     2025, 14300000, -180000, 10900000, 9170000, 120000)
ON CONFLICT (company_id, fiscal_year) DO NOTHING;

INSERT INTO loan_applications (
    company_id,
    requested_amount,
    loan_purpose,
    term_months
)
SELECT company_id, 1500000, 'Equipment expansion', 60
FROM companies
WHERE legal_name = 'Northstar Components LLC'
  AND NOT EXISTS (
      SELECT 1 FROM loan_applications
      WHERE loan_purpose = 'Equipment expansion'
        AND company_id = companies.company_id
  );

INSERT INTO loan_applications (
    company_id,
    requested_amount,
    loan_purpose,
    term_months
)
SELECT company_id, 900000, 'Fleet renewal', 48
FROM companies
WHERE legal_name = 'Harborview Logistics Inc.'
  AND NOT EXISTS (
      SELECT 1 FROM loan_applications
      WHERE loan_purpose = 'Fleet renewal'
        AND company_id = companies.company_id
  );

INSERT INTO loan_applications (
    company_id,
    requested_amount,
    loan_purpose,
    term_months
)
SELECT company_id, 1250000, 'Working capital', 36
FROM companies
WHERE legal_name = 'Juniper Health Systems'
  AND NOT EXISTS (
      SELECT 1 FROM loan_applications
      WHERE loan_purpose = 'Working capital'
        AND company_id = companies.company_id
  );

INSERT INTO credit_assessments (
    application_id,
    credit_score,
    risk_grade,
    debt_to_asset_ratio,
    recommendation,
    rationale
)
SELECT application_id, 84, 'A', 0.5248, 'approve',
       'Strong profitability and operating cash flow with moderate leverage.'
FROM loan_applications
WHERE loan_purpose = 'Equipment expansion'
ON CONFLICT (application_id) DO NOTHING;

INSERT INTO credit_assessments (
    application_id,
    credit_score,
    risk_grade,
    debt_to_asset_ratio,
    recommendation,
    rationale
)
SELECT application_id, 66, 'C', 0.7393, 'review',
       'Positive earnings but elevated leverage requires additional review.'
FROM loan_applications
WHERE loan_purpose = 'Fleet renewal'
ON CONFLICT (application_id) DO NOTHING;

INSERT INTO credit_assessments (
    application_id,
    credit_score,
    risk_grade,
    debt_to_asset_ratio,
    recommendation,
    rationale
)
SELECT application_id, 42, 'D', 0.8413, 'decline',
       'Negative earnings, weak operating cash flow, and high leverage.'
FROM loan_applications
WHERE loan_purpose = 'Working capital'
ON CONFLICT (application_id) DO NOTHING;

COMMIT;
