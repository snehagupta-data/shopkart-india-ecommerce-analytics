SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — DELIVERY & OPERATIONS
-- Analysis 1: Overall Delivery Performance
-- ============================================================

SELECT

    COUNT(*) AS total_shipments,

    COUNT(*) FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    COUNT(*) FILTER (
        WHERE delivery_status <> 'Delivered'
    ) AS non_delivered_shipments,

    ROUND(
        COUNT(*) FILTER (
            WHERE delivery_status = 'Delivered'
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS delivery_success_rate,

    ROUND(AVG(delivery_delay_days), 2)
        AS avg_delay_days,

    ROUND(
        AVG(delivery_delay_days)
        FILTER (WHERE delivery_delay_days > 0),
        2
    ) AS avg_late_delivery_days,

    COUNT(*) FILTER (
        WHERE delivery_delay_days > 0
    ) AS delayed_shipments,

    ROUND(
        COUNT(*) FILTER (
            WHERE delivery_delay_days > 0
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_percent

FROM shipments;