SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — CUSTOMER ANALYTICS
-- Step 1: Customer Purchase Summary
-- ============================================================

DROP VIEW IF EXISTS vw_customer_summary;

CREATE VIEW vw_customer_summary AS

SELECT
    customer_id,

    MIN(order_date) AS first_order_date,

    MAX(order_date) AS last_order_date,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS total_units,

    ROUND(SUM(item_revenue), 2) AS total_revenue,

    ROUND(SUM(item_profit), 2) AS total_profit,

    ROUND(SUM(discount_amount), 2) AS total_discount,

    ROUND(
        SUM(item_profit)
        / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percent

FROM vw_order_item_analysis

GROUP BY customer_id;


-- ============================================================
-- Step 2: New vs Repeat Customers
-- ============================================================

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue,

    ROUND(AVG(total_profit), 2) AS avg_customer_profit

FROM vw_customer_summary

GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END

ORDER BY customers DESC;

-- ============================================================
-- Step 3: Customer Value Segmentation
-- ============================================================

SELECT
    CASE
        WHEN total_revenue >= 50000 THEN 'High Value'
        WHEN total_revenue >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value_segment,

    COUNT(*) AS customers,

    ROUND(SUM(total_revenue), 2) AS revenue,

    ROUND(SUM(total_profit), 2) AS profit,

    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,

    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue

FROM vw_customer_summary

GROUP BY
    CASE
        WHEN total_revenue >= 50000 THEN 'High Value'
        WHEN total_revenue >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END

ORDER BY revenue DESC;

-- ============================================================
-- Step 4: RFM Base Metrics
-- ============================================================

DROP VIEW IF EXISTS vw_customer_rfm;

CREATE VIEW vw_customer_rfm AS

SELECT
    customer_id,

    (
        SELECT MAX(order_date)
        FROM vw_order_item_analysis
    )
    - last_order_date AS recency_days,

    total_orders AS frequency,

    total_revenue AS monetary,

    total_profit,

    total_discount

FROM vw_customer_summary;

-- ============================================================
-- Step 5: RFM Scoring
-- ============================================================

DROP VIEW IF EXISTS vw_customer_rfm_scored;

CREATE VIEW vw_customer_rfm_scored AS

SELECT
    customer_id,

    recency_days,
    frequency,
    monetary,

    total_profit,
    total_discount,

    NTILE(5) OVER (
        ORDER BY recency_days DESC
    ) AS recency_score,

    NTILE(5) OVER (
        ORDER BY frequency
    ) AS frequency_score,

    NTILE(5) OVER (
        ORDER BY monetary
    ) AS monetary_score

FROM vw_customer_rfm;
-- ============================================================
-- Step 6: Final RFM Segment
-- ============================================================
SELECT
    customer_id,

    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,

    recency_score,
    frequency_score,
    monetary_score,

    CASE
        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'

        WHEN recency_score >= 4
             AND frequency_score >= 3
            THEN 'Loyal Customers'

        WHEN recency_score >= 4
             AND frequency_score <= 2
            THEN 'New / Promising'

        WHEN recency_score <= 2
             AND frequency_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Lost / Dormant'

        ELSE 'Potential Loyalists'
    END AS rfm_segment

FROM vw_customer_rfm_scored

ORDER BY monetary DESC;

-- ============================================================
-- Step 7: RFM Segment Business Value
-- ============================================================

WITH rfm_segments AS (

    SELECT
        customer_id,

        recency_days,
        frequency,
        monetary,
        total_profit,

        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 4
                 AND frequency_score >= 3
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
                 AND frequency_score <= 2
                THEN 'New / Promising'

            WHEN recency_score <= 2
                 AND frequency_score >= 3
                THEN 'At Risk'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                THEN 'Lost / Dormant'

            ELSE 'Potential Loyalists'
        END AS rfm_segment

    FROM vw_customer_rfm_scored
)

SELECT
    rfm_segment,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(SUM(monetary), 2) AS total_revenue,

    ROUND(SUM(total_profit), 2) AS total_profit,

    ROUND(AVG(monetary), 2) AS avg_customer_revenue,

    ROUND(AVG(frequency), 2) AS avg_orders_per_customer,

    ROUND(AVG(recency_days), 2) AS avg_recency_days

FROM rfm_segments

GROUP BY rfm_segment

ORDER BY total_revenue DESC;

-- ============================================================
-- Revenue and Profit Associated with At-Risk / Dormant Customers
-- ============================================================

WITH rfm_segments AS (

    SELECT
        customer_id,
        monetary,
        total_profit,

        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 4
                 AND frequency_score >= 3
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
                 AND frequency_score <= 2
                THEN 'New / Promising'

            WHEN recency_score <= 2
                 AND frequency_score >= 3
                THEN 'At Risk'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                THEN 'Lost / Dormant'

            ELSE 'Potential Loyalists'
        END AS rfm_segment

    FROM vw_customer_rfm_scored
)

SELECT
    rfm_segment,

    COUNT(*) AS customers,

    ROUND(SUM(monetary), 2) AS historical_revenue,

    ROUND(SUM(total_profit), 2) AS historical_profit,

    ROUND(
        SUM(monetary) * 100.0
        / SUM(SUM(monetary)) OVER (),
        2
    ) AS revenue_share_percent

FROM rfm_segments

GROUP BY rfm_segment

ORDER BY historical_revenue DESC;
