-- ============================================================
-- SHOPKART INDIA
-- ANALYTICAL DATA LAYER
-- STEP 3A: MAIN ORDER ITEM ANALYSIS VIEW
-- ============================================================

SET search_path TO shopkart;

-- ------------------------------------------------------------
-- Remove existing view if it already exists
-- ------------------------------------------------------------

DROP VIEW IF EXISTS vw_order_item_analysis;


-- ============================================================
-- CREATE MAIN ANALYTICAL VIEW
-- ============================================================

CREATE VIEW vw_order_item_analysis AS

SELECT

    -- ========================================================
    -- ORDER INFORMATION
    -- ========================================================

    o.order_id,
    o.order_date,
    o.order_status,
    o.order_channel,

    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    c.customer_id,
    c.gender,
    c.date_of_birth,
    c.customer_segment,
    c.acquisition_channel,

    -- Customer location
    cl.location_id AS customer_location_id,
    cl.city AS customer_city,
    cl.state AS customer_state,
    cl.region AS customer_region,
    cl.city_tier AS customer_city_tier,

    -- ========================================================
    -- PRODUCT INFORMATION
    -- ========================================================

    p.product_id,
    p.product_name,
    p.brand,
    p.category_id,
    cat.category_name,
    cat.subcategory_name,

    -- ========================================================
    -- SELLER INFORMATION
    -- ========================================================

    s.seller_id,
    s.seller_name,
    s.seller_type,
    s.fulfillment_type,
    s.seller_rating,

    -- ========================================================
    -- ORDER ITEM INFORMATION
    -- ========================================================

    oi.order_item_id,
    oi.quantity,

    oi.unit_list_price,
    oi.unit_selling_price,

    oi.discount_percent,
    oi.discount_amount,

    oi.product_cost,

    oi.item_revenue,
    oi.item_cost,
    oi.item_profit,

    -- ========================================================
    -- DERIVED PROFITABILITY METRICS
    -- ========================================================

    CASE
        WHEN oi.item_revenue > 0
        THEN ROUND(
            oi.item_profit / oi.item_revenue * 100,
            2
        )
        ELSE 0
    END AS profit_margin_percent,

    -- Gross merchandise value before discount
    ROUND(
        oi.quantity * oi.unit_list_price,
        2
    ) AS gross_merchandise_value,

    -- Discount rate based on actual transaction values
    CASE
        WHEN oi.quantity * oi.unit_list_price > 0
        THEN ROUND(
            oi.discount_amount /
            (oi.quantity * oi.unit_list_price) * 100,
            2
        )
        ELSE 0
    END AS calculated_discount_percent,

    -- ========================================================
    -- CUSTOMER ORDER SEQUENCE
    -- ========================================================
    -- Helps identify first-time vs repeat purchasing.

    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date, o.order_id
    ) AS customer_order_number

FROM orders o

INNER JOIN customers c
    ON o.customer_id = c.customer_id

INNER JOIN order_items oi
    ON o.order_id = oi.order_id

INNER JOIN products p
    ON oi.product_id = p.product_id

INNER JOIN categories cat
    ON p.category_id = cat.category_id

INNER JOIN sellers s
    ON oi.seller_id = s.seller_id

LEFT JOIN locations cl
    ON c.location_id = cl.location_id;


-- ============================================================
-- TEST THE VIEW
-- ============================================================

SELECT *
FROM vw_order_item_analysis
LIMIT 20;