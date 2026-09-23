SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — PROFITABILITY ANALYSIS
-- Analysis 1: Category Profitability
-- ============================================================

SELECT
    category_name,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(item_cost), 2) AS cost,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent,

    ROUND(SUM(discount_amount), 2) AS total_discount

FROM vw_order_item_analysis

GROUP BY category_name

ORDER BY profit DESC;