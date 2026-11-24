SELECT
    system_recommendation,
    COUNT(*) AS application_count,
    SUM(requested_amount) AS total_requested_amount,
    ROUND(
        SUM(requested_amount)
        / NULLIF(
            (
                SELECT SUM(requested_amount)
                FROM vw_credit_decisions
            ),
            0
        ) * 100,
        2
    ) AS exposure_share_pct
FROM vw_credit_decisions
GROUP BY system_recommendation
ORDER BY
    CASE system_recommendation
        WHEN 'decline' THEN 1
        WHEN 'review' THEN 2
        WHEN 'approve' THEN 3
    END;
