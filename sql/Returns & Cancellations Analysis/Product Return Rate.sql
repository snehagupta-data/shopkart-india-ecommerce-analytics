SET search_path TO shopkart;

-- ============================================================
-- Analysis 5: Product Return Rate
-- ============================================================

WITH product_orders AS (

    SELECT
        product_id,
        COUNT(DISTINCT order_item_id) AS sold_items
    FROM vw_order_item_analysis
    GROUP BY product_id

),

product_returns AS (

    SELECT
        product_id,
        COUNT(DISTINCT order_item_id) AS returned_items
    FROM returns
    GROUP BY product_id

)

SELECT

    po.product_id,

    p.product_name,

    cat.category_name,

    po.sold_items,

    COALESCE(pr.returned_items, 0) AS returned_items,

    ROUND(
        COALESCE(pr.returned_items, 0) * 100.0
        / NULLIF(po.sold_items, 0),
        2
    ) AS return_rate_percent

FROM product_orders po

INNER JOIN products p
    ON po.product_id = p.product_id

INNER JOIN categories cat
    ON p.category_id = cat.category_id

LEFT JOIN product_returns pr
    ON po.product_id = pr.product_id

ORDER BY return_rate_percent DESC;