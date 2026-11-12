-- Day 2: Multi-year financial trend analysis

-- Calculate year-over-year revenue growth and key financial ratios.
WITH financial_trends AS (
    SELECT
        company_id,
        fiscal_year,
        revenue,
        net_income,
        total_assets,
        total_liabilities,
        LAG(revenue) OVER (
            PARTITION BY company_id
            ORDER BY fiscal_year
        ) AS previous_year_revenue
    FROM financial_statements
)
-- Show current and prior-year net income by company.
SELECT
    c.legal_name,
    ft.fiscal_year,
    ft.revenue,
    ft.previous_year_revenue,
    ROUND(
        (ft.revenue - ft.previous_year_revenue)
        / NULLIF(ft.previous_year_revenue, 0) * 100,
        2
    ) AS revenue_growth_pct,
    ROUND(ft.net_income / NULLIF(ft.revenue, 0) * 100, 2) AS net_margin_pct,
    ROUND(ft.total_liabilities / NULLIF(ft.total_assets, 0), 4)
        AS debt_to_asset_ratio
FROM financial_trends AS ft
JOIN companies AS c USING (company_id)
ORDER BY c.legal_name, ft.fiscal_year;

SELECT
    company_id,
    fiscal_year,
    net_income,
    LAG(net_income) OVER (
        PARTITION BY company_id
        ORDER BY fiscal_year
    ) AS previous_year_net_income
FROM financial_statements
ORDER BY company_id, fiscal_year;

-- Calculate net income changes and classify the profit trend.
WITH net_income_trends AS (
    SELECT
        company_id,
        fiscal_year,
        net_income,
        LAG(net_income) OVER (
            PARTITION BY company_id
            ORDER BY fiscal_year
        ) AS previous_year_net_income
    FROM financial_statements
)
SELECT
    c.legal_name,
    nit.fiscal_year,
    nit.net_income,
    nit.previous_year_net_income,
    (nit.net_income - nit.previous_year_net_income) AS net_income_change,
    CASE
        WHEN nit.previous_year_net_income IS NULL THEN 'no_prior_year'
        WHEN (nit.net_income - nit.previous_year_net_income) > 0 THEN 'improving'
        WHEN (nit.net_income - nit.previous_year_net_income) < 0 THEN 'deteriorating'
        ELSE 'stable'
    END AS profit_trend
FROM net_income_trends AS nit
JOIN companies AS c USING (company_id)
ORDER BY c.legal_name, nit.fiscal_year;
