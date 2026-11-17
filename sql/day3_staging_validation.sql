-- Day 3: Staging data quality validation

-- Import batch summary.
SELECT
    source_file,
    COUNT(*) AS row_count,
    MIN(loaded_at) AS loaded_at
FROM stg_financial_statements
GROUP BY source_file
ORDER BY source_file;

-- Find missing company names or operating cash flow values.
SELECT
    staging_id,
    company_name,
    fiscal_year,
    cash_flow_from_operations
FROM stg_financial_statements
WHERE NULLIF(TRIM(company_name), '') IS NULL
   OR NULLIF(TRIM(cash_flow_from_operations), '') IS NULL;

-- Find duplicate company-year keys after normalizing company names.
SELECT
    LOWER(TRIM(company_name)) AS normalized_company_name,
    fiscal_year,
    COUNT(*) AS record_count
FROM stg_financial_statements
GROUP BY
    LOWER(TRIM(company_name)),
    fiscal_year
HAVING COUNT(*) > 1;

-- Find malformed or out-of-range fiscal years.
SELECT
    staging_id,
    company_name,
    fiscal_year
FROM stg_financial_statements
WHERE CASE
    WHEN TRIM(fiscal_year) ~ '^[0-9]{4}$'
        THEN TRIM(fiscal_year)::INTEGER NOT BETWEEN 1900 AND 2100
    ELSE TRUE
END;

-- Find malformed or negative revenue values.
SELECT
    staging_id,
    company_name,
    fiscal_year,
    revenue
FROM stg_financial_statements
WHERE CASE
    WHEN TRIM(revenue) ~ '^-?[0-9]+(\.[0-9]+)?$'
        THEN TRIM(revenue)::NUMERIC < 0
    ELSE TRUE
END;

-- Find named companies that do not exist in the company master table.
SELECT
    s.staging_id,
    s.company_name,
    s.fiscal_year
FROM stg_financial_statements AS s
LEFT JOIN companies AS c
    ON LOWER(TRIM(s.company_name)) = LOWER(c.legal_name)
WHERE NULLIF(TRIM(s.company_name), '') IS NOT NULL
  AND c.company_id IS NULL;
