SET search_path TO shopkart;

-- ============================================================
-- Analysis 6: Seller Return Performance
-- ============================================================

SELECT

    s.seller_id,
    s.seller_name,

    COUNT(DISTINCT r.return_id) AS total_returns,

    COUNT(DISTINCT r.order_item_id) AS returned_items,

    ROUND(SUM(r.refund_amount), 2) AS total_refund,

    ROUND(SUM(r.return_cost), 2) AS total_return_cost,

    ROUND(
        SUM(r.refund_amount) + SUM(r.return_cost),
        2
    ) AS total_financial_impact,

    ROUND(AVG(s.seller_rating), 2) AS seller_rating

FROM returns r

INNER JOIN order_items oi
    ON r.order_item_id = oi.order_item_id

INNER JOIN sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    s.seller_id,
    s.seller_name

ORDER BY total_financial_impact DESC;