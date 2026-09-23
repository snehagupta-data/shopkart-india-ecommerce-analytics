SET search_path TO shopkart;

-- ============================================================
-- Analysis 6: Delivery Delays vs Repeat Purchase Behavior
-- ============================================================

WITH customer_delivery AS (

    SELECT

        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            AVG(sh.delivery_delay_days),
            2
        ) AS avg_delivery_delay,

        COUNT(*) FILTER (
            WHERE sh.delivery_delay_days > 0
        ) AS delayed_orders

    FROM orders o

    INNER JOIN shipments sh
        ON o.order_id = sh.order_id

    GROUP BY o.customer_id
)

SELECT

    CASE
        WHEN avg_delivery_delay <= 0
            THEN 'No Average Delay'

        WHEN avg_delivery_delay <= 2
            THEN '1–2 Days Average Delay'

        WHEN avg_delivery_delay <= 5
            THEN '3–5 Days Average Delay'

        ELSE '6+ Days Average Delay'
    END AS delivery_experience,

    COUNT(*) AS customers,

    ROUND(
        AVG(total_orders),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        AVG(avg_delivery_delay),
        2
    ) AS avg_delay_days,

    ROUND(
        AVG(delayed_orders),
        2
    ) AS avg_delayed_orders

FROM customer_delivery

GROUP BY

    CASE
        WHEN avg_delivery_delay <= 0
            THEN 'No Average Delay'

        WHEN avg_delivery_delay <= 2
            THEN '1–2 Days Average Delay'

        WHEN avg_delivery_delay <= 5
            THEN '3–5 Days Average Delay'

        ELSE '6+ Days Average Delay'
    END

ORDER BY
    MIN(avg_delivery_delay);