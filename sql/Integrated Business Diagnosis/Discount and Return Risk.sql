SET search_path TO shopkart;

-- ============================================================
-- Analysis 5: Discount + Return Risk
-- ============================================================

WITH product_sales AS (

    SELECT

        product_id,

        product_name,

        category_name,

        SUM(quantity) AS units_sold,

        ROUND(SUM(item_revenue), 2) AS revenue,

        ROUND(SUM(discount_amount), 2) AS discount,

        ROUND(SUM(item_profit), 2) AS profit,

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

        ROUND(SUM(refund_amount), 2) AS refunds,

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

    ps.discount,

    ps.discount_rate,

    ps.profit,

    COALESCE(pr.returns, 0) AS returns,

    COALESCE(pr.refunds, 0) AS refunds,

    COALESCE(pr.return_cost, 0) AS return_cost,

    ROUND(
        COALESCE(pr.returns, 0) * 100.0
        / NULLIF(ps.units_sold, 0),
        2
    ) AS return_rate_percent

FROM product_sales ps

LEFT JOIN product_returns pr
    ON ps.product_id = pr.product_id

WHERE

    ps.discount_rate >= 20

    AND

    COALESCE(pr.returns, 0) > 0

ORDER BY

    return_rate_percent DESC,
    ps.discount_rate DESC;