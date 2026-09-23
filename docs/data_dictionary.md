# Data Dictionary

## Source Tables

### categories
`category_id`, `category_name`, `subcategory_name`

### customers
`customer_id`, `registration_date`, `gender`, `date_of_birth`, `city`, `state`, `location_id`, `acquisition_channel`, `customer_segment`

### delivery_partners
`delivery_partner_id`, `delivery_partner_name`, `service_region`, `partner_type`, `partner_rating`

### locations
`location_id`, `city`, `state`, `region`, `city_tier`, `pincode_prefix`

### order_items
`order_item_id`, `order_id`, `product_id`, `seller_id`, `quantity`, `unit_list_price`, `unit_selling_price`, `discount_percent`, `discount_amount`, `product_cost`, `item_revenue`, `item_cost`, `item_profit`

### payments
`payment_id`, `order_id`, `payment_date`, `payment_method`, `payment_status`, `payment_amount`

### products
`product_id`, `product_name`, `category_id`, `brand`, `seller_id`, `product_cost`, `list_price`, `launch_date`, `product_rating`

### returns
`return_id`, `order_id`, `order_item_id`, `product_id`, `return_date`, `return_reason`, `return_status`, `refund_amount`, `return_cost`

### sellers
`seller_id`, `seller_name`, `registration_date`, `seller_city`, `seller_state`, `seller_location_id`, `seller_rating`, `seller_type`, `fulfillment_type`

### shipments
`shipment_id`, `order_id`, `warehouse_id`, `delivery_partner_id`, `shipping_date`, `expected_delivery_date`, `actual_delivery_date`, `delivery_status`, `delivery_delay_days`

### warehouses
`warehouse_id`, `warehouse_name`, `city`, `state`, `location_id`, `warehouse_type`, `capacity_band`

### orders
`order_id`, `customer_id`, `order_date`, `order_status`, `order_channel`, `shipping_location_id`, `warehouse_id`, `payment_id`, `shipment_id`, `order_subtotal`, `discount_amount`, `shipping_fee`, `order_total`
