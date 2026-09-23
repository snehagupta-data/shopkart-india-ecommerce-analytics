SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — INTEGRATED BUSINESS ANALYSIS
-- Analysis 1: Monthly Business Performance
-- ============================================================

SELECT

    DATE_TRUNC('month', order_date)::DATE AS month,

    COUNT(DISTINCT order_id) AS orders,

    COUNT(DISTINCT customer_id) AS customers,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(item_cost), 2) AS cost,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent,

    ROUND(SUM(discount_amount), 2) AS discount

FROM vw_order_item_analysis

GROUP BY
    DATE_TRUNC('month', order_date)

ORDER BY month;