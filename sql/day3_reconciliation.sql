-- Day 3: Reconcile every staging row to a load or rejection outcome.

WITH staged_rows AS (
    SELECT
        s.*,
        c.company_id,
        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(s.company_name)), TRIM(s.fiscal_year)
            ORDER BY s.staging_id
        ) AS duplicate_rank
    FROM stg_financial_statements AS s
    LEFT JOIN companies AS c
        ON LOWER(TRIM(s.company_name)) = LOWER(c.legal_name)
)
SELECT
    staging_id,
    company_name,
    fiscal_year,
    CASE
        WHEN NULLIF(TRIM(company_name), '') IS NULL
            THEN 'rejected: missing_company'
        WHEN company_id IS NULL
            THEN 'rejected: unknown_company'
        WHEN NOT COALESCE(
            TRIM(fiscal_year) ~ '^[0-9]{4}$',
            FALSE
        )
            THEN 'rejected: invalid_year'
        WHEN TRIM(fiscal_year)::INTEGER NOT BETWEEN 1900 AND 2100
            THEN 'rejected: invalid_year'
        WHEN NOT COALESCE(
            TRIM(revenue) ~ '^-?[0-9]+(\.[0-9]+)?$',
            FALSE
        )
            THEN 'rejected: invalid_revenue'
        WHEN TRIM(revenue)::NUMERIC < 0
            THEN 'rejected: invalid_revenue'       
        WHEN NULLIF(TRIM(cash_flow_from_operations), '') IS NULL
            THEN 'rejected: missing_cash_flow'
        WHEN duplicate_rank > 1
            THEN 'rejected: duplicate'
        ELSE 'accepted'
    END AS load_status
FROM staged_rows
ORDER BY staging_id;

-- Reconciliation priority:
--   1. missing_company
--   2. unknown_company
--   3. invalid_year
--   4. invalid_revenue
--   5. missing_cash_flow
--   6. duplicate
--   7. accepted
