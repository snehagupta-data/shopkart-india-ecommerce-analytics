SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — RETURNS & CANCELLATIONS
-- Analysis 1: Overall Returns Snapshot
-- ============================================================

SELECT

    COUNT(DISTINCT r.return_id) AS total_returns,

    COUNT(DISTINCT r.order_id) AS orders_with_returns,

    COUNT(DISTINCT r.order_item_id) AS returned_items,

    ROUND(SUM(r.refund_amount), 2) AS total_refund_amount,

    ROUND(SUM(r.return_cost), 2) AS total_return_cost,

    ROUND(
        SUM(r.refund_amount) + SUM(r.return_cost),
        2
    ) AS total_return_impact

FROM returns r;