-- Day 4: Reusable company-year financial metrics

CREATE OR REPLACE VIEW vw_company_financial_metrics AS
WITH financial_trends AS (
    SELECT
        company_id,
        fiscal_year,
        revenue,
        net_income,
        total_assets,
        total_liabilities,
        cash_flow_from_operations,
        LAG(revenue) OVER (
            PARTITION BY company_id
            ORDER BY fiscal_year
        ) AS previous_year_revenue
    FROM financial_statements
)
SELECT
    company_id,
    fiscal_year,
    revenue,
    net_income,
    previous_year_revenue,
    total_assets,
    total_liabilities,
    cash_flow_from_operations,
    ROUND(
        (revenue - previous_year_revenue)
        / NULLIF(previous_year_revenue, 0) * 100,
        2
    ) AS revenue_growth_pct,
    ROUND(
        net_income / NULLIF(revenue, 0) * 100,
        2
    ) AS net_margin_pct,
    ROUND(
        total_liabilities / NULLIF(total_assets, 0),
        4
    ) AS debt_to_asset_ratio,
    ROUND(
        cash_flow_from_operations / NULLIF(revenue, 0),
        4
    ) AS operating_cash_flow_margin
FROM financial_trends;
