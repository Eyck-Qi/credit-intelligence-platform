WITH latest_financials AS (
    SELECT
        f.company_id,
        f.fiscal_year,
        f.revenue,
        f.net_income,
        f.total_assets,
        f.total_liabilities,
        f.cash_flow_from_operations,
        f.total_liabilities / NULLIF(f.total_assets, 0) AS debt_to_asset_ratio
    FROM financial_statements AS f
    WHERE f.fiscal_year = (
        SELECT MAX(fiscal_year)
        FROM financial_statements
    )
)
SELECT
    c.legal_name,
    lf.fiscal_year,
    lf.net_income,
    lf.cash_flow_from_operations,
    ROUND(lf.debt_to_asset_ratio, 4) AS debt_to_asset_ratio,
    CASE
        WHEN lf.net_income < 0 THEN 'loss'
        WHEN ROUND(lf.debt_to_asset_ratio, 4) > 0.70 THEN 'high_leverage'
        ELSE 'review'
    END AS risk_reason
FROM latest_financials AS lf
JOIN companies AS c USING (company_id)
WHERE lf.net_income < 0 OR lf.debt_to_asset_ratio > 0.70
ORDER BY lf.debt_to_asset_ratio DESC;

WITH company_risk_metrics AS (
    SELECT
        f.company_id,
        f.fiscal_year,
        f.net_income,
        f.cash_flow_from_operations / NULLIF(f.revenue, 0)
            AS operating_cash_flow_margin,
        f.total_liabilities / NULLIF(f.total_assets, 0)
            AS debt_to_asset_ratio
    FROM financial_statements AS f
    WHERE f.fiscal_year = (
        SELECT MAX(fiscal_year)
        FROM financial_statements
    )
)
SELECT
    c.legal_name,
    crm.fiscal_year,
    crm.net_income,
    ROUND(crm.operating_cash_flow_margin, 4) AS operating_cash_flow_margin,
    ROUND(crm.debt_to_asset_ratio, 4) AS debt_to_asset_ratio,
    CASE
        WHEN crm.net_income < 0 OR crm.debt_to_asset_ratio > 0.80 THEN 'high'
        WHEN crm.debt_to_asset_ratio > 0.70 OR crm.operating_cash_flow_margin < 0.05 THEN 'medium'
        ELSE 'low'
    END AS risk_level
FROM company_risk_metrics AS crm
JOIN companies AS c USING (company_id)
ORDER BY c.legal_name;
