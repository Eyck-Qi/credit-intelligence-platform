-- Day 3: Validate, deduplicate, and load staging data into the core table.

WITH validated_rows AS (
    SELECT
        s.staging_id,
        c.company_id,
        TRIM(s.fiscal_year)::SMALLINT AS fiscal_year,
        TRIM(s.revenue)::NUMERIC(18, 2) AS revenue,
        TRIM(s.net_income)::NUMERIC(18, 2) AS net_income,
        TRIM(s.total_assets)::NUMERIC(18, 2) AS total_assets,
        TRIM(s.total_liabilities)::NUMERIC(18, 2) AS total_liabilities,
        TRIM(s.cash_flow_from_operations)::NUMERIC(18, 2)
            AS cash_flow_from_operations
    FROM stg_financial_statements AS s
    JOIN companies AS c
        ON LOWER(TRIM(s.company_name)) = LOWER(c.legal_name)
    WHERE NULLIF(TRIM(s.company_name), '') IS NOT NULL
      AND TRIM(s.fiscal_year) ~ '^[0-9]{4}$'
      AND TRIM(s.fiscal_year)::INTEGER BETWEEN 1900 AND 2100
      AND TRIM(s.revenue) ~ '^[0-9]+(\.[0-9]+)?$'
      AND TRIM(s.net_income) ~ '^-?[0-9]+(\.[0-9]+)?$'
      AND TRIM(s.total_assets) ~ '^[0-9]+(\.[0-9]+)?$'
      AND TRIM(s.total_liabilities) ~ '^[0-9]+(\.[0-9]+)?$'
      AND TRIM(s.cash_flow_from_operations) ~ '^-?[0-9]+(\.[0-9]+)?$'
),
deduplicated_rows AS (
    SELECT
        validated_rows.*,
        ROW_NUMBER() OVER (
            PARTITION BY company_id, fiscal_year
            ORDER BY staging_id
        ) AS duplicate_rank
    FROM validated_rows
)
INSERT INTO financial_statements (
    company_id,
    fiscal_year,
    revenue,
    net_income,
    total_assets,
    total_liabilities,
    cash_flow_from_operations
)
SELECT
    company_id,
    fiscal_year,
    revenue,
    net_income,
    total_assets,
    total_liabilities,
    cash_flow_from_operations
FROM deduplicated_rows
WHERE duplicate_rank = 1
ON CONFLICT (company_id, fiscal_year) DO UPDATE
SET
    revenue = EXCLUDED.revenue,
    net_income = EXCLUDED.net_income,
    total_assets = EXCLUDED.total_assets,
    total_liabilities = EXCLUDED.total_liabilities,
    cash_flow_from_operations = EXCLUDED.cash_flow_from_operations;
