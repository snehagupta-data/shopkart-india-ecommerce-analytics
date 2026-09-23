SET search_path TO shopkart;

-- ============================================================
-- Analysis 3: High Discount / Low Profit Products
-- ============================================================

SELECT
    product_id,
    product_name,
    category_name,
    brand,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(discount_amount), 2) AS total_discount,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent

FROM vw_order_item_analysis

GROUP BY
    product_id,
    product_name,
    category_name,
    brand

HAVING
    SUM(discount_amount)
        / NULLIF(SUM(gross_merchandise_value), 0) >= 0.30

    AND

    SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) < 0.10

ORDER BY
    profit_margin_percent ASC,
    total_discount DESC;