-- Day 6: Explainable credit decision engine

-- Goal: combine each loan application with its company, existing assessment,
-- and latest financial risk metrics before generating a system decision.

CREATE OR REPLACE VIEW vw_credit_decisions AS
WITH application_context AS (
    SELECT
        la.application_id,
        la.company_id,
        la.requested_amount,
        la.loan_purpose,
        la.term_months,
        la.application_status,
        c.legal_name,
        c.industry,
        ca.credit_score,
        ca.risk_grade,
        ca.recommendation AS assessment_recommendation,
        vr.fiscal_year,
        vr.revenue_growth_pct,
        vr.net_margin_pct,
        vr.debt_to_asset_ratio,
        vr.operating_cash_flow_margin,
        vr.risk_level
    FROM loan_applications AS la
    JOIN companies AS c USING (company_id)
    JOIN credit_assessments AS ca USING (application_id)
    JOIN vw_latest_credit_risk AS vr USING (company_id)
),
decision_results AS (
    SELECT
        ac.*,
        -- Apply the most severe matching decision rule first.
        CASE
            WHEN ac.risk_level = 'high'
                OR ac.credit_score < 50
                OR ac.risk_grade IN ('D', 'E')
                THEN 'decline'
            WHEN ac.risk_level = 'medium'
                OR ac.credit_score < 70
                OR ac.risk_grade = 'C'
                THEN 'review'
            ELSE 'approve'
        END AS system_recommendation,
        -- Return the primary reason associated with the first matching rule.
        CASE
            WHEN ac.risk_level = 'high'
                THEN 'High financial risk based on latest financial metrics'
            WHEN ac.credit_score < 50
                THEN 'Credit score is below the minimum threshold'
            WHEN ac.risk_grade IN ('D', 'E')
                THEN 'Risk grade is below the acceptable threshold'
            WHEN ac.risk_level = 'medium'
                THEN 'Medium financial risk requires manual review'
            WHEN ac.credit_score < 70
                THEN 'Credit score requires manual review'
            WHEN ac.risk_grade = 'C'
                THEN 'Risk grade C requires manual review'
            ELSE 'Low financial risk and strong credit profile'
        END AS decision_reason
    FROM application_context AS ac
)
SELECT
    dr.*,
    dr.assessment_recommendation = dr.system_recommendation
        AS decision_matches_assessment
FROM decision_results AS dr;
