SET search_path TO shopkart;

-- ============================================================
-- Analysis 6: Product Risk Prioritization
-- ============================================================

WITH product_sales AS (

    SELECT

        product_id,
        product_name,
        category_name,

        SUM(quantity) AS units_sold,

        ROUND(SUM(item_revenue), 2) AS revenue,

        ROUND(SUM(item_profit), 2) AS profit,

        ROUND(
            SUM(item_profit)
            / NULLIF(SUM(item_revenue), 0) * 100,
            2
        ) AS profit_margin,

        ROUND(
            SUM(discount_amount)
            / NULLIF(SUM(gross_merchandise_value), 0) * 100,
            2
        ) AS discount_rate

    FROM vw_order_item_analysis

    GROUP BY

        product_id,
        product_name,
        category_name
),

product_returns AS (

    SELECT

        product_id,

        COUNT(DISTINCT return_id) AS returns,

        ROUND(SUM(return_cost), 2) AS return_cost

    FROM returns

    GROUP BY product_id
)

SELECT

    ps.product_id,

    ps.product_name,

    ps.category_name,

    ps.units_sold,

    ps.revenue,

    ps.profit,

    ps.profit_margin,

    ps.discount_rate,

    COALESCE(pr.returns, 0) AS returns,

    ROUND(
        COALESCE(pr.returns, 0) * 100.0
        / NULLIF(ps.units_sold, 0),
        2
    ) AS return_rate,

    (
        CASE
            WHEN ps.profit_margin < 5 THEN 2
            WHEN ps.profit_margin < 10 THEN 1
            ELSE 0
        END

        +

        CASE
            WHEN ps.discount_rate >= 30 THEN 2
            WHEN ps.discount_rate >= 20 THEN 1
            ELSE 0
        END

        +

        CASE
            WHEN
                COALESCE(pr.returns, 0) * 100.0
                / NULLIF(ps.units_sold, 0) >= 20
                THEN 2

            WHEN
                COALESCE(pr.returns, 0) * 100.0
                / NULLIF(ps.units_sold, 0) >= 10
                THEN 1

            ELSE 0
        END

    ) AS business_risk_score

FROM product_sales ps

LEFT JOIN product_returns pr

    ON ps.product_id = pr.product_id

WHERE ps.units_sold >= 10

ORDER BY business_risk_score DESC, revenue DESC;