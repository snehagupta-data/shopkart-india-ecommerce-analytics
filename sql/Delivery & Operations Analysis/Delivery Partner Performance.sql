SET search_path TO shopkart;

-- ============================================================
-- Analysis 4: Delivery Partner Performance
-- ============================================================

SELECT

    dp.delivery_partner_id,
    dp.delivery_partner_name,
    dp.partner_type,
    dp.service_region,

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

    ROUND(AVG(dp.partner_rating), 2)
        AS partner_rating

FROM shipments sh

INNER JOIN delivery_partners dp
    ON sh.delivery_partner_id = dp.delivery_partner_id

GROUP BY

    dp.delivery_partner_id,
    dp.delivery_partner_name,
    dp.partner_type,
    dp.service_region

ORDER BY delay_rate_percent DESC;