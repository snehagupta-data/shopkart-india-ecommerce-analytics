SET search_path TO shopkart;

-- ============================================================
-- Analysis 3: Warehouse Performance
-- ============================================================

SELECT

    w.warehouse_id,
    w.warehouse_name,
    w.city,
    w.state,
    w.warehouse_type,
    w.capacity_band,

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

INNER JOIN warehouses w
    ON sh.warehouse_id = w.warehouse_id

GROUP BY

    w.warehouse_id,
    w.warehouse_name,
    w.city,
    w.state,
    w.warehouse_type,
    w.capacity_band

ORDER BY delay_rate_percent DESC;