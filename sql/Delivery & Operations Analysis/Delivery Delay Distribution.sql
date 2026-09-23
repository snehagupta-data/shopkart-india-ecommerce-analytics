SET search_path TO shopkart;

-- ============================================================
-- Analysis 2: Delivery Delay Distribution
-- ============================================================

SELECT

    CASE
        WHEN delivery_delay_days < 0
            THEN 'Early Delivery'

        WHEN delivery_delay_days = 0
            THEN 'On Time'

        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN '1–2 Days Late'

        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN '3–5 Days Late'

        ELSE '6+ Days Late'
    END AS delay_band,

    COUNT(*) AS shipments,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS shipment_percentage

FROM shipments

GROUP BY
    CASE
        WHEN delivery_delay_days < 0
            THEN 'Early Delivery'

        WHEN delivery_delay_days = 0
            THEN 'On Time'

        WHEN delivery_delay_days BETWEEN 1 AND 2
            THEN '1–2 Days Late'

        WHEN delivery_delay_days BETWEEN 3 AND 5
            THEN '3–5 Days Late'

        ELSE '6+ Days Late'
    END

ORDER BY
    MIN(delivery_delay_days);