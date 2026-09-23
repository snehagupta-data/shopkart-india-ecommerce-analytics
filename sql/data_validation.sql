-- ============================================================
-- SHOPKART INDIA E-COMMERCE ANALYTICS
-- DATA QUALITY & VALIDATION SCRIPT
-- PostgreSQL / pgAdmin
-- ============================================================
--
-- PURPOSE:
--   Validate the imported ShopKart dataset before analysis.
--
-- IMPORTANT:
--   This script is READ-ONLY.
--   It does NOT UPDATE, DELETE, or MODIFY any data.
--
-- VALIDATION AREAS:
--   1. Row counts
--   2. Primary-key duplicates
--   3. Foreign-key integrity
--   4. NULL / missing values
--   5. Invalid numeric values
--   6. Invalid ratings
--   7. Invalid dates
--   8. Order-item calculations
--   9. Order-total reconciliation
--  10. Payment reconciliation
--  11. Shipment validation
--  12. Return validation
--  13. Seller/product consistency
--  14. Business-rule anomalies
--
-- EXPECTED RESULT:
--   Most validation queries should return 0 rows.
--   Some "business anomaly" queries may legitimately return rows.
--
-- ============================================================


-- ============================================================
-- 0. SET SCHEMA
-- ============================================================

SET search_path TO shopkart;


-- ============================================================
-- SECTION 1: TABLE ROW COUNTS
-- ============================================================
-- Purpose:
-- Confirm that all 12 tables contain data.
--
-- This is the first check after importing CSVs.
-- ============================================================

SELECT 'categories' AS table_name, COUNT(*) AS row_count
FROM categories

UNION ALL

SELECT 'locations', COUNT(*)
FROM locations

UNION ALL

SELECT 'warehouses', COUNT(*)
FROM warehouses

UNION ALL

SELECT 'delivery_partners', COUNT(*)
FROM delivery_partners

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'shipments', COUNT(*)
FROM shipments

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns

ORDER BY table_name;


-- ============================================================
-- SECTION 2: PRIMARY KEY DUPLICATE CHECKS
-- ============================================================
-- Purpose:
-- Every primary key must be unique.
--
-- EXPECTED:
-- All queries should return 0 rows.
-- ============================================================


-- 2.1 Categories

SELECT category_id, COUNT(*) AS duplicate_count
FROM categories
GROUP BY category_id
HAVING COUNT(*) > 1;


-- 2.2 Locations

SELECT location_id, COUNT(*) AS duplicate_count
FROM locations
GROUP BY location_id
HAVING COUNT(*) > 1;


-- 2.3 Warehouses

SELECT warehouse_id, COUNT(*) AS duplicate_count
FROM warehouses
GROUP BY warehouse_id
HAVING COUNT(*) > 1;


-- 2.4 Delivery Partners

SELECT delivery_partner_id, COUNT(*) AS duplicate_count
FROM delivery_partners
GROUP BY delivery_partner_id
HAVING COUNT(*) > 1;


-- 2.5 Sellers

SELECT seller_id, COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- 2.6 Products

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 2.7 Customers

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 2.8 Orders

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 2.9 Order Items

SELECT order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;


-- 2.10 Payments

SELECT payment_id, COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- 2.11 Shipments

SELECT shipment_id, COUNT(*) AS duplicate_count
FROM shipments
GROUP BY shipment_id
HAVING COUNT(*) > 1;


-- 2.12 Returns

SELECT return_id, COUNT(*) AS duplicate_count
FROM returns
GROUP BY return_id
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 3: FOREIGN KEY INTEGRITY
-- ============================================================
-- Purpose:
-- Check whether child-table IDs actually exist in parent tables.
--
-- EXPECTED:
-- All queries should return 0 rows.
-- ============================================================


-- 3.1 Products → Categories

SELECT
    p.product_id,
    p.category_id
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
WHERE c.category_id IS NULL;


-- 3.2 Products → Sellers

SELECT
    p.product_id,
    p.seller_id
FROM products p
LEFT JOIN sellers s
    ON p.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- 3.3 Customers → Locations

SELECT
    c.customer_id,
    c.location_id
FROM customers c
LEFT JOIN locations l
    ON c.location_id = l.location_id
WHERE l.location_id IS NULL;


-- 3.4 Sellers → Locations

SELECT
    s.seller_id,
    s.seller_location_id
FROM sellers s
LEFT JOIN locations l
    ON s.seller_location_id = l.location_id
WHERE l.location_id IS NULL;


-- 3.5 Warehouses → Locations

SELECT
    w.warehouse_id,
    w.location_id
FROM warehouses w
LEFT JOIN locations l
    ON w.location_id = l.location_id
WHERE l.location_id IS NULL;


-- 3.6 Orders → Customers

SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 3.7 Orders → Shipping Location

SELECT
    o.order_id,
    o.shipping_location_id
FROM orders o
LEFT JOIN locations l
    ON o.shipping_location_id = l.location_id
WHERE l.location_id IS NULL;


-- 3.8 Orders → Warehouse

SELECT
    o.order_id,
    o.warehouse_id
FROM orders o
LEFT JOIN warehouses w
    ON o.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL;


-- 3.9 Order Items → Orders

SELECT
    oi.order_item_id,
    oi.order_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 3.10 Order Items → Products

SELECT
    oi.order_item_id,
    oi.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 3.11 Order Items → Sellers

SELECT
    oi.order_item_id,
    oi.seller_id
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- 3.12 Payments → Orders

SELECT
    p.payment_id,
    p.order_id
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 3.13 Shipments → Orders

SELECT
    s.shipment_id,
    s.order_id
FROM shipments s
LEFT JOIN orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 3.14 Shipments → Warehouses

SELECT
    s.shipment_id,
    s.warehouse_id
FROM shipments s
LEFT JOIN warehouses w
    ON s.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL;


-- 3.15 Shipments → Delivery Partners

SELECT
    s.shipment_id,
    s.delivery_partner_id
FROM shipments s
LEFT JOIN delivery_partners dp
    ON s.delivery_partner_id = dp.delivery_partner_id
WHERE dp.delivery_partner_id IS NULL;


-- 3.16 Returns → Orders

SELECT
    r.return_id,
    r.order_id
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 3.17 Returns → Order Items

SELECT
    r.return_id,
    r.order_item_id
FROM returns r
LEFT JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;


-- 3.18 Returns → Products

SELECT
    r.return_id,
    r.product_id
FROM returns r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- SECTION 4: NULL / MISSING VALUE AUDIT
-- ============================================================
-- Purpose:
-- Identify important columns containing NULL values.
--
-- NULLs are not automatically errors.
-- We investigate them based on business meaning.
-- ============================================================


-- 4.1 Customers

SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS registration_date_nulls,
    COUNT(*) FILTER (WHERE location_id IS NULL) AS location_id_nulls,
    COUNT(*) FILTER (WHERE gender IS NULL) AS gender_nulls,
    COUNT(*) FILTER (WHERE date_of_birth IS NULL) AS dob_nulls
FROM customers;


-- 4.2 Products

SELECT
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
    COUNT(*) FILTER (WHERE product_name IS NULL) AS product_name_nulls,
    COUNT(*) FILTER (WHERE category_id IS NULL) AS category_id_nulls,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulls,
    COUNT(*) FILTER (WHERE product_cost IS NULL) AS product_cost_nulls,
    COUNT(*) FILTER (WHERE list_price IS NULL) AS list_price_nulls
FROM products;


-- 4.3 Orders

SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulls,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS status_nulls,
    COUNT(*) FILTER (WHERE order_total IS NULL) AS order_total_nulls
FROM orders;


-- 4.4 Order Items

SELECT
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS item_id_nulls,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulls,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulls,
    COUNT(*) FILTER (WHERE item_revenue IS NULL) AS revenue_nulls,
    COUNT(*) FILTER (WHERE item_cost IS NULL) AS cost_nulls,
    COUNT(*) FILTER (WHERE item_profit IS NULL) AS profit_nulls
FROM order_items;


-- 4.5 Payments

SELECT
    COUNT(*) FILTER (WHERE payment_id IS NULL) AS payment_id_nulls,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE payment_date IS NULL) AS payment_date_nulls,
    COUNT(*) FILTER (WHERE payment_amount IS NULL) AS payment_amount_nulls
FROM payments;


-- 4.6 Shipments

SELECT
    COUNT(*) FILTER (WHERE shipment_id IS NULL) AS shipment_id_nulls,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE warehouse_id IS NULL) AS warehouse_id_nulls,
    COUNT(*) FILTER (WHERE delivery_partner_id IS NULL) AS partner_id_nulls,
    COUNT(*) FILTER (WHERE shipping_date IS NULL) AS shipping_date_nulls,
    COUNT(*) FILTER (WHERE actual_delivery_date IS NULL) AS actual_delivery_nulls
FROM shipments;


-- 4.7 Returns

SELECT
    COUNT(*) FILTER (WHERE return_id IS NULL) AS return_id_nulls,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS order_item_id_nulls,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
    COUNT(*) FILTER (WHERE return_date IS NULL) AS return_date_nulls,
    COUNT(*) FILTER (WHERE refund_amount IS NULL) AS refund_amount_nulls
FROM returns;


-- ============================================================
-- SECTION 5: NUMERIC / VALUE VALIDATION
-- ============================================================
-- Purpose:
-- Find impossible negative or invalid values.
-- ============================================================


-- 5.1 Invalid Product Costs

SELECT *
FROM products
WHERE product_cost < 0;


-- 5.2 Invalid Product List Prices

SELECT *
FROM products
WHERE list_price < 0;


-- 5.3 Invalid Order Quantities

SELECT *
FROM order_items
WHERE quantity <= 0;


-- 5.4 Invalid Unit Prices

SELECT *
FROM order_items
WHERE unit_list_price < 0
   OR unit_selling_price < 0;


-- 5.5 Invalid Discounts

SELECT *
FROM order_items
WHERE discount_percent < 0
   OR discount_percent > 100
   OR discount_amount < 0;


-- 5.6 Invalid Order Amounts

SELECT *
FROM orders
WHERE order_subtotal < 0
   OR discount_amount < 0
   OR shipping_fee < 0
   OR order_total < 0;


-- 5.7 Invalid Payment Amounts

SELECT *
FROM payments
WHERE payment_amount < 0;


-- 5.8 Invalid Refund Amounts

SELECT *
FROM returns
WHERE refund_amount < 0
   OR return_cost < 0;


-- ============================================================
-- SECTION 6: RATING VALIDATION
-- ============================================================
-- Ratings should normally fall between 0 and 5.
-- ============================================================


-- 6.1 Product Ratings

SELECT *
FROM products
WHERE product_rating IS NOT NULL
  AND (
      product_rating < 0
      OR product_rating > 5
  );


-- 6.2 Seller Ratings

SELECT *
FROM sellers
WHERE seller_rating IS NOT NULL
  AND (
      seller_rating < 0
      OR seller_rating > 5
  );


-- 6.3 Delivery Partner Ratings

SELECT *
FROM delivery_partners
WHERE partner_rating IS NOT NULL
  AND (
      partner_rating < 0
      OR partner_rating > 5
  );


-- ============================================================
-- SECTION 7: DATE VALIDATION
-- ============================================================
-- Purpose:
-- Identify logically impossible dates.
-- ============================================================


-- 7.1 Customer registration date after today's date

SELECT *
FROM customers
WHERE registration_date > CURRENT_DATE;


-- 7.2 Customer date of birth after registration

SELECT
    customer_id,
    date_of_birth,
    registration_date
FROM customers
WHERE date_of_birth IS NOT NULL
  AND date_of_birth > registration_date;


-- 7.3 Product launch date after today's date

SELECT *
FROM products
WHERE launch_date > CURRENT_DATE;


-- 7.4 Seller registration date after today's date

SELECT *
FROM sellers
WHERE registration_date > CURRENT_DATE;


-- 7.5 Order date after today's date

SELECT *
FROM orders
WHERE order_date > CURRENT_DATE;


-- ============================================================
-- SECTION 8: ORDER ITEM CALCULATION VALIDATION
-- ============================================================
-- Purpose:
-- Validate the mathematical relationships inside order_items.
--
-- Expected formulas:
--
-- Gross Amount =
-- quantity × unit_list_price
--
-- Discount Amount =
-- Gross Amount - Revenue
--
-- Revenue =
-- quantity × unit_selling_price
--
-- Item Cost =
-- quantity × product_cost
--
-- Profit =
-- Revenue - Cost
-- ============================================================


-- 8.1 Validate item revenue

SELECT
    order_item_id,
    quantity,
    unit_selling_price,
    item_revenue,
    ROUND(
        quantity * unit_selling_price,
        2
    ) AS calculated_revenue
FROM order_items
WHERE ABS(
    item_revenue -
    ROUND(quantity * unit_selling_price, 2)
) > 0.01;


-- 8.2 Validate item cost

SELECT
    order_item_id,
    quantity,
    product_cost,
    item_cost,
    ROUND(
        quantity * product_cost,
        2
    ) AS calculated_cost
FROM order_items
WHERE ABS(
    item_cost -
    ROUND(quantity * product_cost, 2)
) > 0.01;


-- 8.3 Validate item profit

SELECT
    order_item_id,
    item_revenue,
    item_cost,
    item_profit,
    ROUND(
        item_revenue - item_cost,
        2
    ) AS calculated_profit
FROM order_items
WHERE ABS(
    item_profit -
    ROUND(item_revenue - item_cost, 2)
) > 0.01;


-- 8.4 Validate discount amount

SELECT
    order_item_id,
    quantity,
    unit_list_price,
    unit_selling_price,
    discount_amount,
    ROUND(
        (quantity * unit_list_price)
        - (quantity * unit_selling_price),
        2
    ) AS calculated_discount
FROM order_items
WHERE ABS(
    discount_amount -
    ROUND(
        (quantity * unit_list_price)
        - (quantity * unit_selling_price),
        2
    )
) > 0.01;


-- 8.5 Validate discount percentage

SELECT
    order_item_id,
    unit_list_price,
    unit_selling_price,
    discount_percent,
    ROUND(
        (
            (unit_list_price - unit_selling_price)
            / NULLIF(unit_list_price, 0)
        ) * 100,
        2
    ) AS calculated_discount_percent
FROM order_items
WHERE unit_list_price > 0
  AND ABS(
      discount_percent -
      ROUND(
          (
              (unit_list_price - unit_selling_price)
              / NULLIF(unit_list_price, 0)
          ) * 100,
          2
      )
  ) > 0.10;


-- ============================================================
-- SECTION 9: ORDER TOTAL RECONCILIATION
-- ============================================================
-- Purpose:
-- Compare order-level amounts against order-item totals.
--
-- This is one of the most important validation checks.
-- ============================================================


-- 9.1 Compare order subtotal against order-item revenue

SELECT
    o.order_id,
    o.order_subtotal,
    ROUND(SUM(oi.item_revenue), 2) AS item_revenue_total,
    ROUND(
        o.order_subtotal - SUM(oi.item_revenue),
        2
    ) AS difference
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.order_subtotal
HAVING ABS(
    o.order_subtotal - SUM(oi.item_revenue)
) > 0.01
ORDER BY ABS(
    o.order_subtotal - SUM(oi.item_revenue)
) DESC;


-- 9.2 Recalculate order total
--
-- Expected:
-- order_total =
-- order_subtotal - discount_amount + shipping_fee

SELECT
    order_id,
    order_subtotal,
    discount_amount,
    shipping_fee,
    order_total,
    ROUND(
        order_subtotal
        - discount_amount
        + shipping_fee,
        2
    ) AS calculated_order_total
FROM orders
WHERE ABS(
    order_total -
    ROUND(
        order_subtotal
        - discount_amount
        + shipping_fee,
        2
    )
) > 0.01;


-- ============================================================
-- SECTION 10: PAYMENT VALIDATION
-- ============================================================
-- Purpose:
-- Compare successful payment amounts against order totals.
--
-- Multiple payment records may exist for one order,
-- so we aggregate them.
-- ============================================================


-- 10.1 Successful payment vs order total

SELECT
    o.order_id,
    o.order_total,
    ROUND(
        SUM(
            CASE
                WHEN p.payment_status = 'Successful'
                THEN p.payment_amount
                ELSE 0
            END
        ),
        2
    ) AS successful_payment_total,
    ROUND(
        o.order_total -
        SUM(
            CASE
                WHEN p.payment_status = 'Successful'
                THEN p.payment_amount
                ELSE 0
            END
        ),
        2
    ) AS difference
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
GROUP BY
    o.order_id,
    o.order_total
HAVING ABS(
    o.order_total -
    SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN p.payment_amount
            ELSE 0
        END
    )
) > 0.01
ORDER BY ABS(
    o.order_total -
    SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN p.payment_amount
            ELSE 0
        END
    )
) DESC;


-- 10.2 Payments without matching order

SELECT
    p.payment_id,
    p.order_id,
    p.payment_amount
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 10.3 Multiple payment records per order

SELECT
    order_id,
    COUNT(*) AS payment_record_count
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_record_count DESC;


-- ============================================================
-- SECTION 11: SHIPMENT VALIDATION
-- ============================================================
-- Purpose:
-- Check shipment dates and delivery delays.
-- ============================================================


-- 11.1 Delivery before shipping

SELECT
    shipment_id,
    shipping_date,
    actual_delivery_date
FROM shipments
WHERE actual_delivery_date IS NOT NULL
  AND shipping_date IS NOT NULL
  AND actual_delivery_date < shipping_date;


-- 11.2 Expected delivery before shipping

SELECT
    shipment_id,
    shipping_date,
    expected_delivery_date
FROM shipments
WHERE expected_delivery_date IS NOT NULL
  AND shipping_date IS NOT NULL
  AND expected_delivery_date < shipping_date;


-- 11.3 Invalid delivery delay values

SELECT *
FROM shipments
WHERE delivery_delay_days IS NULL
   OR delivery_delay_days < -1000;


-- NOTE:
-- Negative delivery delay is NOT automatically an error.
--
-- Example:
-- expected date = 17-May
-- actual date   = 15-May
-- delay         = -2
--
-- That means the order arrived 2 days early.
-- This is valid business information.


-- 11.4 Validate delivery delay calculation

SELECT
    shipment_id,
    expected_delivery_date,
    actual_delivery_date,
    delivery_delay_days,
    (
        actual_delivery_date
        - expected_delivery_date
    ) AS calculated_delay
FROM shipments
WHERE actual_delivery_date IS NOT NULL
  AND expected_delivery_date IS NOT NULL
  AND delivery_delay_days IS NOT NULL
  AND delivery_delay_days <>
      (
          actual_delivery_date
          - expected_delivery_date
      );


-- 11.5 Delivered shipments without actual delivery date

SELECT *
FROM shipments
WHERE delivery_status = 'Delivered'
  AND actual_delivery_date IS NULL;


-- 11.6 Actual delivery date present for non-delivered shipment

SELECT
    shipment_id,
    delivery_status,
    actual_delivery_date
FROM shipments
WHERE delivery_status <> 'Delivered'
  AND actual_delivery_date IS NOT NULL;


-- ============================================================
-- SECTION 12: RETURN VALIDATION
-- ============================================================
-- Purpose:
-- Validate return relationships and quantities.
-- ============================================================


-- 12.1 Return date before order date

SELECT
    r.return_id,
    r.order_id,
    o.order_date,
    r.return_date
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id
WHERE r.return_date < o.order_date;


-- 12.2 Return product vs order-item product

SELECT
    r.return_id,
    r.product_id AS return_product,
    oi.product_id AS purchased_product
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE r.product_id <> oi.product_id;


-- 12.3 Return order vs order-item order

SELECT
    r.return_id,
    r.order_id AS return_order,
    oi.order_id AS item_order
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_id <> oi.order_id;


-- 12.4 Returns with zero refund when status is Refunded

SELECT *
FROM returns
WHERE return_status = 'Refunded'
  AND refund_amount = 0;


-- ============================================================
-- SECTION 13: SELLER / PRODUCT CONSISTENCY
-- ============================================================
-- Purpose:
-- Check whether the seller recorded in order_items matches
-- the seller assigned to the product.
-- ============================================================


SELECT
    oi.order_item_id,
    oi.product_id,
    oi.seller_id AS item_seller,
    p.seller_id AS product_seller
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.seller_id <> p.seller_id;


-- ============================================================
-- SECTION 14: PRODUCT PRICE CONSISTENCY
-- ============================================================
-- Purpose:
-- Compare product master prices with transactional prices.
--
-- Price changes over time can be legitimate.
-- Therefore these are INFORMATIONAL checks, not automatically
-- errors.
-- ============================================================


-- 14.1 Products sold above list price

SELECT
    oi.order_item_id,
    oi.product_id,
    p.list_price,
    oi.unit_list_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.unit_list_price > p.list_price;


-- 14.2 Products sold below cost
--
-- IMPORTANT:
-- This is NOT a data-quality error.
-- It is potentially a business profitability problem.

SELECT
    oi.order_item_id,
    oi.product_id,
    oi.unit_selling_price,
    oi.product_cost,
    oi.item_profit
FROM order_items oi
WHERE oi.unit_selling_price < oi.product_cost
ORDER BY oi.item_profit;


-- ============================================================
-- SECTION 15: CUSTOMER DATE / AGE LOGIC
-- ============================================================
-- Purpose:
-- Identify unrealistic customer ages.
-- ============================================================


SELECT
    customer_id,
    date_of_birth,
    registration_date,
    DATE_PART(
        'year',
        AGE(registration_date, date_of_birth)
    ) AS age_at_registration
FROM customers
WHERE date_of_birth IS NOT NULL
  AND (
      DATE_PART(
          'year',
          AGE(registration_date, date_of_birth)
      ) < 13
      OR
      DATE_PART(
          'year',
          AGE(registration_date, date_of_birth)
      ) > 100
  );


-- ============================================================
-- SECTION 16: ORDER STATUS DISTRIBUTION
-- ============================================================
-- Purpose:
-- Understand the values actually present in order_status.
-- This helps detect unexpected spelling/capitalization.
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- SECTION 17: PAYMENT STATUS DISTRIBUTION
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;


-- ============================================================
-- SECTION 18: SHIPMENT STATUS DISTRIBUTION
-- ============================================================

SELECT
    delivery_status,
    COUNT(*) AS shipment_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM shipments
GROUP BY delivery_status
ORDER BY shipment_count DESC;


-- ============================================================
-- SECTION 19: RETURN STATUS DISTRIBUTION
-- ============================================================

SELECT
    return_status,
    COUNT(*) AS return_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM returns
GROUP BY return_status
ORDER BY return_count DESC;


-- ============================================================
-- SECTION 20: RETURN REASON DISTRIBUTION
-- ============================================================
-- Useful for checking whether return reasons contain
-- unexpected spelling variations.
-- ============================================================

SELECT
    return_reason,
    COUNT(*) AS return_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM returns
GROUP BY return_reason
ORDER BY return_count DESC;


-- ============================================================
-- SECTION 21: DUPLICATE TRANSACTION-LIKE RECORDS
-- ============================================================
-- These are informational checks.
-- They do NOT automatically mean the data is wrong.
-- ============================================================


-- 21.1 Multiple shipments for the same order

SELECT
    order_id,
    COUNT(*) AS shipment_count
FROM shipments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY shipment_count DESC;


-- 21.2 Multiple returns for the same order item

SELECT
    order_item_id,
    COUNT(*) AS return_count
FROM returns
GROUP BY order_item_id
HAVING COUNT(*) > 1
ORDER BY return_count DESC;


-- ============================================================
-- SECTION 22: ORDER ↔ PAYMENT_ID REFERENCE CHECK
-- ============================================================
-- Your orders table contains payment_id.
-- payments also contains order_id.
--
-- We deliberately do NOT create a circular FK.
-- Instead, validate the relationship here.
-- ============================================================


SELECT
    o.order_id,
    o.payment_id
FROM orders o
LEFT JOIN payments p
    ON o.payment_id = p.payment_id
WHERE o.payment_id IS NOT NULL
  AND p.payment_id IS NULL;


-- ============================================================
-- SECTION 23: ORDER ↔ SHIPMENT_ID REFERENCE CHECK
-- ============================================================
-- Same principle as payment_id.
-- ============================================================


SELECT
    o.order_id,
    o.shipment_id
FROM orders o
LEFT JOIN shipments s
    ON o.shipment_id = s.shipment_id
WHERE o.shipment_id IS NOT NULL
  AND s.shipment_id IS NULL;


-- ============================================================
-- SECTION 24: ORDER-LEVEL PAYMENT_ID CONSISTENCY
-- ============================================================
-- Check whether orders.payment_id actually belongs to
-- the same order.
-- ============================================================


SELECT
    o.order_id,
    o.payment_id,
    p.order_id AS payment_order_id
FROM orders o
JOIN payments p
    ON o.payment_id = p.payment_id
WHERE o.payment_id IS NOT NULL
  AND o.order_id <> p.order_id;


-- ============================================================
-- SECTION 25: ORDER-LEVEL SHIPMENT_ID CONSISTENCY
-- ============================================================


SELECT
    o.order_id,
    o.shipment_id,
    s.order_id AS shipment_order_id
FROM orders o
JOIN shipments s
    ON o.shipment_id = s.shipment_id
WHERE o.shipment_id IS NOT NULL
  AND o.order_id <> s.order_id;


-- ============================================================
-- SECTION 26: ORDERS WITHOUT ORDER ITEMS
-- ============================================================
-- A normal completed order should generally have items.
-- Cancelled/test orders may require interpretation.
-- ============================================================


SELECT
    o.order_id,
    o.order_status,
    o.order_total
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;


-- ============================================================
-- SECTION 27: BUSINESS ANOMALY — HIGH DISCOUNTS
-- ============================================================
-- This is not a data-quality error.
-- It identifies transactions worth investigating.
-- ============================================================


SELECT
    order_item_id,
    product_id,
    quantity,
    discount_percent,
    discount_amount,
    item_revenue,
    item_profit
FROM order_items
WHERE discount_percent >= 50
ORDER BY discount_percent DESC;


-- ============================================================
-- SECTION 28: BUSINESS ANOMALY — NEGATIVE PROFIT
-- ============================================================
-- These are valid records but potentially important findings.
-- ============================================================


SELECT
    order_item_id,
    product_id,
    seller_id,
    quantity,
    item_revenue,
    item_cost,
    item_profit
FROM order_items
WHERE item_profit < 0
ORDER BY item_profit ASC;


-- ============================================================
-- SECTION 29: BUSINESS ANOMALY — HIGH DELIVERY DELAYS
-- ============================================================


SELECT
    shipment_id,
    order_id,
    warehouse_id,
    delivery_partner_id,
    expected_delivery_date,
    actual_delivery_date,
    delivery_delay_days
FROM shipments
WHERE delivery_delay_days > 3
ORDER BY delivery_delay_days DESC;


-- ============================================================
-- SECTION 30: BUSINESS ANOMALY — HIGH RETURN REFUNDS
-- ============================================================


SELECT
    return_id,
    order_id,
    order_item_id,
    product_id,
    return_reason,
    return_status,
    refund_amount,
    return_cost
FROM returns
WHERE refund_amount > 5000
ORDER BY refund_amount DESC;


-- ============================================================
-- SECTION 31: FINAL DATABASE SUMMARY
-- ============================================================
-- Quick overview of the dataset after validation.
-- ============================================================


SELECT
    (SELECT COUNT(*) FROM categories) AS categories,
    (SELECT COUNT(*) FROM locations) AS locations,
    (SELECT COUNT(*) FROM warehouses) AS warehouses,
    (SELECT COUNT(*) FROM delivery_partners) AS delivery_partners,
    (SELECT COUNT(*) FROM sellers) AS sellers,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM payments) AS payments,
    (SELECT COUNT(*) FROM shipments) AS shipments,
    (SELECT COUNT(*) FROM returns) AS returns;


-- ============================================================
-- END OF DATA VALIDATION SCRIPT
-- ============================================================
--
-- INTERPRETATION:
--
-- 0 rows in an integrity check
--       = GOOD
--
-- Rows returned in an integrity check
--       = INVESTIGATE
--
-- Rows returned in a BUSINESS ANOMALY check
--       = NOT NECESSARILY BAD DATA
--       = Potential business insight
--
-- DO NOT DELETE ANOMALOUS RECORDS JUST BECAUSE THEY LOOK ODD.
--
-- Examples:
--   Negative profit       → possible business problem
--   High discount         → possible margin problem
--   Negative delivery
--   delay                  → early delivery, not necessarily error
--   Multiple payments     → possible payment attempts
--   Multiple returns     → may require business interpretation
--
-- ============================================================