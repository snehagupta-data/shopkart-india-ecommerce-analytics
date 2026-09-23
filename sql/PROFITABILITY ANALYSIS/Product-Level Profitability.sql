SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — PROFITABILITY ANALYSIS
-- Analysis 2: Product-Level Profitability
-- ============================================================

SELECT
    product_id,
    product_name,
    category_name,
    brand,

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

    ROUND(SUM(discount_amount), 2) AS total_discount,

    ROUND(
        SUM(discount_amount)
        / NULLIF(SUM(gross_merchandise_value), 0) * 100,
        2
    ) AS discount_rate

FROM vw_order_item_analysis

GROUP BY
    product_id,
    product_name,
    category_name,
    brand

ORDER BY profit DESC;


-- ============================================================
--Loss-making products
-- ============================================================
SELECT
    product_id,
    product_name,
    category_name,
    brand,

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

GROUP BY
    product_id,
    product_name,
    category_name,
    brand

HAVING SUM(item_profit) < 0

ORDER BY profit ASC;

-- ============================================================
--High-revenue but low-margin products
-- ============================================================

SELECT
    product_id,
    product_name,
    category_name,
    brand,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent,

    ROUND(SUM(discount_amount), 2) AS total_discount

FROM vw_order_item_analysis

GROUP BY
    product_id,
    product_name,
    category_name,
    brand

HAVING
    SUM(item_revenue) > 100000
    AND
    SUM(item_profit) / NULLIF(SUM(item_revenue), 0) < 0.10

ORDER BY revenue DESC;
