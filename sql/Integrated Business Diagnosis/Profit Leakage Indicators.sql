SET search_path TO shopkart;

-- ============================================================
-- Analysis 3: Profit Leakage Indicators
-- ============================================================

SELECT

    ROUND(SUM(discount_amount), 2)
        AS total_discount_given,

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

    ROUND(
        SUM(item_profit),
        2
    ) AS total_item_profit,

    ROUND(
        SUM(item_revenue),
        2
    ) AS total_revenue

FROM vw_order_item_analysis;