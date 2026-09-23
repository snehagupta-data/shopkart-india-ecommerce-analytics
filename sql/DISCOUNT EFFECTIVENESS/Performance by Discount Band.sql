SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — DISCOUNT EFFECTIVENESS
-- Analysis 1: Performance by Discount Band
-- ============================================================

SELECT
    CASE
        WHEN discount_percent = 0 THEN '0% — No Discount'
        WHEN discount_percent <= 10 THEN '1–10%'
        WHEN discount_percent <= 20 THEN '11–20%'
        WHEN discount_percent <= 30 THEN '21–30%'
        WHEN discount_percent <= 40 THEN '31–40%'
        ELSE '40%+'
    END AS discount_band,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(SUM(discount_amount), 2) AS total_discount,

    ROUND(SUM(item_profit), 2) AS profit,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent,

    ROUND(
        SUM(discount_amount)
        / NULLIF(SUM(gross_merchandise_value), 0) * 100,
        2
    ) AS effective_discount_rate

FROM vw_order_item_analysis

GROUP BY
    CASE
        WHEN discount_percent = 0 THEN '0% — No Discount'
        WHEN discount_percent <= 10 THEN '1–10%'
        WHEN discount_percent <= 20 THEN '11–20%'
        WHEN discount_percent <= 30 THEN '21–30%'
        WHEN discount_percent <= 40 THEN '31–40%'
        ELSE '40%+'
    END

ORDER BY
    MIN(discount_percent);