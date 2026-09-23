SET search_path TO shopkart;

-- ============================================================
-- Analysis 2: Monthly Returns Trend
-- ============================================================

SELECT

    DATE_TRUNC('month', return_date)::DATE AS month,

    COUNT(DISTINCT return_id) AS returns,

    COUNT(DISTINCT order_id) AS affected_orders,

    ROUND(SUM(refund_amount), 2) AS refunds,

    ROUND(SUM(return_cost), 2) AS return_cost,

    ROUND(
        SUM(refund_amount) + SUM(return_cost),
        2
    ) AS total_return_impact

FROM returns

GROUP BY
    DATE_TRUNC('month', return_date)

ORDER BY month;