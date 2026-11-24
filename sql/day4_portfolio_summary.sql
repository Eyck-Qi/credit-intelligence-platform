
SELECT
    risk_level,
    COUNT(*) AS company_count,
    ROUND(
        AVG(debt_to_asset_ratio),
        4
    ) AS avg_debt_to_asset_ratio,
    ROUND(
        AVG(net_margin_pct),
        2
    ) AS avg_net_margin_pct,
    ROUND(
        AVG(operating_cash_flow_margin),
        4
    ) AS avg_operating_cash_flow_margin
FROM vw_latest_credit_risk
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'high' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'low' THEN 3
    END;
