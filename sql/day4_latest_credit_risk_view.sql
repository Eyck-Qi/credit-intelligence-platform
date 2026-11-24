
CREATE OR REPLACE VIEW vw_latest_credit_risk AS
WITH ranked_financials AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY company_id
            ORDER BY fiscal_year DESC
        ) AS recency_rank
    FROM vw_company_financial_metrics
)
SELECT
    rf.company_id,
    c.legal_name,
    c.industry,
    rf.fiscal_year,
    rf.revenue_growth_pct,
    rf.net_margin_pct,
    rf.debt_to_asset_ratio,
    rf.operating_cash_flow_margin,
    CASE
        WHEN rf.net_margin_pct < 0 OR rf.debt_to_asset_ratio > 0.80 THEN 'high'
        WHEN rf.debt_to_asset_ratio > 0.70
            OR rf.operating_cash_flow_margin < 0.05 THEN 'medium'
        ELSE 'low'
    END AS risk_level
FROM ranked_financials AS rf
JOIN companies AS c USING (company_id)
WHERE rf.recency_rank = 1;
