SELECT
    c.legal_name,
    c.industry,
    f.fiscal_year,
    f.revenue,
    f.net_income,
    ROUND(f.total_liabilities / NULLIF(f.total_assets, 0), 4) AS debt_to_asset_ratio,
    l.requested_amount,
    l.loan_purpose,
    a.credit_score,
    a.risk_grade,
    a.recommendation
FROM companies AS c
JOIN financial_statements AS f USING (company_id)
JOIN loan_applications AS l USING (company_id)
JOIN credit_assessments AS a USING (application_id)
ORDER BY a.credit_score DESC;

SELECT
    a.recommendation,
    COUNT(*) AS application_count,
    SUM(l.requested_amount) AS total_requested_amount,
    ROUND(AVG(a.credit_score), 1) AS average_credit_score
FROM loan_applications AS l
JOIN credit_assessments AS a USING (application_id)
GROUP BY a.recommendation
ORDER BY total_requested_amount DESC;
