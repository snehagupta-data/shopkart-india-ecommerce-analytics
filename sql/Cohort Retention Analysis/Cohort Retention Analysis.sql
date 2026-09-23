SET search_path TO shopkart;

-- ============================================================
-- SHOPKART INDIA — COHORT RETENTION
-- Monthly Customer Cohorts
-- ============================================================

WITH customer_orders AS (

    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS order_month
    FROM vw_order_item_analysis

),

first_purchase AS (

    SELECT
        customer_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_id

),

cohort_activity AS (

    SELECT
        co.customer_id,
        fp.cohort_month,
        co.order_month,

        (
            EXTRACT(YEAR FROM co.order_month)
            - EXTRACT(YEAR FROM fp.cohort_month)
        ) * 12
        +
        (
            EXTRACT(MONTH FROM co.order_month)
            - EXTRACT(MONTH FROM fp.cohort_month)
        ) AS month_number

    FROM customer_orders co

    INNER JOIN first_purchase fp
        ON co.customer_id = fp.customer_id
)

SELECT
    cohort_month,
    month_number,

    COUNT(DISTINCT customer_id) AS active_customers

FROM cohort_activity

GROUP BY
    cohort_month,
    month_number

ORDER BY
    cohort_month,
    month_number;
	
-- ============================================================
-- Retention Percentage
-- ============================================================

SET search_path TO shopkart;

WITH customer_orders AS (

    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS order_month
    FROM vw_order_item_analysis

),

first_purchase AS (

    SELECT
        customer_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_id

),

cohort_activity AS (

    SELECT
        co.customer_id,
        fp.cohort_month,
        co.order_month,

        (
            EXTRACT(YEAR FROM co.order_month)
            - EXTRACT(YEAR FROM fp.cohort_month)
        ) * 12
        +
        (
            EXTRACT(MONTH FROM co.order_month)
            - EXTRACT(MONTH FROM fp.cohort_month)
        ) AS month_number

    FROM customer_orders co

    INNER JOIN first_purchase fp
        ON co.customer_id = fp.customer_id
),

cohort_counts AS (

    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    GROUP BY
        cohort_month,
        month_number
),

cohort_size AS (

    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)

SELECT
    cc.cohort_month,
    cc.month_number,

    cc.active_customers,

    cs.cohort_customers,

    ROUND(
        cc.active_customers * 100.0
        / NULLIF(cs.cohort_customers, 0),
        2
    ) AS retention_percent

FROM cohort_counts cc

INNER JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month

ORDER BY
    cc.cohort_month,
    cc.month_number;