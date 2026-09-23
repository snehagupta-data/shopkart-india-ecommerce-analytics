SET search_path TO shopkart;

-- ============================================================
-- Analysis 4: Category-Level Returns
-- ============================================================

SELECT

    p.category_id,
    cat.category_name,

    COUNT(DISTINCT r.return_id) AS total_returns,

    COUNT(DISTINCT r.order_item_id) AS returned_items,

    ROUND(SUM(r.refund_amount), 2) AS total_refund,

    ROUND(SUM(r.return_cost), 2) AS total_return_cost,

    ROUND(
        SUM(r.refund_amount) + SUM(r.return_cost),
        2
    ) AS total_financial_impact

FROM returns r

INNER JOIN products p
    ON r.product_id = p.product_id

INNER JOIN categories cat
    ON p.category_id = cat.category_id

GROUP BY
    p.category_id,
    cat.category_name

ORDER BY total_financial_impact DESC;