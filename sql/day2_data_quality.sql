SELECT
    company_id,
    fiscal_year,
    cash_flow_from_operations
FROM financial_statements
WHERE cash_flow_from_operations IS NULL;

SELECT
    company_id,
    fiscal_year,
    COUNT(*) AS record_count
FROM financial_statements
GROUP BY company_id, fiscal_year
HAVING COUNT(*) > 1;

SELECT
    company_id,
    fiscal_year,
    revenue,
    net_income,
    total_assets,
    total_liabilities
FROM financial_statements
WHERE total_liabilities > total_assets
   OR revenue = 0;
