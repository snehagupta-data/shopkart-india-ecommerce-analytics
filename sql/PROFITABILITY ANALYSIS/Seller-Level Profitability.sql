SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — PROFITABILITY ANALYSIS
-- Analysis 3: Seller-Level Profitability
-- ============================================================

SELECT
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type,

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

    ROUND(AVG(seller_rating), 2) AS seller_rating

FROM vw_order_item_analysis

GROUP BY
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type

ORDER BY profit DESC;

-- ============================================================
--Loss-making sellers
-- ============================================================

SET search_path TO shopkart;

-- Sellers generating negative total profit

SELECT
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type,

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

    ROUND(AVG(seller_rating), 2) AS seller_rating

FROM vw_order_item_analysis

GROUP BY
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type

HAVING SUM(item_profit) < 0

ORDER BY profit ASC;

-- ============================================================
--High-revenue but low-margin sellers
-- ============================================================
SET search_path TO shopkart;

-- High-volume sellers where revenue is strong
-- but profitability is weak

SELECT
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent,

    ROUND(SUM(discount_amount), 2) AS total_discount,

    ROUND(AVG(seller_rating), 2) AS seller_rating

FROM vw_order_item_analysis

GROUP BY
    seller_id,
    seller_name,
    seller_type,
    fulfillment_type

HAVING
    SUM(item_revenue) > 500000
    AND
    SUM(item_profit) / NULLIF(SUM(item_revenue), 0) < 0.10

ORDER BY revenue DESC;

-- ============================================================
--Top sellers by profit contribution
-- ============================================================

SET search_path TO shopkart;

-- Identify sellers contributing the most absolute profit

SELECT
    seller_id,
    seller_name,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent

FROM vw_order_item_analysis

GROUP BY
    seller_id,
    seller_name

ORDER BY profit DESC

LIMIT 15;