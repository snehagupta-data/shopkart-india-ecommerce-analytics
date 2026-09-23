SET search_path TO shopkart;

-- ============================================================
-- Analysis 4: Negative Profit by Category
-- ============================================================

SELECT

    category_name,

    COUNT(DISTINCT product_id) AS products,

    SUM(quantity) AS units_sold,

    ROUND(SUM(item_revenue), 2) AS revenue,

    ROUND(
        SUM(
            CASE
                WHEN item_profit < 0
                THEN ABS(item_profit)
                ELSE 0
            END
        ),
        2
    ) AS negative_profit_exposure,

    COUNT(*) FILTER (
        WHERE item_profit < 0
    ) AS loss_making_items

FROM vw_order_item_analysis

GROUP BY category_name

HAVING
    COUNT(*) FILTER (
        WHERE item_profit < 0
    ) > 0

ORDER BY negative_profit_exposure DESC;