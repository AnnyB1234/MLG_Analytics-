/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_customers'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   ============================================================ */

SELECT
    (SELECT COUNT(*) FROM bronze.crm_customers) AS bronze_record_count,
    (SELECT COUNT(*) FROM silver.crm_customers) AS silver_record_count;


/* ============================================================
   2. DUPLICATE CUSTOMER IDs
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_customer_id_groups
FROM
(
    SELECT
        customer_id,
        COUNT(*) AS record_count
    FROM silver.crm_customers
    GROUP BY customer_id
    HAVING customer_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. CUSTOMER ID FORMAT
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS customer_id_format_issues
FROM
(
    SELECT
        customer_id
    FROM silver.crm_customers
    WHERE customer_id IS NULL
       OR customer_id NOT LIKE
          'CUS[0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. CUSTOMER NAME
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS customer_name_issues
FROM
(
    SELECT
        customer_id,
        customer_name
    FROM silver.crm_customers
    WHERE customer_name IS NULL
       OR TRIM(customer_name) = ''
       OR customer_name <> UPPER(TRIM(customer_name))
) AS t;


/* ============================================================
   5. GENDER DOMAIN
   Allowed:
       Male
       Female
       Other
       Unknown
   ============================================================ */

SELECT
    gender,
    COUNT(*) AS record_count
FROM silver.crm_customers
GROUP BY gender
ORDER BY record_count DESC;


/* Unexpected gender values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS gender_issues
FROM
(
    SELECT
        customer_id,
        gender
    FROM silver.crm_customers
    WHERE gender IS NULL
       OR gender NOT IN
          ('Male', 'Female', 'Other', 'Unknown')
) AS t;


/* ============================================================
   6. DATE OF BIRTH
   Expected Result: 0 future dates
   ============================================================ */

SELECT
    COUNT(*) AS date_of_birth_issues
FROM
(
    SELECT
        customer_id,
        date_of_birth
    FROM silver.crm_customers
    WHERE date_of_birth IS NOT NULL
      AND date_of_birth > CAST(GETDATE() AS DATE)
) AS t;


/* Check data type
   Expected: date
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'crm_customers'
  AND COLUMN_NAME = 'date_of_birth';


/* ============================================================
   7. EMAIL
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS email_issues
FROM
(
    SELECT
        customer_id,
        email
    FROM silver.crm_customers
    WHERE email IS NOT NULL
      AND
      (
          email <> LOWER(TRIM(email))
          OR email LIKE '% %'
          OR email NOT LIKE '%@%.%'
          OR email LIKE '%@%@%'
          OR LEFT(TRIM(email), 1) = '@'
          OR RIGHT(TRIM(email), 1) = '@'
      )
) AS t;


/* ============================================================
   8. PHONE NUMBER
   Expected:
       Exactly 10 digits
       First digit = 6, 7, 8, or 9
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_phone_numbers
FROM
(
    SELECT
        customer_id,
        phone
    FROM silver.crm_customers
    WHERE phone IS NOT NULL
      AND phone NOT LIKE
          '[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* +91 should no longer exist in Silver
   Expected Result: 0
*/

SELECT
    COUNT(*) AS remaining_plus91_numbers
FROM silver.crm_customers
WHERE phone LIKE '+91%';


/* ============================================================
   9. CITY
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS city_issues
FROM
(
    SELECT
        customer_id,
        city
    FROM silver.crm_customers
    WHERE city IS NOT NULL
      AND
      (
          city <> TRIM(city)
          OR city LIKE '%  %'
      )
) AS t;


/* ============================================================
   10. STATE
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS state_issues
FROM
(
    SELECT
        customer_id,
        state
    FROM silver.crm_customers
    WHERE state IS NOT NULL
      AND
      (
          state <> TRIM(state)
          OR state LIKE '%  %'
      )
) AS t;


/* ============================================================
   11. PINCODE
   Rule:
       Exactly 6 digits
       First digit = 1-9

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS incorrect_pincodes
FROM
(
    SELECT
        customer_id,
        pincode
    FROM silver.crm_customers
    WHERE pincode IS NOT NULL
      AND pincode NOT LIKE
          '[1-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   12. SIGNUP DATE
   Expected Result: 0 future dates
   ============================================================ */

SELECT
    COUNT(*) AS signup_date_issues
FROM
(
    SELECT
        customer_id,
        signup_date
    FROM silver.crm_customers
    WHERE signup_date IS NOT NULL
      AND signup_date > CAST(GETDATE() AS DATE)
) AS t;


/* Check data type
   Expected: date
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'crm_customers'
  AND COLUMN_NAME = 'signup_date';


/* ============================================================
   13. CUSTOMER TYPE
   Allowed:
       Regular
       Premium
       Wholesale
       Unknown
   ============================================================ */

SELECT
    customer_type,
    COUNT(*) AS record_count
FROM silver.crm_customers
GROUP BY customer_type
ORDER BY record_count DESC;


/* Unexpected customer type values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS customer_type_issues
FROM
(
    SELECT
        customer_id,
        customer_type
    FROM silver.crm_customers
    WHERE customer_type IS NULL
       OR customer_type NOT IN
          ('Regular', 'Premium', 'Wholesale', 'Unknown')
) AS t;


/* ============================================================
   14. ACQUISITION CHANNEL
   Allowed:
       Organic Search
       Referral
       Direct
       Paid Ads
       Social Media
       Email Campaign
       Unknown
   ============================================================ */

SELECT
    acquisition_channel,
    COUNT(*) AS record_count
FROM silver.crm_customers
GROUP BY acquisition_channel
ORDER BY record_count DESC;


/* Unexpected acquisition channel values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS acquisition_channel_issues
FROM
(
    SELECT
        customer_id,
        acquisition_channel
    FROM silver.crm_customers
    WHERE acquisition_channel IS NULL
       OR acquisition_channel NOT IN
          (
              'Organic Search',
              'Referral',
              'Direct',
              'Paid Ads',
              'Social Media',
              'Email Campaign',
              'Unknown'
          )
) AS t;


/* ============================================================
   15. CUSTOMER STATUS
   Allowed:
       Active
       Inactive
       Unknown
   ============================================================ */

SELECT
    customer_status,
    COUNT(*) AS record_count
FROM silver.crm_customers
GROUP BY customer_status
ORDER BY record_count DESC;


/* Unexpected customer status values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS customer_status_issues
FROM
(
    SELECT
        customer_id,
        customer_status
    FROM silver.crm_customers
    WHERE customer_status IS NULL
       OR customer_status NOT IN
          ('Active', 'Inactive', 'Unknown')
) AS t;


/* ============================================================
   16. BUSINESS RULE:
       DATE OF BIRTH MUST NOT BE AFTER SIGNUP DATE

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS dob_after_signup_issues
FROM
(
    SELECT
        customer_id,
        date_of_birth,
        signup_date
    FROM silver.crm_customers
    WHERE date_of_birth IS NOT NULL
      AND signup_date IS NOT NULL
      AND date_of_birth > signup_date
) AS t;


-- ====================================================================
-- Checking 'silver.erp_products'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.erp_products) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.erp_products) AS silver_record_count;


/* ============================================================
   2. DUPLICATE PRODUCT IDs
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_product_id_groups
FROM
(
    SELECT
        product_id,
        COUNT(*) AS record_count
    FROM silver.erp_products
    GROUP BY product_id
    HAVING product_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. PRODUCT ID FORMAT
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_id_format_issues
FROM
(
    SELECT
        product_id
    FROM silver.erp_products
    WHERE product_id IS NULL
       OR product_id NOT LIKE
          'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. PRODUCT NAME
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_name_issues
FROM
(
    SELECT
        product_id,
        product_name
    FROM silver.erp_products
    WHERE product_name IS NULL
       OR TRIM(product_name) = ''
       OR product_name <> TRIM(product_name)
) AS t;


/* ============================================================
   5. CATEGORY DOMAIN
   ============================================================ */

SELECT
    category,
    COUNT(*) AS record_count
FROM silver.erp_products
GROUP BY category
ORDER BY record_count DESC;


/* Unexpected category values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS category_issues
FROM
(
    SELECT
        product_id,
        category
    FROM silver.erp_products
    WHERE category IS NULL
       OR category NOT IN
          (
              'Accessories',
              'Beauty & Personal Care',
              'Books',
              'Electronics',
              'Fashion',
              'Grocery',
              'Home & Kitchen',
              'Sports & Fitness',
              'Unknown'
          )
) AS t;


/* ============================================================
   6. SUBCATEGORY
   Rule:
       Missing subcategory = N/A
   Expected Result: 0 invalid/missing values
   ============================================================ */

SELECT
    COUNT(*) AS subcategory_issues
FROM
(
    SELECT
        product_id,
        subcategory
    FROM silver.erp_products
    WHERE subcategory IS NULL
       OR TRIM(subcategory) = ''
) AS t;


/* ============================================================
   7. BRAND
   Rule:
       Missing brand = Unknown
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS brand_issues
FROM
(
    SELECT
        product_id,
        brand
    FROM silver.erp_products
    WHERE brand IS NULL
       OR TRIM(brand) = ''
) AS t;


/* ============================================================
   8. UNIT COST
   Rules:
       - If present, must be > 0
       - NULL allowed for invalid/missing source values
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS unit_cost_issues
FROM
(
    SELECT
        product_id,
        unit_cost
    FROM silver.erp_products
    WHERE unit_cost IS NOT NULL
      AND unit_cost <= 0
) AS t;


/* Check UNIT_COST data type
   Expected:
       DECIMAL
       Precision = 10
       Scale = 2
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_products'
  AND COLUMN_NAME = 'unit_cost';


/* ============================================================
   9. SELLING PRICE
   Rules:
       - If present, must be > 0
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS selling_price_issues
FROM
(
    SELECT
        product_id,
        selling_price
    FROM silver.erp_products
    WHERE selling_price IS NOT NULL
      AND selling_price <= 0
) AS t;


/* ============================================================
   10. REQUIRED SELLING PRICE
   Business Rule:
       If unit_cost is valid, selling_price MUST exist.

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS missing_selling_price
FROM silver.erp_products
WHERE unit_cost IS NOT NULL
  AND selling_price IS NULL;


/* ============================================================
   11. UNIT COST VS SELLING PRICE
   Business Rule:
       selling_price >= unit_cost

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS price_relationship_issues
FROM silver.erp_products
WHERE unit_cost IS NOT NULL
  AND selling_price IS NOT NULL
  AND selling_price < unit_cost;


/* ============================================================
   12. SUPPLIER ID
   Expected format: SUP###
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS supplier_id_issues
FROM
(
    SELECT
        product_id,
        supplier_id
    FROM silver.erp_products
    WHERE supplier_id IS NOT NULL
      AND supplier_id NOT LIKE
          'SUP[0-9][0-9][0-9]'
) AS t;


/* ============================================================
   13. LAUNCH DATE
   Rule:
       Must not be a future date
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS launch_date_issues
FROM
(
    SELECT
        product_id,
        launch_date
    FROM silver.erp_products
    WHERE launch_date IS NOT NULL
      AND launch_date > CAST(GETDATE() AS DATE)
) AS t;


/* Check LAUNCH_DATE data type
   Expected: DATE
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_products'
  AND COLUMN_NAME = 'launch_date';


/* ============================================================
   14. PRODUCT STATUS DOMAIN
   Allowed:
       Active
       Inactive
       Discontinued
       Unknown
   ============================================================ */

SELECT
    product_status,
    COUNT(*) AS record_count
FROM silver.erp_products
GROUP BY product_status
ORDER BY record_count DESC;


/* Unexpected status values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS product_status_issues
FROM
(
    SELECT
        product_id,
        product_status
    FROM silver.erp_products
    WHERE product_status IS NULL
       OR product_status NOT IN
          (
              'Active',
              'Inactive',
              'Discontinued',
              'Unknown'
          )
) AS t;


/* ============================================================
   15. NUMERIC DATA TYPES
   Expected:
       unit_cost      -> DECIMAL(10,2)
       selling_price  -> DECIMAL(10,2)
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_products'
  AND COLUMN_NAME IN
      (
          'unit_cost',
          'selling_price'
      );


/* ============================================================
   16. SUBCATEGORY / CATEGORY PROFILING
   Informational check
   ============================================================ */

SELECT
    category,
    subcategory,
    COUNT(*) AS product_count
FROM silver.erp_products
GROUP BY
    category,
    subcategory
ORDER BY
    category,
    product_count DESC;

-- ====================================================================
-- Checking 'silver.erp_orders'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Full Bronze → Silver load
   Expected: Bronze count = Silver count
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.erp_orders) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.erp_orders) AS silver_record_count;


/* ============================================================
   2. DUPLICATE ORDER IDs
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_order_id_groups
FROM
(
    SELECT
        order_id,
        COUNT(*) AS record_count
    FROM silver.erp_orders
    GROUP BY order_id
    HAVING order_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. ORDER ID FORMAT
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_id_format_issues
FROM
(
    SELECT
        order_id
    FROM silver.erp_orders
    WHERE order_id IS NULL
       OR order_id NOT LIKE
          'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. CUSTOMER ID
   Expected:
       - Valid CUS###### format
       - No NULLs
   ============================================================ */

SELECT
    COUNT(*) AS customer_id_issues
FROM
(
    SELECT
        order_id,
        customer_id
    FROM silver.erp_orders
    WHERE customer_id IS NULL
       OR customer_id NOT LIKE
          'CUS[0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   5. CUSTOMER REFERENCE INTEGRITY
   Every order should reference an existing Silver customer.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS customer_reference_issues
FROM silver.erp_orders AS o
LEFT JOIN silver.crm_customers AS c
    ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL
   OR c.customer_id IS NULL;


/* ============================================================
   6. ORDER DATE
   Rules:
       - Must not be NULL
       - Must not be future
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_date_issues
FROM
(
    SELECT
        order_id,
        order_date
    FROM silver.erp_orders
    WHERE order_date IS NULL
       OR order_date > CAST(GETDATE() AS DATE)
) AS t;


/* Check data type
   Expected: DATE
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_orders'
  AND COLUMN_NAME = 'order_date';


/* ============================================================
   7. ORDER STATUS DOMAIN
   Allowed:
       Completed
       Cancelled
       Pending
       Unknown
   ============================================================ */

SELECT
    order_status,
    COUNT(*) AS record_count
FROM silver.erp_orders
GROUP BY order_status
ORDER BY record_count DESC;


/* Unexpected order status values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS order_status_issues
FROM
(
    SELECT
        order_id,
        order_status
    FROM silver.erp_orders
    WHERE order_status IS NULL
       OR order_status NOT IN
          (
              'Completed',
              'Cancelled',
              'Pending',
              'Unknown'
          )
) AS t;


/* ============================================================
   8. SHIPPING CITY
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS shipping_city_issues
FROM
(
    SELECT
        order_id,
        shipping_city
    FROM silver.erp_orders
    WHERE shipping_city IS NOT NULL
      AND (
            shipping_city <> TRIM(shipping_city)
            OR shipping_city LIKE '%  %'
          )
) AS t;


/* ============================================================
   9. SHIPPING STATE
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS shipping_state_issues
FROM
(
    SELECT
        order_id,
        shipping_state
    FROM silver.erp_orders
    WHERE shipping_state IS NOT NULL
      AND (
            shipping_state <> TRIM(shipping_state)
            OR shipping_state LIKE '%  %'
          )
) AS t;


/* ============================================================
   10. SHIPPING PINCODE
   Rule:
       Exactly 6 digits
       First digit = 1-9
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS shipping_pincode_issues
FROM
(
    SELECT
        order_id,
        shipping_pincode
    FROM silver.erp_orders
    WHERE shipping_pincode IS NOT NULL
      AND shipping_pincode NOT LIKE
          '[1-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   11. REGION ID
   Expected format: REG###
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS region_id_issues
FROM
(
    SELECT
        order_id,
        region_id
    FROM silver.erp_orders
    WHERE region_id IS NULL
       OR region_id NOT LIKE
          'REG[0-9][0-9][0-9]'
) AS t;


/* ============================================================
   12. PAYMENT METHOD DOMAIN
   Allowed:
       UPI
       Credit Card
       Debit Card
       Cash on Delivery
       Net Banking
       Wallet
       Unknown
   ============================================================ */

SELECT
    payment_method,
    COUNT(*) AS record_count
FROM silver.erp_orders
GROUP BY payment_method
ORDER BY record_count DESC;


/* Unexpected payment methods
   Expected Result: 0
*/

SELECT
    COUNT(*) AS payment_method_issues
FROM
(
    SELECT
        order_id,
        payment_method
    FROM silver.erp_orders
    WHERE payment_method IS NULL
       OR payment_method NOT IN
          (
              'UPI',
              'Credit Card',
              'Debit Card',
              'Cash on Delivery',
              'Net Banking',
              'Wallet',
              'Unknown'
          )
) AS t;


/* ============================================================
   13. PROMOTION ID
   Promotion is optional.
   Check only for unwanted whitespace.
   ============================================================ */

SELECT
    COUNT(*) AS promotion_id_issues
FROM
(
    SELECT
        order_id,
        promotion_id
    FROM silver.erp_orders
    WHERE promotion_id IS NOT NULL
      AND promotion_id <> TRIM(promotion_id)
) AS t;


/* ============================================================
   14. SHIPPING FEE
   Rules:
       - If present, must be >= 0
   Zero is valid.
   ============================================================ */

SELECT
    COUNT(*) AS shipping_fee_issues
FROM
(
    SELECT
        order_id,
        shipping_fee
    FROM silver.erp_orders
    WHERE shipping_fee IS NOT NULL
      AND shipping_fee < 0
) AS t;


/* Check data type
   Expected: DECIMAL(10,2)
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_orders'
  AND COLUMN_NAME = 'shipping_fee';


/* ============================================================
   15. ORDER TOTAL
   Rules:
       - Must be > 0 when present
   ============================================================ */

SELECT
    COUNT(*) AS order_total_issues
FROM
(
    SELECT
        order_id,
        order_total
    FROM silver.erp_orders
    WHERE order_total IS NOT NULL
      AND order_total <= 0
) AS t;


/* Check data type
   Expected: DECIMAL(10,2)
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_orders'
  AND COLUMN_NAME = 'order_total';


/* ============================================================
   16. ORDER CHANNEL DOMAIN
   Allowed:
       Website
       Mobile App
       Unknown
   ============================================================ */

SELECT
    order_channel,
    COUNT(*) AS record_count
FROM silver.erp_orders
GROUP BY order_channel
ORDER BY record_count DESC;


/* Unexpected order channels
   Expected Result: 0
*/

SELECT
    COUNT(*) AS order_channel_issues
FROM
(
    SELECT
        order_id,
        order_channel
    FROM silver.erp_orders
    WHERE order_channel IS NULL
       OR order_channel NOT IN
          (
              'Website',
              'Mobile App',
              'Unknown'
          )
) AS t;


/* ============================================================
   17. SHIPPING METHOD DOMAIN
   Allowed:
       Standard
       Express
       Same Day
       Unknown
   ============================================================ */

SELECT
    shipping_method,
    COUNT(*) AS record_count
FROM silver.erp_orders
GROUP BY shipping_method
ORDER BY record_count DESC;


/* Unexpected shipping methods
   Expected Result: 0
*/

SELECT
    COUNT(*) AS shipping_method_issues
FROM
(
    SELECT
        order_id,
        shipping_method
    FROM silver.erp_orders
    WHERE shipping_method IS NULL
       OR shipping_method NOT IN
          (
              'Standard',
              'Express',
              'Same Day',
              'Unknown'
          )
) AS t;


/* ============================================================
   18. EXPECTED DELIVERY DATE
   Rules:
       - Must be present
       - Must not be before order date
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS expected_delivery_date_issues
FROM
(
    SELECT
        order_id,
        order_date,
        expected_delivery_date
    FROM silver.erp_orders
    WHERE expected_delivery_date IS NULL
       OR (
            order_date IS NOT NULL
            AND expected_delivery_date < order_date
          )
) AS t;


/* Check data type
   Expected: DATE
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_orders'
  AND COLUMN_NAME = 'expected_delivery_date';


/* ============================================================
   19. ACTUAL DELIVERY DATE
   Rules:
       - NULL is allowed
       - If present, must not be before order date

   Early delivery is valid.
   ============================================================ */

SELECT
    COUNT(*) AS actual_delivery_date_issues
FROM
(
    SELECT
        order_id,
        order_date,
        actual_delivery_date
    FROM silver.erp_orders
    WHERE actual_delivery_date IS NOT NULL
      AND order_date IS NOT NULL
      AND actual_delivery_date < order_date
) AS t;


/* Check data type
   Expected: DATE
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_orders'
  AND COLUMN_NAME = 'actual_delivery_date';


/* ============================================================
   20. DELIVERY PERFORMANCE DISTRIBUTION
   Informational check

   Early      = actual < expected
   On Time    = actual = expected
   Late       = actual > expected
   Not Delivered = actual is NULL
   ============================================================ */

SELECT
    CASE
        WHEN actual_delivery_date IS NULL
            THEN 'Not Delivered'

        WHEN actual_delivery_date < expected_delivery_date
            THEN 'Early'

        WHEN actual_delivery_date = expected_delivery_date
            THEN 'On Time'

        WHEN actual_delivery_date > expected_delivery_date
            THEN 'Late'

        ELSE 'Unknown'
    END AS delivery_status,

    COUNT(*) AS order_count

FROM silver.erp_orders

GROUP BY
    CASE
        WHEN actual_delivery_date IS NULL
            THEN 'Not Delivered'

        WHEN actual_delivery_date < expected_delivery_date
            THEN 'Early'

        WHEN actual_delivery_date = expected_delivery_date
            THEN 'On Time'

        WHEN actual_delivery_date > expected_delivery_date
            THEN 'Late'

        ELSE 'Unknown'
    END

ORDER BY order_count DESC;


/* ============================================================
   21. BUSINESS RULE:
       COMPLETED ORDERS SHOULD HAVE AN ACTUAL DELIVERY DATE

   Expected Result: 0

   This assumes "Completed" means the order has been delivered.
   ============================================================ */

SELECT
    COUNT(*) AS completed_without_delivery_date
FROM silver.erp_orders
WHERE order_status = 'Completed'
  AND actual_delivery_date IS NULL;


-- ====================================================================
-- Checking 'silver.erp_order_items'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Full Bronze → Silver load
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.erp_order_items) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.erp_order_items) AS silver_record_count;


/* ============================================================
   2. DUPLICATE ORDER ITEM IDs
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_order_item_id_groups
FROM
(
    SELECT
        order_item_id,
        COUNT(*) AS record_count
    FROM silver.erp_order_items
    GROUP BY order_item_id
    HAVING order_item_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. ORDER ITEM ID FORMAT
   Expected: OI########
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_item_id_format_issues
FROM
(
    SELECT
        order_item_id
    FROM silver.erp_order_items
    WHERE order_item_id IS NULL
       OR order_item_id NOT LIKE
          'OI[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. ORDER ID FORMAT
   Expected: ORD######
   ============================================================ */

SELECT
    COUNT(*) AS order_id_issues
FROM
(
    SELECT
        order_item_id,
        order_id
    FROM silver.erp_order_items
    WHERE order_id IS NULL
       OR order_id NOT LIKE
          'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   5. ORDER REFERENCE INTEGRITY
   Every order item should reference an existing Silver order.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_reference_issues
FROM silver.erp_order_items AS oi
LEFT JOIN silver.erp_orders AS o
    ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
   OR o.order_id IS NULL;


/* ============================================================
   6. PRODUCT ID FORMAT
   Expected: PRD######
   ============================================================ */

SELECT
    COUNT(*) AS product_id_issues
FROM
(
    SELECT
        order_item_id,
        product_id
    FROM silver.erp_order_items
    WHERE product_id IS NULL
       OR product_id NOT LIKE
          'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   7. PRODUCT REFERENCE INTEGRITY
   Every order item should reference an existing Silver product.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_reference_issues
FROM silver.erp_order_items AS oi
LEFT JOIN silver.erp_products AS p
    ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
   OR p.product_id IS NULL;


/* ============================================================
   8. QUANTITY
   Rule:
       Must be a positive integer.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS quantity_issues
FROM
(
    SELECT
        order_item_id,
        quantity
    FROM silver.erp_order_items
    WHERE quantity IS NULL
       OR quantity <= 0
       OR quantity <> FLOOR(quantity)
) AS t;


/* ============================================================
   9. UNIT PRICE
   Rule:
       Must be greater than 0.
   ============================================================ */

SELECT
    COUNT(*) AS unit_price_issues
FROM
(
    SELECT
        order_item_id,
        unit_price
    FROM silver.erp_order_items
    WHERE unit_price IS NULL
       OR unit_price <= 0
) AS t;


/* ============================================================
   10. UNIT COST
   Rule:
       Must be greater than 0.
   ============================================================ */

SELECT
    COUNT(*) AS unit_cost_issues
FROM
(
    SELECT
        order_item_id,
        unit_cost
    FROM silver.erp_order_items
    WHERE unit_cost IS NULL
       OR unit_cost <= 0
) AS t;


/* ============================================================
   11. UNIT PRICE VS UNIT COST
   Business Rule:
       unit_price >= unit_cost
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS price_cost_relationship_issues
FROM silver.erp_order_items
WHERE unit_price IS NOT NULL
  AND unit_cost IS NOT NULL
  AND unit_price < unit_cost;


/* ============================================================
   12. DISCOUNT PERCENTAGE
   Rule:
       0 to 100
   ============================================================ */

SELECT
    COUNT(*) AS discount_percentage_issues
FROM
(
    SELECT
        order_item_id,
        discount_percentage
    FROM silver.erp_order_items
    WHERE discount_percentage IS NULL
       OR discount_percentage < 0
       OR discount_percentage > 100
) AS t;


/* ============================================================
   13. DISCOUNT AMOUNT
   Rule:
       >= 0
       Zero is valid.
   ============================================================ */

SELECT
    COUNT(*) AS discount_amount_issues
FROM
(
    SELECT
        order_item_id,
        discount_amount
    FROM silver.erp_order_items
    WHERE discount_amount IS NULL
       OR discount_amount < 0
) AS t;


/* ============================================================
   14. LINE TOTAL
   Rule:
       >= 0
   ============================================================ */

SELECT
    COUNT(*) AS line_total_issues
FROM
(
    SELECT
        order_item_id,
        line_total
    FROM silver.erp_order_items
    WHERE line_total IS NULL
       OR line_total < 0
) AS t;


/* ============================================================
   15. DISCOUNT AMOUNT CANNOT EXCEED GROSS AMOUNT

   Gross amount:
       quantity × unit_price

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS excessive_discount_issues
FROM silver.erp_order_items
WHERE quantity IS NOT NULL
  AND unit_price IS NOT NULL
  AND discount_amount IS NOT NULL
  AND discount_amount >
      quantity * unit_price;


/* ============================================================
   16. LINE TOTAL CALCULATION
   Expected:
       quantity × unit_price - discount_amount

   Tolerance:
       0.01 for rounding
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS line_total_calculation_issues
FROM silver.erp_order_items
WHERE quantity IS NOT NULL
  AND unit_price IS NOT NULL
  AND discount_amount IS NOT NULL
  AND line_total IS NOT NULL
  AND ABS(
        line_total
        -
        (
            quantity * unit_price
            - discount_amount
        )
      ) > 0.01;


/* ============================================================
   17. ZERO DISCOUNT CHECK
   If discount_percentage = 0,
   discount_amount should normally be 0.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS zero_discount_mismatch
FROM silver.erp_order_items
WHERE discount_percentage = 0
  AND discount_amount <> 0;


/* ============================================================
   18. DATA TYPES
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_order_items'
  AND COLUMN_NAME IN
      (
          'quantity',
          'unit_price',
          'unit_cost',
          'discount_percentage',
          'discount_amount',
          'line_total'
      );


/* ============================================================
   19. STRING COLUMN TRIMMING
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS text_formatting_issues
FROM silver.erp_order_items
WHERE order_item_id <> TRIM(order_item_id)
   OR order_id <> TRIM(order_id)
   OR product_id <> TRIM(product_id);


/* ============================================================
   20. FINAL FINANCIAL CONSISTENCY CHECK
   Shows problematic records for investigation.
   ============================================================ */

SELECT
    order_item_id,
    quantity,
    unit_price,
    unit_cost,
    discount_percentage,
    discount_amount,
    line_total
FROM silver.erp_order_items
WHERE
       quantity IS NULL
    OR unit_price IS NULL
    OR unit_cost IS NULL
    OR discount_percentage IS NULL
    OR discount_amount IS NULL
    OR line_total IS NULL
    OR unit_price < unit_cost
    OR discount_amount > quantity * unit_price
    OR ABS(
        line_total
        -
        (
            quantity * unit_price
            - discount_amount
        )
      ) > 0.01;

-- ====================================================================
-- Checking 'silver.erp_regions'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Full Bronze → Silver load
   Expected: Bronze count = Silver count
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.erp_regions) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.erp_regions) AS silver_record_count;


/* ============================================================
   2. DUPLICATE REGION + WAREHOUSE ASSIGNMENTS
   The combination should be unique.

   One region can have many warehouses, so region_id alone
   must NOT be treated as unique.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS duplicate_region_warehouse_groups
FROM
(
    SELECT
        region_id,
        warehouse_id,
        COUNT(*) AS record_count
    FROM silver.erp_regions
    GROUP BY
        region_id,
        warehouse_id
    HAVING region_id IS NULL
        OR warehouse_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. REGION ID FORMAT
   Expected format: REG###
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS region_id_format_issues
FROM
(
    SELECT
        region_id
    FROM silver.erp_regions
    WHERE region_id IS NULL
       OR region_id NOT LIKE
          'REG[0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. REGION NAME DOMAIN
   Allowed:
       North
       South
       East
       West
       Central
       Unknown
   ============================================================ */

SELECT
    region_name,
    COUNT(*) AS record_count
FROM silver.erp_regions
GROUP BY region_name
ORDER BY record_count DESC;


/* Unexpected region names
   Expected Result: 0
*/

SELECT
    COUNT(*) AS region_name_issues
FROM
(
    SELECT
        region_id,
        region_name
    FROM silver.erp_regions
    WHERE region_name IS NULL
       OR region_name NOT IN
          (
              'North',
              'South',
              'East',
              'West',
              'Central',
              'Unknown'
          )
) AS t;


/* ============================================================
   5. STATE FORMAT
   No leading/trailing spaces.
   Missing source values are allowed as NULL.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS state_format_issues
FROM
(
    SELECT
        region_id,
        state
    FROM silver.erp_regions
    WHERE state IS NOT NULL
      AND state <> TRIM(state)
) AS t;


/* ============================================================
   6. CITY FORMAT
   No leading/trailing spaces.
   Missing source values are allowed as NULL.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS city_format_issues
FROM
(
    SELECT
        region_id,
        city
    FROM silver.erp_regions
    WHERE city IS NOT NULL
      AND city <> TRIM(city)
) AS t;


/* ============================================================
   7. WAREHOUSE ID FORMAT
   Expected format: WH-XXX-##
   Example: WH-RAJ-04
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS warehouse_id_format_issues
FROM
(
    SELECT
        region_id,
        warehouse_id
    FROM silver.erp_regions
    WHERE warehouse_id IS NULL
       OR warehouse_id NOT LIKE
          'WH-[A-Z][A-Z][A-Z]-[0-9][0-9]'
) AS t;


/* ============================================================
   8. REGION ID → REGION NAME CONSISTENCY
   A region should have one region name.
   Expected Result: 0
   ============================================================ */

SELECT
    region_id,
    COUNT(DISTINCT region_name) AS region_name_count
FROM silver.erp_regions
GROUP BY region_id
HAVING COUNT(DISTINCT region_name) > 1;


/* ============================================================
   9. REGION ID → STATE CONSISTENCY
   A region should belong to one state.
   Expected Result: 0
   ============================================================ */

SELECT
    region_id,
    COUNT(DISTINCT state) AS state_count
FROM silver.erp_regions
GROUP BY region_id
HAVING COUNT(DISTINCT state) > 1;


/* ============================================================
   10. REGION ID → CITY CONSISTENCY
   A region should map to one city.
   Expected Result: 0
   ============================================================ */

SELECT
    region_id,
    COUNT(DISTINCT city) AS city_count
FROM silver.erp_regions
GROUP BY region_id
HAVING COUNT(DISTINCT city) > 1;


/* ============================================================
   11. WAREHOUSE ASSIGNMENT DISTRIBUTION
   Informational only.

   This confirms that one region can have multiple warehouses.
   ============================================================ */

SELECT
    region_id,
    COUNT(DISTINCT warehouse_id) AS warehouse_count
FROM silver.erp_regions
GROUP BY region_id
ORDER BY warehouse_count DESC;


/* ============================================================
   12. DATA TYPE VALIDATION
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'erp_region'
ORDER BY ORDINAL_POSITION;


/* ============================================================
   13. TEXT WHITESPACE CHECK
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS text_formatting_issues
FROM silver.erp_regions
WHERE region_id <> TRIM(region_id)
   OR region_name <> TRIM(region_name)
   OR (state IS NOT NULL AND state <> TRIM(state))
   OR (city IS NOT NULL AND city <> TRIM(city))
   OR warehouse_id <> TRIM(warehouse_id);


/* ============================================================
   14. REGION / STATE / CITY DISTRIBUTION
   Informational
   ============================================================ */

SELECT
    region_id,
    region_name,
    state,
    city,
    COUNT(*) AS warehouse_assignment_count
FROM silver.erp_regions
GROUP BY
    region_id,
    region_name,
    state,
    city
ORDER BY
    region_id,
    warehouse_assignment_count DESC;

-- ====================================================================
-- Checking 'silver.mkt_promotions'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Full Bronze → Silver load
   Expected: Bronze count = Silver count
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.mkt_promotions) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.mkt_promotions) AS silver_record_count;


/* ============================================================
   2. DUPLICATE PROMOTION IDs
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_promotion_id_groups
FROM
(
    SELECT
        promotion_id,
        COUNT(*) AS record_count
    FROM silver.mkt_promotions
    GROUP BY promotion_id
    HAVING promotion_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. PROMOTION ID FORMAT
   Expected: PROMO#####
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS promotion_id_format_issues
FROM
(
    SELECT
        promotion_id
    FROM silver.mkt_promotions
    WHERE promotion_id IS NULL
       OR promotion_id NOT LIKE
          'PROMO[0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. PROMOTION NAME
   Rules:
       - Not NULL
       - Not blank
       - No leading/trailing spaces
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS promotion_name_issues
FROM
(
    SELECT
        promotion_id,
        promotion_name
    FROM silver.mkt_promotions
    WHERE promotion_name IS NULL
       OR TRIM(promotion_name) = ''
       OR promotion_name <> TRIM(promotion_name)
) AS t;


/* ============================================================
   5. PROMOTION TYPE DOMAIN
   Known types:
       Flash Sale
       Cashback
       Clearance
       Coupon
       Festival
       Unknown

   Note:
   A future, previously unknown promotion type is intentionally
   allowed by the transformation rule.
   ============================================================ */

SELECT
    promotion_type,
    COUNT(*) AS record_count
FROM silver.mkt_promotions
GROUP BY promotion_type
ORDER BY record_count DESC;


/* Known / standard domain check
   Expected Result: 0 for invalid historical/current values.
   Future new types may legitimately appear.
*/

SELECT
    COUNT(*) AS promotion_type_issues
FROM
(
    SELECT
        promotion_id,
        promotion_type,
        start_date
    FROM silver.mkt_promotions
    WHERE promotion_type IS NULL
       OR (
            promotion_type NOT IN
            (
                'Flash Sale',
                'Cashback',
                'Clearance',
                'Coupon',
                'Festival',
                'Unknown'
            )
            AND start_date <= CAST(GETDATE() AS DATE)
          )
) AS t;


/* ============================================================
   6. DISCOUNT PERCENTAGE
   Rule:
       0 <= discount_percentage <= 100
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS discount_percentage_issues
FROM
(
    SELECT
        promotion_id,
        discount_percentage
    FROM silver.mkt_promotions
    WHERE discount_percentage IS NULL
       OR discount_percentage < 0
       OR discount_percentage > 100
) AS t;


/* ============================================================
   7. START DATE
   Rule:
       Must be a valid date.
   Future start dates are allowed.
   ============================================================ */

SELECT
    COUNT(*) AS start_date_issues
FROM
(
    SELECT
        promotion_id,
        start_date
    FROM silver.mkt_promotions
    WHERE start_date IS NULL
) AS t;


/* ============================================================
   8. END DATE
   Rule:
       Must exist and cannot be before start_date.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS end_date_issues
FROM
(
    SELECT
        promotion_id,
        start_date,
        end_date
    FROM silver.mkt_promotions
    WHERE end_date IS NULL
       OR (
            start_date IS NOT NULL
            AND end_date < start_date
          )
) AS t;


/* ============================================================
   9. MINIMUM ORDER VALUE
   Rule:
       Must be >= 0 when present.
   ============================================================ */

SELECT
    COUNT(*) AS minimum_order_value_issues
FROM
(
    SELECT
        promotion_id,
        minimum_order_value
    FROM silver.mkt_promotions
    WHERE minimum_order_value IS NOT NULL
      AND minimum_order_value < 0
) AS t;


/* ============================================================
   10. MAXIMUM DISCOUNT
   Rule:
       Optional.
       If present, must be >= 0.
   ============================================================ */

SELECT
    COUNT(*) AS maximum_discount_issues
FROM
(
    SELECT
        promotion_id,
        maximum_discount
    FROM silver.mkt_promotions
    WHERE maximum_discount IS NOT NULL
      AND maximum_discount < 0
) AS t;


/* ============================================================
   11. PROMOTION STATUS DOMAIN
   Allowed:
       Active
       Expired
       Upcoming
       Scheduled
       Unknown
   ============================================================ */

SELECT
    promotion_status,
    COUNT(*) AS record_count
FROM silver.mkt_promotions
GROUP BY promotion_status
ORDER BY record_count DESC;


/* Unexpected status values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS promotion_status_issues
FROM
(
    SELECT
        promotion_id,
        promotion_status
    FROM silver.mkt_promotions
    WHERE promotion_status IS NULL
       OR promotion_status NOT IN
          (
              'Active',
              'Expired',
              'Upcoming',
              'Scheduled',
              'Unknown'
          )
) AS t;


/* ============================================================
   12. CAMPAIGN CHANNEL DOMAIN
   Allowed:
       Email
       In-App Banner
       SMS
       Social Media
       Push Notification
       Unknown
   ============================================================ */

SELECT
    campaign_channel,
    COUNT(*) AS record_count
FROM silver.mkt_promotions
GROUP BY campaign_channel
ORDER BY record_count DESC;


/* Unexpected campaign channels
   Expected Result: 0
*/

SELECT
    COUNT(*) AS campaign_channel_issues
FROM
(
    SELECT
        promotion_id,
        campaign_channel
    FROM silver.mkt_promotions
    WHERE campaign_channel IS NULL
       OR campaign_channel NOT IN
          (
              'Email',
              'In-App Banner',
              'SMS',
              'Social Media',
              'Push Notification',
              'Unknown'
          )
) AS t;


/* ============================================================
   13. MARKETING SPEND
   Rule:
       Must be >= 0 when present.
   ============================================================ */

SELECT
    COUNT(*) AS marketing_spend_issues
FROM
(
    SELECT
        promotion_id,
        marketing_spend
    FROM silver.mkt_promotions
    WHERE marketing_spend IS NOT NULL
      AND marketing_spend < 0
) AS t;


/* ============================================================
   14. DATA TYPES
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'mkt_promotions'
  AND COLUMN_NAME IN
      (
          'discount_percentage',
          'minimum_order_value',
          'maximum_discount',
          'marketing_spend'
      );


/* ============================================================
   15. DATE DATA TYPES
   Expected:
       start_date → DATE
       end_date   → DATE
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'mkt_promotions'
  AND COLUMN_NAME IN
      (
          'start_date',
          'end_date'
      );


/* ============================================================
   16. TEXT WHITESPACE CHECK
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS text_formatting_issues
FROM silver.mkt_promotions
WHERE promotion_id <> TRIM(promotion_id)
   OR promotion_name <> TRIM(promotion_name)
   OR promotion_type <> TRIM(promotion_type)
   OR promotion_status <> TRIM(promotion_status)
   OR campaign_channel <> TRIM(campaign_channel);


/* ============================================================
   17. BUSINESS RULE:
       END DATE MUST NOT BE BEFORE START DATE
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_date_range
FROM silver.mkt_promotions
WHERE start_date IS NOT NULL
  AND end_date IS NOT NULL
  AND end_date < start_date;


/* ============================================================
   18. INFORMATIONAL:
       PROMOTIONS BY STATUS
   ============================================================ */

SELECT
    promotion_status,
    COUNT(*) AS promotion_count
FROM silver.mkt_promotions
GROUP BY promotion_status
ORDER BY promotion_count DESC;


/* ============================================================
   19. INFORMATIONAL:
       PROMOTIONS BY TYPE
   ============================================================ */

SELECT
    promotion_type,
    COUNT(*) AS promotion_count
FROM silver.mkt_promotions
GROUP BY promotion_type
ORDER BY promotion_count DESC;


/* ============================================================
   20. INFORMATIONAL:
       PROMOTIONS BY CAMPAIGN CHANNEL
   ============================================================ */

SELECT
    campaign_channel,
    COUNT(*) AS promotion_count
FROM silver.mkt_promotions
GROUP BY campaign_channel
ORDER BY promotion_count DESC;

-- ====================================================================
-- Checking 'silver.rms_returns'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Full Bronze → Silver load
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.rms_returns) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.rms_returns) AS silver_record_count;


/* ============================================================
   2. DUPLICATE RETURN IDs
   return_id must be unique and non-null.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_return_id_groups
FROM
(
    SELECT
        return_id,
        COUNT(*) AS record_count
    FROM silver.rms_returns
    GROUP BY return_id
    HAVING return_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. RETURN ID FORMAT
   Expected format: RET#######
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS return_id_format_issues
FROM
(
    SELECT
        return_id
    FROM silver.rms_returns
    WHERE return_id IS NULL
       OR return_id NOT LIKE
          'RET[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. ORDER ID FORMAT
   Expected format: ORD######
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_id_issues
FROM
(
    SELECT
        return_id,
        order_id
    FROM silver.rms_returns
    WHERE order_id IS NULL
       OR order_id NOT LIKE
          'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   5. ORDER REFERENCE INTEGRITY
   Every return should reference an existing Silver order.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_reference_issues
FROM silver.rms_returns AS r
LEFT JOIN silver.erp_orders AS o
    ON r.order_id = o.order_id
WHERE r.order_id IS NULL
   OR o.order_id IS NULL;


/* ============================================================
   6. ORDER ITEM ID FORMAT
   Expected format: OI########
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_item_id_issues
FROM
(
    SELECT
        return_id,
        order_item_id
    FROM silver.rms_returns
    WHERE order_item_id IS NULL
       OR order_item_id NOT LIKE
          'OI[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   7. ORDER ITEM REFERENCE INTEGRITY
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_item_reference_issues
FROM silver.rms_returns AS r
LEFT JOIN silver.erp_order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_id IS NULL
   OR oi.order_item_id IS NULL;


/* ============================================================
   8. PRODUCT ID FORMAT
   Expected format: PRD######
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_id_issues
FROM
(
    SELECT
        return_id,
        product_id
    FROM silver.rms_returns
    WHERE product_id IS NULL
       OR product_id NOT LIKE
          'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   9. PRODUCT REFERENCE INTEGRITY
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_reference_issues
FROM silver.rms_returns AS r
LEFT JOIN silver.erp_products AS p
    ON r.product_id = p.product_id
WHERE r.product_id IS NULL
   OR p.product_id IS NULL;


/* ============================================================
   10. RETURN DATE
   Rules:
       - Must be present
       - Must not be future
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS return_date_issues
FROM
(
    SELECT
        return_id,
        return_date
    FROM silver.rms_returns
    WHERE return_date IS NULL
       OR return_date > CAST(GETDATE() AS DATE)
) AS t;


/* ============================================================
   11. RETURN DATE VS ORDER DATE
   Business rule:
       return_date >= order_date
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS return_before_order_issues
FROM silver.rms_returns AS r
INNER JOIN silver.erp_orders AS o
    ON r.order_id = o.order_id
WHERE r.return_date IS NOT NULL
  AND o.order_date IS NOT NULL
  AND r.return_date < o.order_date;


/* ============================================================
   12. RETURN QUANTITY
   Rule:
       Must be a positive integer.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS return_quantity_issues
FROM
(
    SELECT
        return_id,
        return_quantity
    FROM silver.rms_returns
    WHERE return_quantity IS NULL
       OR return_quantity <= 0
       OR return_quantity <> FLOOR(return_quantity)
) AS t;


/* ============================================================
   13. RETURN QUANTITY VS ORDER ITEM QUANTITY
   A return cannot exceed the originally purchased quantity.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS excessive_return_quantity
FROM silver.rms_returns AS r
INNER JOIN silver.erp_order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.return_quantity IS NOT NULL
  AND oi.quantity IS NOT NULL
  AND r.return_quantity > oi.quantity;


/* ============================================================
   14. RETURN PRODUCT VS ORDER ITEM PRODUCT
   The returned product must match the referenced order item.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS product_mismatch_issues
FROM silver.rms_returns AS r
INNER JOIN silver.erp_order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.product_id IS NOT NULL
  AND oi.product_id IS NOT NULL
  AND r.product_id <> oi.product_id;


/* ============================================================
   15. RETURN REASON
   Missing values are represented as Unknown.
   Expected Result: 0 NULL / blank values
   ============================================================ */

SELECT
    COUNT(*) AS return_reason_issues
FROM silver.rms_returns
WHERE return_reason IS NULL
   OR TRIM(return_reason) = '';


/* ============================================================
   16. RETURN STATUS DOMAIN

   Allowed:
       Requested
       Approved
       Received
       Refunded
       Rejected
       Unknown
   ============================================================ */

SELECT
    return_status,
    COUNT(*) AS record_count
FROM silver.rms_returns
GROUP BY return_status
ORDER BY record_count DESC;


/* Unexpected status values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS return_status_issues
FROM
(
    SELECT
        return_id,
        return_status
    FROM silver.rms_returns
    WHERE return_status IS NULL
       OR return_status NOT IN
          (
              'Requested',
              'Approved',
              'Received',
              'Refunded',
              'Rejected',
              'Unknown'
          )
) AS t;


/* ============================================================
   17. REFUND AMOUNT
   Rules:
       - Non-refunded statuses should not have refund amounts
       - Refunded status requires positive refund
   ============================================================ */

SELECT
    COUNT(*) AS refund_amount_issues
FROM silver.rms_returns
WHERE
       (
           return_status IN
           (
               'Requested',
               'Approved',
               'Received',
               'Rejected'
           )
           AND refund_amount IS NOT NULL
       )

    OR (
           return_status = 'Refunded'
           AND (
                refund_amount IS NULL
                OR refund_amount <= 0
           )
       )

    OR (
           refund_amount IS NOT NULL
           AND refund_amount < 0
       );


/* ============================================================
   18. REFUND AMOUNT DATA TYPE
   Expected: DECIMAL(18,2)
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'rms_returns'
  AND COLUMN_NAME = 'refund_amount';


/* ============================================================
   19. CONDITION RULE

   Requested  → NULL
   Approved   → NULL
   Rejected   → NULL

   Received   → NULL or populated
   Refunded   → must be populated

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS condition_issues
FROM silver.rms_returns
WHERE
       return_status IN
       (
           'Requested',
           'Approved',
           'Rejected'
       )
       AND condition IS NOT NULL

    OR (
           return_status = 'Refunded'
           AND (
                condition IS NULL
                OR TRIM(condition) = ''
           )
       );


/* ============================================================
   20. TEXT WHITESPACE CHECK
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS text_formatting_issues
FROM silver.rms_returns
WHERE return_id <> TRIM(return_id)
   OR order_id <> TRIM(order_id)
   OR order_item_id <> TRIM(order_item_id)
   OR product_id <> TRIM(product_id)
   OR return_reason <> TRIM(return_reason)
   OR return_status <> TRIM(return_status)
   OR (
        condition IS NOT NULL
        AND condition <> TRIM(condition)
      );


/* ============================================================
   21. REFUND STATUS DISTRIBUTION
   Informational
   ============================================================ */

SELECT
    return_status,

    CASE
        WHEN refund_amount IS NULL
            THEN 'No Refund Amount'

        WHEN refund_amount > 0
            THEN 'Positive Refund'

        WHEN refund_amount = 0
            THEN 'Zero Refund'

        ELSE 'Invalid'
    END AS refund_category,

    COUNT(*) AS record_count

FROM silver.rms_returns

GROUP BY
    return_status,

    CASE
        WHEN refund_amount IS NULL
            THEN 'No Refund Amount'

        WHEN refund_amount > 0
            THEN 'Positive Refund'

        WHEN refund_amount = 0
            THEN 'Zero Refund'

        ELSE 'Invalid'
    END

ORDER BY
    return_status,
    record_count DESC;


/* ============================================================
   22. CONDITION DISTRIBUTION
   Informational
   ============================================================ */

SELECT
    condition,
    COUNT(*) AS record_count
FROM silver.rms_returns
GROUP BY condition
ORDER BY record_count DESC;


/* ============================================================
   23. FINAL RETURNS QUALITY CHECK
   Shows records violating the core Silver contract.
   ============================================================ */

SELECT
    return_id,
    order_id,
    order_item_id,
    product_id,
    return_date,
    return_quantity,
    return_reason,
    return_status,
    refund_amount,
    condition
FROM silver.rms_returns
WHERE return_id IS NULL

   OR order_id IS NULL
   OR order_item_id IS NULL
   OR product_id IS NULL

   OR return_date IS NULL

   OR return_quantity IS NULL
   OR return_quantity <= 0

   OR return_reason IS NULL

   OR return_status IS NULL

   OR (
        return_status IN
        (
            'Requested',
            'Approved',
            'Received',
            'Rejected'
        )
        AND refund_amount IS NOT NULL
      )

   OR (
        return_status = 'Refunded'
        AND (
             refund_amount IS NULL
             OR refund_amount <= 0
        )
      )

   OR (
        return_status IN
        (
            'Requested',
            'Approved',
            'Rejected'
        )
        AND condition IS NOT NULL
      )

   OR (
        return_status = 'Refunded'
        AND (
             condition IS NULL
             OR TRIM(condition) = ''
        )
      );

-- ====================================================================
-- Checking 'silver.pg_payments'
-- ====================================================================

/* ============================================================
   1. RECORD COUNT
   Expected:
       Silver count = Bronze count - duplicate references removed
   ============================================================ */

SELECT
    (SELECT COUNT(*)
     FROM bronze.pg_payments) AS bronze_record_count,

    (SELECT COUNT(*)
     FROM silver.pg_payments) AS silver_record_count;


/* ============================================================
   2. PAYMENT ID UNIQUENESS
   payment_id must be unique and non-null.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS invalid_payment_id_groups
FROM
(
    SELECT
        payment_id,
        COUNT(*) AS record_count
    FROM silver.pg_payments
    GROUP BY payment_id
    HAVING payment_id IS NULL
        OR COUNT(*) > 1
) AS t;


/* ============================================================
   3. PAYMENT ID FORMAT
   Expected format: PAY########
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS payment_id_format_issues
FROM
(
    SELECT
        payment_id
    FROM silver.pg_payments
    WHERE payment_id IS NULL
       OR payment_id NOT LIKE
          'PAY[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   4. ORDER ID
   Expected format: ORD######
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_id_issues
FROM
(
    SELECT
        payment_id,
        order_id
    FROM silver.pg_payments
    WHERE order_id IS NULL
       OR order_id NOT LIKE
          'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   5. PAYMENT → ORDER REFERENCE INTEGRITY
   Every payment should reference an existing Silver order.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS order_reference_issues
FROM silver.pg_payments AS p
LEFT JOIN silver.erp_orders AS o
    ON p.order_id = o.order_id
WHERE p.order_id IS NULL
   OR o.order_id IS NULL;


/* ============================================================
   6. PAYMENT DATE
   Rules:
       - Must be present
       - Must not be future
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS payment_date_issues
FROM
(
    SELECT
        payment_id,
        payment_date
    FROM silver.pg_payments
    WHERE payment_date IS NULL
       OR payment_date > CAST(GETDATE() AS DATE)
) AS t;


/* ============================================================
   7. PAYMENT DATE VS ORDER DATE
   Business rule:
       payment_date >= order_date
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS payment_before_order_issues
FROM silver.pg_payments AS p
INNER JOIN silver.erp_orders AS o
    ON p.order_id = o.order_id
WHERE p.payment_date IS NOT NULL
  AND o.order_date IS NOT NULL
  AND p.payment_date < o.order_date;


/* ============================================================
   8. PAYMENT METHOD DOMAIN
   ============================================================ */

SELECT
    payment_method,
    COUNT(*) AS record_count
FROM silver.pg_payments
GROUP BY payment_method
ORDER BY record_count DESC;


/* Unexpected values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS payment_method_issues
FROM
(
    SELECT
        payment_id,
        payment_method
    FROM silver.pg_payments
    WHERE payment_method IS NULL
       OR payment_method NOT IN
          (
              'UPI',
              'Credit Card',
              'Debit Card',
              'Cash on Delivery',
              'Net Banking',
              'Wallet',
              'Unknown'
          )
) AS t;


/* ============================================================
   9. PAYMENT STATUS DOMAIN
   ============================================================ */

SELECT
    payment_status,
    COUNT(*) AS record_count
FROM silver.pg_payments
GROUP BY payment_status
ORDER BY record_count DESC;


/* Unexpected values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS payment_status_issues
FROM
(
    SELECT
        payment_id,
        payment_status
    FROM silver.pg_payments
    WHERE payment_status IS NULL
       OR payment_status NOT IN
          (
              'Successful',
              'Failed',
              'Partially Refunded',
              'Refunded',
              'Pending',
              'Unknown'
          )
) AS t;


/* ============================================================
   10. TRANSACTION REFERENCE FORMAT
   Transaction reference is optional.

   Valid populated value:
       TXN##########

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS transaction_reference_format_issues
FROM
(
    SELECT
        payment_id,
        transaction_reference
    FROM silver.pg_payments
    WHERE transaction_reference IS NOT NULL
      AND transaction_reference NOT LIKE
          'TXN[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
) AS t;


/* ============================================================
   11. DUPLICATE TRANSACTION REFERENCES
   NULL values are excluded because multiple payments may
   legitimately have no transaction reference.

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS duplicate_transaction_reference_groups
FROM
(
    SELECT
        transaction_reference,
        COUNT(*) AS record_count
    FROM silver.pg_payments
    WHERE transaction_reference IS NOT NULL
    GROUP BY transaction_reference
    HAVING COUNT(*) > 1
) AS t;


/* ============================================================
   12. PAYMENT AMOUNT
   Rule:
       Must be > 0
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS amount_issues
FROM
(
    SELECT
        payment_id,
        amount
    FROM silver.pg_payments
    WHERE amount IS NULL
       OR amount <= 0
) AS t;


/* ============================================================
   13. REFUND AMOUNT
   Rule:
       Must be >= 0 when present.
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS refund_amount_issues
FROM
(
    SELECT
        payment_id,
        refund_amount
    FROM silver.pg_payments
    WHERE refund_amount IS NULL
       OR refund_amount < 0
) AS t;


/* ============================================================
   14. REFUND CANNOT EXCEED PAYMENT AMOUNT
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS refund_exceeds_payment
FROM silver.pg_payments
WHERE refund_amount IS NOT NULL
  AND amount IS NOT NULL
  AND refund_amount > amount;


/* ============================================================
   15. PAYMENT STATUS vs REFUND AMOUNT

   Successful          → refund = 0
   Failed              → refund = 0
   Pending             → refund = 0

   Partially Refunded  → 0 < refund < amount

   Refunded            → refund = amount

   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS refund_status_issues
FROM silver.pg_payments
WHERE
       (
           payment_status IN
           (
               'Successful',
               'Failed',
               'Pending'
           )
           AND (
                refund_amount IS NULL
                OR refund_amount <> 0
           )
       )

    OR (
           payment_status = 'Partially Refunded'
           AND (
                refund_amount IS NULL
                OR refund_amount <= 0
                OR refund_amount >= amount
           )
       )

    OR (
           payment_status = 'Refunded'
           AND (
                refund_amount IS NULL
                OR refund_amount <> amount
           )
       );


/* ============================================================
   16. REFUND DISTRIBUTION BY PAYMENT STATUS
   Informational
   ============================================================ */

SELECT
    payment_status,

    CASE
        WHEN refund_amount = 0
            THEN 'No Refund'

        WHEN refund_amount > 0
         AND refund_amount < amount
            THEN 'Partial Refund'

        WHEN refund_amount = amount
            THEN 'Full Refund'

        WHEN refund_amount IS NULL
            THEN 'Missing Refund Amount'

        ELSE 'Invalid'
    END AS refund_category,

    COUNT(*) AS record_count

FROM silver.pg_payments

GROUP BY
    payment_status,

    CASE
        WHEN refund_amount = 0
            THEN 'No Refund'

        WHEN refund_amount > 0
         AND refund_amount < amount
            THEN 'Partial Refund'

        WHEN refund_amount = amount
            THEN 'Full Refund'

        WHEN refund_amount IS NULL
            THEN 'Missing Refund Amount'

        ELSE 'Invalid'
    END

ORDER BY
    payment_status,
    record_count DESC;


/* ============================================================
   17. PAYMENT GATEWAY DOMAIN
   ============================================================ */

SELECT
    payment_gateway,
    COUNT(*) AS record_count
FROM silver.pg_payments
GROUP BY payment_gateway
ORDER BY record_count DESC;


/* Unexpected values
   Expected Result: 0
*/

SELECT
    COUNT(*) AS payment_gateway_issues
FROM
(
    SELECT
        payment_id,
        payment_gateway
    FROM silver.pg_payments
    WHERE payment_gateway IS NULL
       OR payment_gateway NOT IN
          (
              'CCAvenue',
              'PayU',
              'Paytm Gateway',
              'Razorpay',
              'Unknown'
          )
) AS t;


/* ============================================================
   18. DATA TYPES
   ============================================================ */

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'pg_payments'
  AND COLUMN_NAME IN
      (
          'amount',
          'refund_amount'
      );


/* ============================================================
   19. TEXT WHITESPACE CHECK
   Expected Result: 0
   ============================================================ */

SELECT
    COUNT(*) AS text_formatting_issues
FROM silver.pg_payments
WHERE payment_id <> TRIM(payment_id)
   OR order_id <> TRIM(order_id)
   OR (payment_method IS NOT NULL
       AND payment_method <> TRIM(payment_method))
   OR (payment_status IS NOT NULL
       AND payment_status <> TRIM(payment_status))
   OR (transaction_reference IS NOT NULL
       AND transaction_reference <> TRIM(transaction_reference))
   OR (payment_gateway IS NOT NULL
       AND payment_gateway <> TRIM(payment_gateway));


/* ============================================================
   20. FAILED PAYMENTS WITH / WITHOUT TRANSACTION REFERENCE
   Informational

   A failed payment is allowed to have either a transaction
   reference or NULL based on the actual Bronze profiling.
   ============================================================ */

SELECT
    payment_status,

    CASE
        WHEN transaction_reference IS NULL
            THEN 'Missing Transaction Reference'
        ELSE 'Transaction Reference Present'
    END AS reference_status,

    COUNT(*) AS record_count

FROM silver.pg_payments

WHERE payment_status = 'Failed'

GROUP BY
    payment_status,
    CASE
        WHEN transaction_reference IS NULL
            THEN 'Missing Transaction Reference'
        ELSE 'Transaction Reference Present'
    END

ORDER BY record_count DESC;


/* ============================================================
   21. FINAL PAYMENT QUALITY CHECK
   Shows any records violating the core Silver contract.
   ============================================================ */

SELECT
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_status,
    transaction_reference,
    amount,
    refund_amount,
    payment_gateway
FROM silver.pg_payments
WHERE payment_id IS NULL

   OR order_id IS NULL

   OR payment_date IS NULL

   OR payment_method IS NULL

   OR payment_status IS NULL

   OR amount IS NULL
   OR amount <= 0

   OR refund_amount IS NULL
   OR refund_amount < 0

   OR refund_amount > amount

   OR (
        payment_status IN
        (
            'Successful',
            'Failed',
            'Pending'
        )
        AND refund_amount <> 0
      )

   OR (
        payment_status = 'Partially Refunded'
        AND (
             refund_amount <= 0
             OR refund_amount >= amount
        )
      )

   OR (
        payment_status = 'Refunded'
        AND refund_amount <> amount
      );

