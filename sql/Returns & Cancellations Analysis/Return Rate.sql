SET search_path TO shopkart;

-- ============================================================
-- Analysis 2: Return Rate
-- ============================================================

WITH order_base AS (

    SELECT
        COUNT(DISTINCT order_id) AS total_orders
    FROM vw_order_item_analysis
),

return_base AS (

    SELECT
        COUNT(DISTINCT order_id) AS returned_orders
    FROM returns
)

SELECT

    ob.total_orders,

    rb.returned_orders,

    ROUND(
        rb.returned_orders * 100.0
        / NULLIF(ob.total_orders, 0),
        2
    ) AS order_return_rate_percent

FROM order_base ob
CROSS JOIN return_base rb;