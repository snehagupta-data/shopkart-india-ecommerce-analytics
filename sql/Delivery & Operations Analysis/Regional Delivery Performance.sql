SET search_path TO shopkart;

-- ============================================================
-- Analysis 5: Regional Delivery Performance
-- ============================================================

SELECT

    l.region,

    COUNT(sh.shipment_id) AS total_shipments,

    ROUND(AVG(sh.delivery_delay_days), 2)
        AS avg_delay_days,

    COUNT(*) FILTER (
        WHERE sh.delivery_delay_days > 0
    ) AS delayed_shipments,

    ROUND(
        COUNT(*) FILTER (
            WHERE sh.delivery_delay_days > 0
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_percent,

    ROUND(
        AVG(sh.delivery_delay_days)
        FILTER (WHERE sh.delivery_delay_days > 0),
        2
    ) AS avg_late_days

FROM shipments sh

INNER JOIN orders o
    ON sh.order_id = o.order_id

INNER JOIN locations l
    ON o.shipping_location_id = l.location_id

GROUP BY l.region

ORDER BY delay_rate_percent DESC;