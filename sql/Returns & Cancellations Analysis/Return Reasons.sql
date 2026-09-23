SET search_path TO shopkart;

-- ============================================================
-- Analysis 3: Return Reasons
-- ============================================================

SELECT

    return_reason,

    COUNT(*) AS return_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS return_percentage,

    ROUND(SUM(refund_amount), 2) AS total_refund,

    ROUND(SUM(return_cost), 2) AS total_return_cost,

    ROUND(
        SUM(refund_amount) + SUM(return_cost),
        2
    ) AS total_financial_impact,

    ROUND(AVG(refund_amount), 2) AS avg_refund_amount

FROM returns

GROUP BY return_reason

ORDER BY total_financial_impact DESC;