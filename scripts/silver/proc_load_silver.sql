/* ============================================================
   BRONZE → SILVER TRANSFORMATION
   Full-load transformation
   ============================================================ */

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        BEGIN TRANSACTION;
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Table';
		PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_customers';
        TRUNCATE TABLE silver.crm_customers;
        PRINT '>> Inserting Data Into: silver.crm_customers';

;WITH source_data AS
(
    SELECT
        TRIM(customer_id)          AS customer_id,
        TRIM(customer_name)        AS customer_name,
        TRIM(gender)               AS gender,
        TRIM(date_of_birth)        AS date_of_birth,
        TRIM(email)                AS email,
        TRIM(phone)                AS phone,
        TRIM(city)                 AS city,
        TRIM(state)                AS state,
        TRIM(pincode)               AS pincode,
        TRIM(signup_date)          AS signup_date,
        TRIM(customer_type)        AS customer_type,
        TRIM(acquisition_channel)  AS acquisition_channel,
        TRIM(customer_status)      AS customer_status
    FROM bronze.crm_customers
),

parsed_data AS
(
    SELECT
        *,

        TRY_CONVERT(DATE, date_of_birth, 23)
            AS date_of_birth_value,

        TRY_CONVERT(DATE, signup_date, 23)
            AS signup_date_value,

        REPLACE(phone, ' ', '')
            AS normalized_phone

    FROM source_data
)
INSERT INTO silver.crm_customers
(
    customer_id,
    customer_name,
    gender,
    date_of_birth,
    email,
    phone,
    city,
    state,
    pincode,
    signup_date,
    customer_type,
    acquisition_channel,
    customer_status
)

SELECT

    CASE
        WHEN customer_id IS NULL
          OR customer_id = ''
          OR customer_id NOT LIKE
             'CUS[0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE customer_id
    END AS customer_id,

    CASE
        WHEN customer_name IS NULL
          OR customer_name = ''
        THEN NULL

        ELSE UPPER(customer_name)
    END AS customer_name,

    CASE
        WHEN UPPER(gender) IN ('MALE', 'M')
            THEN 'Male'

        WHEN UPPER(gender) IN ('FEMALE', 'F')
            THEN 'Female'

        WHEN UPPER(gender) = 'OTHER'
            THEN 'Other'

        ELSE 'Unknown'
    END AS gender,

    CASE
        WHEN date_of_birth IS NULL
          OR date_of_birth = ''
          OR date_of_birth NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR date_of_birth_value IS NULL
        THEN NULL

        ELSE date_of_birth_value
    END AS date_of_birth,

    CASE
        WHEN email IS NULL
          OR email = ''
          OR email LIKE '% %'
          OR email NOT LIKE '%@%.%'
          OR email LIKE '%@%@%'
          OR LEFT(email, 1) = '@'
          OR RIGHT(email, 1) = '@'
        THEN NULL

        ELSE LOWER(email)
    END AS email,

    CASE

        WHEN normalized_phone LIKE
             '+91[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN RIGHT(normalized_phone, 10)

        WHEN phone LIKE
             '[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN phone

        ELSE NULL

    END AS phone,

    CASE
        WHEN city IS NULL
          OR city = ''
        THEN NULL

        ELSE city
    END AS city,

    CASE
        WHEN state IS NULL
          OR state = ''
        THEN NULL

        ELSE state
    END AS state,

    CASE
        WHEN pincode IS NULL
          OR pincode = ''
          OR pincode NOT LIKE
             '[1-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE pincode
    END AS pincode,

    CASE
        WHEN signup_date IS NULL
          OR signup_date = ''
          OR signup_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR signup_date_value IS NULL
          OR signup_date_value > CAST(GETDATE() AS DATE)
        THEN NULL

        ELSE signup_date_value
    END AS signup_date,

    CASE
        WHEN UPPER(customer_type) = 'REGULAR'
            THEN 'Regular'

        WHEN UPPER(customer_type) = 'PREMIUM'
            THEN 'Premium'

        WHEN UPPER(customer_type) = 'WHOLESALE'
            THEN 'Wholesale'

        ELSE 'Unknown'
    END AS customer_type,

    CASE
        WHEN UPPER(acquisition_channel) = 'ORGANIC SEARCH'
            THEN 'Organic Search'

        WHEN UPPER(acquisition_channel) = 'REFERRAL'
            THEN 'Referral'

        WHEN UPPER(acquisition_channel) = 'DIRECT'
            THEN 'Direct'

        WHEN UPPER(acquisition_channel) = 'PAID ADS'
            THEN 'Paid Ads'

        WHEN UPPER(acquisition_channel) = 'SOCIAL MEDIA'
            THEN 'Social Media'

        WHEN UPPER(acquisition_channel) = 'EMAIL CAMPAIGN'
            THEN 'Email Campaign'

        ELSE 'Unknown'
    END AS acquisition_channel,


    CASE
        WHEN UPPER(customer_status) = 'ACTIVE'
            THEN 'Active'

        WHEN UPPER(customer_status) = 'INACTIVE'
            THEN 'Inactive'

        ELSE 'Unknown'
    END AS customer_status

FROM parsed_data;

SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

PRINT '------------------------------------------------';
PRINT 'Loading ERP Tables';
PRINT '------------------------------------------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.erp_products';
TRUNCATE TABLE silver.erp_products;
PRINT '>> Inserting Data Into: silver.erp_products';

;WITH source_data AS
(
    SELECT
        TRIM(product_id)       AS product_id,
        TRIM(product_name)     AS product_name,
        TRIM(category)         AS category,
        TRIM(subcategory)      AS subcategory,
        TRIM(brand)            AS brand,
        TRIM(unit_cost)        AS unit_cost,
        TRIM(selling_price)    AS selling_price,
        TRIM(supplier_id)      AS supplier_id,
        TRIM(launch_date)      AS launch_date,
        TRIM(product_status)   AS product_status
    FROM bronze.erp_products
),

parsed_data AS
(
    SELECT
        *,
        
        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(unit_cost, ',', '')
        ) AS unit_cost_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(selling_price, ',', '')
        ) AS selling_price_value,

        TRY_CONVERT(
            DATE,
            launch_date,
            23
        ) AS launch_date_value

    FROM source_data
)
INSERT INTO silver.erp_products
(
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_cost,
    selling_price,
    supplier_id,
    launch_date,
    product_status
)

SELECT

    CASE
        WHEN product_id IS NULL
          OR product_id = ''
          OR product_id NOT LIKE
             'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE product_id
    END AS product_id,


    CASE
        WHEN product_name IS NULL
          OR product_name = ''
        THEN NULL

        ELSE product_name
    END AS product_name,

    CASE
        WHEN category IS NULL
          OR category = ''
        THEN 'Unknown'

        WHEN UPPER(category) = 'ACCESSORIES'
            THEN 'Accessories'

        WHEN UPPER(category) = 'BEAUTY & PERSONAL CARE'
            THEN 'Beauty & Personal Care'

        WHEN UPPER(category) = 'BOOKS'
            THEN 'Books'

        WHEN UPPER(category) = 'ELECTRONICS'
            THEN 'Electronics'

        WHEN UPPER(category) = 'FASHION'
            THEN 'Fashion'

        WHEN UPPER(category) = 'GROCERY'
            THEN 'Grocery'

        WHEN UPPER(category) = 'HOME & KITCHEN'
            THEN 'Home & Kitchen'

        WHEN UPPER(category) = 'SPORTS & FITNESS'
            THEN 'Sports & Fitness'

        ELSE 'Unknown'
    END AS category,

    CASE
        WHEN subcategory IS NULL
          OR subcategory = ''
        THEN 'N/A'

        ELSE subcategory
    END AS subcategory,


    CASE
        WHEN brand IS NULL
          OR brand = ''
        THEN 'Unknown'

        ELSE brand
    END AS brand,

    CASE
        WHEN unit_cost IS NULL
          OR unit_cost = ''
          OR unit_cost LIKE '%[^0-9,. ]%'
          OR unit_cost_value IS NULL
          OR unit_cost_value <= 0
        THEN NULL

        ELSE unit_cost_value
    END AS unit_cost,

    CASE
        WHEN selling_price IS NULL
          OR selling_price = ''
          OR selling_price LIKE '%[^0-9,. ]%'
          OR selling_price_value IS NULL
          OR selling_price_value <= 0
        THEN NULL

        WHEN unit_cost_value IS NOT NULL
         AND unit_cost_value > 0
         AND selling_price_value < unit_cost_value
        THEN NULL

        ELSE selling_price_value
    END AS selling_price,

    CASE
        WHEN supplier_id IS NULL
          OR supplier_id = ''
          OR supplier_id NOT LIKE
             'SUP[0-9][0-9][0-9]'
        THEN NULL

        ELSE supplier_id
    END AS supplier_id,

    CASE
        WHEN launch_date IS NULL
          OR launch_date = ''
          OR launch_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR launch_date_value IS NULL
          OR launch_date_value > CAST(GETDATE() AS DATE)
        THEN NULL

        ELSE launch_date_value
    END AS launch_date,

    CASE
        WHEN UPPER(product_status) = 'ACTIVE'
            THEN 'Active'

        WHEN UPPER(product_status) = 'INACTIVE'
            THEN 'Inactive'

        WHEN UPPER(product_status) = 'DISCONTINUED'
            THEN 'Discontinued'

        ELSE 'Unknown'
    END AS product_status

FROM parsed_data;

SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.erp_orders';
TRUNCATE TABLE silver.erp_orders;
PRINT '>> Inserting Data Into: silver.erp_orders';

;WITH source_data AS
(
    SELECT
        TRIM(order_id)               AS order_id,
        TRIM(customer_id)            AS customer_id,
        TRIM(order_date)             AS order_date,
        TRIM(order_status)           AS order_status,
        TRIM(shipping_city)          AS shipping_city,
        TRIM(shipping_state)         AS shipping_state,
        TRIM(shipping_pincode)       AS shipping_pincode,
        TRIM(region_id)              AS region_id,
        TRIM(payment_method)         AS payment_method,
        TRIM(promotion_id)           AS promotion_id,
        TRIM(shipping_fee)           AS shipping_fee,
        TRIM(order_total)            AS order_total,
        TRIM(order_channel)          AS order_channel,
        TRIM(shipping_method)        AS shipping_method,
        TRIM(expected_delivery_date) AS expected_delivery_date,
        TRIM(actual_delivery_date)   AS actual_delivery_date
    FROM bronze.erp_orders
),

parsed_data AS
(
    SELECT
        *,

        TRY_CONVERT(DATE, order_date, 23)
            AS order_date_value,

        TRY_CONVERT(DATE, expected_delivery_date, 23)
            AS expected_delivery_date_value,

        TRY_CONVERT(DATE, actual_delivery_date, 23)
            AS actual_delivery_date_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(shipping_fee, ',', '')
        ) AS shipping_fee_value,

        TRY_CONVERT(
            DECIMAL(18,2),
            REPLACE(order_total, ',', '')
        ) AS order_total_value

    FROM source_data
)
INSERT INTO silver.erp_orders
(
    order_id,
    customer_id,
    order_date,
    order_status,
    shipping_city,
    shipping_state,
    shipping_pincode,
    region_id,
    payment_method,
    promotion_id,
    shipping_fee,
    order_total,
    order_channel,
    shipping_method,
    expected_delivery_date,
    actual_delivery_date
)

SELECT


    CASE
        WHEN order_id IS NULL
          OR order_id = ''
          OR order_id NOT LIKE
             'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL
        ELSE order_id
    END AS order_id,

    CASE
        WHEN customer_id IS NULL
          OR customer_id = ''
          OR customer_id NOT LIKE
             'CUS[0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL
        ELSE customer_id
    END AS customer_id,

    CASE
        WHEN order_date IS NULL
          OR order_date = ''
          OR order_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR order_date_value IS NULL
          OR order_date_value > CAST(GETDATE() AS DATE)
        THEN NULL
        ELSE order_date_value
    END AS order_date,

    CASE
        WHEN UPPER(order_status) = 'COMPLETED'
            THEN 'Completed'

        WHEN UPPER(order_status) = 'CANCELLED'
            THEN 'Cancelled'

        WHEN UPPER(order_status) = 'PENDING'
            THEN 'Pending'

        ELSE 'Unknown'
    END AS order_status,

    CASE
        WHEN shipping_city IS NULL
          OR shipping_city = ''
        THEN NULL
        ELSE shipping_city
    END AS shipping_city,

    CASE
        WHEN shipping_state IS NULL
          OR shipping_state = ''
        THEN NULL
        ELSE shipping_state
    END AS shipping_state,

    CASE
        WHEN shipping_pincode IS NULL
          OR shipping_pincode = ''
          OR shipping_pincode NOT LIKE
             '[1-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL
        ELSE shipping_pincode
    END AS shipping_pincode,


    CASE
        WHEN region_id IS NULL
          OR region_id = ''
          OR region_id NOT LIKE
             'REG[0-9][0-9][0-9]'
        THEN NULL
        ELSE region_id
    END AS region_id,

    CASE
        WHEN UPPER(payment_method) = 'UPI'
            THEN 'UPI'

        WHEN UPPER(payment_method) = 'CREDIT CARD'
            THEN 'Credit Card'

        WHEN UPPER(payment_method) = 'DEBIT CARD'
            THEN 'Debit Card'

        WHEN UPPER(payment_method) = 'CASH ON DELIVERY'
            THEN 'Cash on Delivery'

        WHEN UPPER(payment_method) = 'NET BANKING'
            THEN 'Net Banking'

        WHEN UPPER(payment_method) = 'WALLET'
            THEN 'Wallet'

        ELSE 'Unknown'
    END AS payment_method,

    CASE
        WHEN promotion_id IS NULL
          OR promotion_id = ''
        THEN NULL
        ELSE promotion_id
    END AS promotion_id,

    CASE
        WHEN shipping_fee IS NULL
          OR shipping_fee = ''
          OR shipping_fee_value IS NULL
          OR shipping_fee_value < 0
        THEN NULL
        ELSE shipping_fee_value
    END AS shipping_fee,

    CASE
        WHEN order_total IS NULL
          OR order_total = ''
          OR order_total_value IS NULL
          OR order_total_value <= 0
        THEN NULL
        ELSE order_total_value
    END AS order_total,


    CASE
        WHEN UPPER(order_channel) = 'WEBSITE'
            THEN 'Website'

        WHEN UPPER(order_channel) = 'MOBILE APP'
            THEN 'Mobile App'

        ELSE 'Unknown'
    END AS order_channel,


    CASE
        WHEN UPPER(shipping_method) = 'STANDARD'
            THEN 'Standard'

        WHEN UPPER(shipping_method) = 'EXPRESS'
            THEN 'Express'

        WHEN UPPER(shipping_method) = 'SAME DAY'
            THEN 'Same Day'

        ELSE 'Unknown'
    END AS shipping_method,

    CASE
        WHEN expected_delivery_date IS NULL
          OR expected_delivery_date = ''
          OR expected_delivery_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR expected_delivery_date_value IS NULL
        THEN NULL

        WHEN order_date_value IS NOT NULL
         AND expected_delivery_date_value < order_date_value
        THEN NULL

        ELSE expected_delivery_date_value
    END AS expected_delivery_date,

    CASE
        WHEN actual_delivery_date IS NULL
          OR actual_delivery_date = ''
        THEN NULL

        WHEN actual_delivery_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR actual_delivery_date_value IS NULL
        THEN NULL

        WHEN order_date_value IS NOT NULL
         AND actual_delivery_date_value < order_date_value
        THEN NULL

        ELSE actual_delivery_date_value
    END AS actual_delivery_date

FROM parsed_data;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.erp_order_items';
TRUNCATE TABLE silver.erp_order_items;
PRINT '>> Inserting Data Into: silver.erp_order_items';

;WITH source_data AS
(
    SELECT
        TRIM(order_item_id)       AS order_item_id,
        TRIM(order_id)            AS order_id,
        TRIM(product_id)          AS product_id,
        TRIM(quantity)             AS quantity,
        TRIM(unit_price)           AS unit_price,
        TRIM(unit_cost)            AS unit_cost,
        TRIM(discount_percentage)  AS discount_percentage,
        TRIM(discount_amount)      AS discount_amount,
        TRIM(line_total)           AS line_total

    FROM bronze.erp_order_items
),

parsed_data AS
(
    SELECT
        *,

        TRY_CONVERT(
            INT,
            quantity
        ) AS quantity_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(unit_price, ',', '')
        ) AS unit_price_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(unit_cost, ',', '')
        ) AS unit_cost_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(discount_percentage, ',', '')
        ) AS discount_percentage_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(discount_amount, ',', '')
        ) AS discount_amount_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(line_total, ',', '')
        ) AS line_total_value

    FROM source_data
)
INSERT INTO silver.erp_order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    unit_cost,
    discount_percentage,
    discount_amount,
    line_total
)

SELECT

    CASE
        WHEN order_item_id IS NULL
          OR order_item_id = ''
          OR order_item_id NOT LIKE
             'OI[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE order_item_id
    END AS order_item_id,

    CASE
        WHEN order_id IS NULL
          OR order_id = ''
          OR order_id NOT LIKE
             'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE order_id
    END AS order_id,

    CASE
        WHEN product_id IS NULL
          OR product_id = ''
          OR product_id NOT LIKE
             'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE product_id
    END AS product_id,

    CASE
        WHEN quantity IS NULL
          OR quantity = ''
          OR quantity_value IS NULL
          OR quantity_value <= 0
        THEN NULL

        ELSE quantity_value
    END AS quantity,


    CASE
        WHEN unit_price IS NULL
          OR unit_price = ''
          OR unit_price_value IS NULL
          OR unit_price_value <= 0
        THEN NULL

        ELSE unit_price_value
    END AS unit_price,

    CASE
        WHEN unit_cost IS NULL
          OR unit_cost = ''
          OR unit_cost_value IS NULL
          OR unit_cost_value <= 0
        THEN NULL

        WHEN unit_price_value IS NOT NULL
         AND unit_price_value < unit_cost_value
        THEN NULL

        ELSE unit_cost_value
    END AS unit_cost,

    CASE
        WHEN discount_percentage IS NULL
          OR discount_percentage = ''
          OR discount_percentage_value IS NULL
          OR discount_percentage_value < 0
          OR discount_percentage_value > 100
        THEN NULL

        ELSE discount_percentage_value
    END AS discount_percentage,

    CASE
        WHEN discount_amount IS NULL
          OR discount_amount = ''
          OR discount_amount_value IS NULL
          OR discount_amount_value < 0
        THEN NULL

        ELSE discount_amount_value
    END AS discount_amount,

    CASE
        WHEN line_total IS NULL
          OR line_total = ''
          OR line_total_value IS NULL
          OR line_total_value < 0
        THEN NULL

        WHEN quantity_value IS NOT NULL
         AND unit_price_value IS NOT NULL
         AND discount_amount_value IS NOT NULL
         AND ABS(
                line_total_value
                -
                (
                    quantity_value * unit_price_value
                    - discount_amount_value
                )
             ) > 0.01
        THEN NULL

        ELSE line_total_value
    END AS line_total


FROM parsed_data;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.erp_regions';
TRUNCATE TABLE silver.erp_regions;
PRINT '>> Inserting Data Into: silver.erp_regions';

;WITH source_data AS
(
    SELECT
        TRIM(region_id)     AS region_id,
        TRIM(region_name)   AS region_name,
        TRIM(state)         AS state,
        TRIM(city)          AS city,
        TRIM(warehouse_id)  AS warehouse_id

    FROM bronze.erp_regions
)
INSERT INTO silver.erp_regions
(
    region_id,
    region_name,
    state,
    city,
    warehouse_id
)

SELECT


    CASE
        WHEN region_id IS NULL
          OR region_id = ''
          OR region_id NOT LIKE
             'REG[0-9][0-9][0-9]'
        THEN NULL

        ELSE region_id
    END AS region_id,


    CASE
        WHEN UPPER(region_name) = 'NORTH'
            THEN 'North'

        WHEN UPPER(region_name) = 'SOUTH'
            THEN 'South'

        WHEN UPPER(region_name) = 'EAST'
            THEN 'East'

        WHEN UPPER(region_name) = 'WEST'
            THEN 'West'

        WHEN UPPER(region_name) = 'CENTRAL'
            THEN 'Central'

        WHEN region_name IS NULL
          OR region_name = ''
        THEN 'Unknown'

        ELSE 'Unknown'
    END AS region_name,

    CASE
        WHEN state IS NULL
          OR state = ''
        THEN NULL

        ELSE state
    END AS state,


    CASE
        WHEN city IS NULL
          OR city = ''
        THEN NULL

        ELSE city
    END AS city,

    CASE
        WHEN warehouse_id IS NULL
          OR warehouse_id = ''
          OR warehouse_id NOT LIKE
             'WH-[A-Z][A-Z][A-Z]-[0-9][0-9]'
        THEN NULL

        ELSE warehouse_id
    END AS warehouse_id


FROM source_data;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

PRINT '------------------------------------------------';
PRINT 'Loading MKT Table';
PRINT '------------------------------------------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.mkt_promotions';
TRUNCATE TABLE silver.mkt_promotions;
PRINT '>> Inserting Data Into: silver.mkt_promotions';

;WITH source_data AS
(
    SELECT
        TRIM(promotion_id)        AS promotion_id,
        TRIM(promotion_name)      AS promotion_name,
        TRIM(promotion_type)      AS promotion_type,
        TRIM(discount_percentage) AS discount_percentage,
        TRIM(start_date)          AS start_date,
        TRIM(end_date)            AS end_date,
        TRIM(minimum_order_value) AS minimum_order_value,
        TRIM(maximum_discount)    AS maximum_discount,
        TRIM(promotion_status)    AS promotion_status,
        TRIM(campaign_channel)    AS campaign_channel,
        TRIM(marketing_spend)     AS marketing_spend
    FROM bronze.mkt_promotions
),

parsed_data AS
(
    SELECT
        *,
        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(discount_percentage, ',', '')
        ) AS discount_percentage_value,

        TRY_CONVERT(
            DATE,
            start_date,
            23
        ) AS start_date_value,

        TRY_CONVERT(
            DATE,
            end_date,
            23
        ) AS end_date_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(minimum_order_value, ',', '')
        ) AS minimum_order_value_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(maximum_discount, ',', '')
        ) AS maximum_discount_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(marketing_spend, ',', '')
        ) AS marketing_spend_value

    FROM source_data
)
INSERT INTO silver.mkt_promotions
(
    promotion_id,
    promotion_name,
    promotion_type,
    discount_percentage,
    start_date,
    end_date,
    minimum_order_value,
    maximum_discount,
    promotion_status,
    campaign_channel,
    marketing_spend
)

SELECT

    CASE
        WHEN promotion_id IS NULL
          OR promotion_id = ''
          OR promotion_id NOT LIKE
             'PROMO[0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE promotion_id
    END AS promotion_id,

    CASE
        WHEN promotion_name IS NULL
          OR promotion_name = ''
        THEN NULL

        ELSE promotion_name
    END AS promotion_name,

    CASE
        WHEN UPPER(promotion_type) = 'FLASH SALE'
            THEN 'Flash Sale'

        WHEN UPPER(promotion_type) = 'CASHBACK'
            THEN 'Cashback'

        WHEN UPPER(promotion_type) = 'CLEARANCE'
            THEN 'Clearance'

        WHEN UPPER(promotion_type) = 'COUPON'
            THEN 'Coupon'

        WHEN UPPER(promotion_type) = 'FESTIVAL'
            THEN 'Festival'

        WHEN promotion_type IS NULL
          OR promotion_type = ''
        THEN 'Unknown'

        WHEN start_date_value > CAST(GETDATE() AS DATE)
        THEN promotion_type

        ELSE 'Unknown'
    END AS promotion_type,

    CASE
        WHEN discount_percentage IS NULL
          OR discount_percentage = ''
          OR discount_percentage_value IS NULL
          OR discount_percentage_value < 0
          OR discount_percentage_value > 100
        THEN NULL

        ELSE discount_percentage_value
    END AS discount_percentage,


    CASE
        WHEN start_date IS NULL
          OR start_date = ''
          OR start_date_value IS NULL
        THEN NULL

        ELSE start_date_value
    END AS start_date,

    CASE
        WHEN end_date IS NULL
          OR end_date = ''
          OR end_date_value IS NULL
        THEN NULL

        WHEN start_date_value IS NOT NULL
         AND end_date_value < start_date_value
        THEN NULL

        ELSE end_date_value
    END AS end_date,

    CASE
        WHEN minimum_order_value IS NULL
          OR minimum_order_value = ''
          OR minimum_order_value_value IS NULL
          OR minimum_order_value_value < 0
        THEN NULL

        ELSE minimum_order_value_value
    END AS minimum_order_value,

    CASE
        WHEN maximum_discount IS NULL
          OR maximum_discount = ''
        THEN NULL

        WHEN maximum_discount_value IS NULL
          OR maximum_discount_value < 0
        THEN NULL

        ELSE maximum_discount_value
    END AS maximum_discount,

    CASE
        WHEN UPPER(promotion_status) = 'ACTIVE'
            THEN 'Active'

        WHEN UPPER(promotion_status) = 'EXPIRED'
            THEN 'Expired'

        WHEN UPPER(promotion_status) = 'UPCOMING'
            THEN 'Upcoming'

        WHEN UPPER(promotion_status) = 'SCHEDULED'
            THEN 'Scheduled'

        ELSE 'Unknown'
    END AS promotion_status,

    CASE
        WHEN UPPER(campaign_channel) = 'EMAIL'
            THEN 'Email'

        WHEN UPPER(campaign_channel) = 'IN-APP BANNER'
            THEN 'In-App Banner'

        WHEN UPPER(campaign_channel) = 'SMS'
            THEN 'SMS'

        WHEN UPPER(campaign_channel) = 'SOCIAL MEDIA'
            THEN 'Social Media'

        WHEN UPPER(campaign_channel) = 'PUSH NOTIFICATION'
            THEN 'Push Notification'

        ELSE 'Unknown'
    END AS campaign_channel,

    CASE
        WHEN marketing_spend IS NULL
          OR marketing_spend = ''
          OR marketing_spend_value IS NULL
          OR marketing_spend_value < 0
        THEN NULL

        ELSE marketing_spend_value
    END AS marketing_spend


FROM parsed_data;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

PRINT '------------------------------------------------';
PRINT 'Loading RMS Table';
PRINT '------------------------------------------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.rms_returns';
TRUNCATE TABLE silver.rms_returns;
PRINT '>> Inserting Data Into: silver.rms_returns';

;WITH source_data AS
(
    SELECT
        TRIM(return_id)        AS return_id,
        TRIM(order_id)         AS order_id,
        TRIM(order_item_id)    AS order_item_id,
        TRIM(product_id)       AS product_id,
        TRIM(return_date)      AS return_date,
        TRIM(return_quantity)  AS return_quantity,
        TRIM(return_reason)    AS return_reason,
        TRIM(return_status)    AS return_status,
        TRIM(refund_amount)    AS refund_amount,
        TRIM(condition)        AS condition

    FROM bronze.rms_returns
),


parsed_data AS
(
    SELECT
        *,

        TRY_CONVERT(
            DATE,
            return_date,
            23
        ) AS return_date_value,

        TRY_CONVERT(
            INT,
            return_quantity
        ) AS return_quantity_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(refund_amount, ',', '')
        ) AS refund_amount_value

    FROM source_data
)
INSERT INTO silver.rms_returns
(
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
)

SELECT


    CASE
        WHEN return_id IS NULL
          OR return_id = ''
          OR return_id NOT LIKE
             'RET[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE return_id
    END AS return_id,


    CASE
        WHEN order_id IS NULL
          OR order_id = ''
          OR order_id NOT LIKE
             'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE order_id
    END AS order_id,

    CASE
        WHEN order_item_id IS NULL
          OR order_item_id = ''
          OR order_item_id NOT LIKE
             'OI[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE order_item_id
    END AS order_item_id,


    CASE
        WHEN product_id IS NULL
          OR product_id = ''
          OR product_id NOT LIKE
             'PRD[0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE product_id
    END AS product_id,


    CASE
        WHEN return_date IS NULL
          OR return_date = ''
          OR return_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR return_date_value IS NULL
          OR return_date_value > CAST(GETDATE() AS DATE)
        THEN NULL

        ELSE return_date_value
    END AS return_date,

    CASE
        WHEN return_quantity IS NULL
          OR return_quantity = ''
          OR return_quantity_value IS NULL
          OR return_quantity_value <= 0
        THEN NULL

        ELSE return_quantity_value
    END AS return_quantity,


    CASE
        WHEN return_reason IS NULL
          OR return_reason = ''
        THEN 'Unknown'

        ELSE return_reason
    END AS return_reason,


    CASE
        WHEN UPPER(return_status) = 'REQUESTED'
            THEN 'Requested'

        WHEN UPPER(return_status) = 'APPROVED'
            THEN 'Approved'

        WHEN UPPER(return_status) = 'RECEIVED'
            THEN 'Received'

        WHEN UPPER(return_status) = 'REFUNDED'
            THEN 'Refunded'

        WHEN UPPER(return_status) = 'REJECTED'
            THEN 'Rejected'

        ELSE 'Unknown'
    END AS return_status,


    CASE

        WHEN UPPER(return_status) IN
             (
                 'REQUESTED',
                 'APPROVED',
                 'RECEIVED',
                 'REJECTED'
             )
        THEN NULL


        WHEN UPPER(return_status) = 'REFUNDED'
        THEN
            CASE
                WHEN refund_amount_value IS NOT NULL
                 AND refund_amount_value > 0
                THEN refund_amount_value

                ELSE NULL
            END

        ELSE
            CASE
                WHEN refund_amount_value IS NOT NULL
                 AND refund_amount_value >= 0
                THEN refund_amount_value

                ELSE NULL
            END

    END AS refund_amount,

    CASE

        WHEN UPPER(return_status) IN
             (
                 'REQUESTED',
                 'APPROVED',
                 'REJECTED'
             )
        THEN NULL


        WHEN UPPER(return_status) = 'REFUNDED'
        THEN
            CASE
                WHEN condition IS NULL
                  OR condition = ''
                THEN NULL  -- missing condition on a Refunded return is a genuine data-quality gap;
                            -- leave it NULL so Silver validation flags it, rather than masking it as 'Unknown'

                ELSE condition
            END

        WHEN UPPER(return_status) = 'RECEIVED'
        THEN
            CASE
                WHEN condition IS NULL
                  OR condition = ''
                THEN NULL

                ELSE condition
            END

        ELSE
            CASE
                WHEN condition IS NULL
                  OR condition = ''
                THEN NULL

                ELSE condition
            END

    END AS condition


FROM parsed_data;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';


PRINT '------------------------------------------------';
PRINT 'Loading  PG Table';
PRINT '------------------------------------------------';

SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.pg_payments';
TRUNCATE TABLE silver.pg_payments;
PRINT '>> Inserting Data Into: silver.pg_payments';

;WITH source_data AS
(
    SELECT
        TRIM(payment_id)            AS payment_id,
        TRIM(order_id)             AS order_id,
        TRIM(payment_date)         AS payment_date,
        TRIM(payment_method)       AS payment_method,
        TRIM(payment_status)       AS payment_status,
        TRIM(transaction_reference) AS transaction_reference,
        TRIM(amount)               AS amount,
        TRIM(refund_amount)        AS refund_amount,
        TRIM(payment_gateway)      AS payment_gateway
    FROM bronze.pg_payments
),

parsed_data AS
(
    SELECT
        *,
        TRY_CONVERT(
            DATE,
            payment_date,
            23
        ) AS payment_date_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(amount, ',', '')
        ) AS amount_value,

        TRY_CONVERT(
            DECIMAL(10,2),
            REPLACE(refund_amount, ',', '')
        ) AS refund_amount_value,

        CASE
            WHEN transaction_reference IS NOT NULL
             AND transaction_reference <> ''
             AND transaction_reference LIKE
                 'TXN[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            THEN transaction_reference

            ELSE NULL
        END AS valid_transaction_reference

    FROM source_data
),

deduplicated_data AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                CASE
                    WHEN valid_transaction_reference IS NOT NULL
                    THEN valid_transaction_reference
                    ELSE payment_id
                END

            ORDER BY
                payment_date_value DESC,
                payment_id DESC
        ) AS rn

    FROM parsed_data
)
INSERT INTO silver.pg_payments
(
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_status,
    transaction_reference,
    amount,
    refund_amount,
    payment_gateway
)

SELECT

    CASE
        WHEN payment_id IS NULL
          OR payment_id = ''
          OR payment_id NOT LIKE
             'PAY[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE payment_id
    END AS payment_id,


    CASE
        WHEN order_id IS NULL
          OR order_id = ''
          OR order_id NOT LIKE
             'ORD[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THEN NULL

        ELSE order_id
    END AS order_id,

    CASE
        WHEN payment_date IS NULL
          OR payment_date = ''
          OR payment_date_value IS NULL
          OR payment_date NOT LIKE
             '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR payment_date_value > CAST(GETDATE() AS DATE)
        THEN NULL

        ELSE payment_date_value
    END AS payment_date,

    CASE
        WHEN UPPER(payment_method) = 'UPI'
            THEN 'UPI'

        WHEN UPPER(payment_method) = 'CREDIT CARD'
            THEN 'Credit Card'

        WHEN UPPER(payment_method) = 'DEBIT CARD'
            THEN 'Debit Card'

        WHEN UPPER(payment_method) = 'CASH ON DELIVERY'
            THEN 'Cash on Delivery'

        WHEN UPPER(payment_method) = 'NET BANKING'
            THEN 'Net Banking'

        WHEN UPPER(payment_method) = 'WALLET'
            THEN 'Wallet'

        ELSE 'Unknown'
    END AS payment_method,


    CASE
        WHEN UPPER(payment_status) = 'SUCCESSFUL'
            THEN 'Successful'

        WHEN UPPER(payment_status) = 'FAILED'
            THEN 'Failed'

        WHEN UPPER(payment_status) = 'PARTIALLY REFUNDED'
            THEN 'Partially Refunded'

        WHEN UPPER(payment_status) = 'REFUNDED'
            THEN 'Refunded'

        WHEN UPPER(payment_status) = 'PENDING'
            THEN 'Pending'

        ELSE 'Unknown'
    END AS payment_status,

    valid_transaction_reference AS transaction_reference,


    CASE
        WHEN amount IS NULL
          OR amount = ''
          OR amount_value IS NULL
          OR amount_value <= 0
        THEN NULL

        ELSE amount_value
    END AS amount,


    CASE

        WHEN UPPER(payment_status) IN
             (
                 'SUCCESSFUL',
                 'FAILED',
                 'PENDING'
             )
        THEN
            CASE
                WHEN refund_amount_value IS NULL
                  OR refund_amount_value = 0
                THEN 0

                ELSE NULL
            END

        WHEN UPPER(payment_status) = 'PARTIALLY REFUNDED'
        THEN
            CASE
                WHEN refund_amount_value > 0
                 AND amount_value IS NOT NULL
                 AND refund_amount_value < amount_value
                THEN refund_amount_value

                ELSE NULL
            END

        WHEN UPPER(payment_status) = 'REFUNDED'
        THEN
            CASE
                WHEN refund_amount_value IS NOT NULL
                 AND amount_value IS NOT NULL
                 AND refund_amount_value = amount_value
                THEN refund_amount_value

                ELSE NULL
            END

        ELSE NULL

    END AS refund_amount,

    CASE
        WHEN UPPER(payment_gateway) = 'CCAVENUE'
            THEN 'CCAvenue'

        WHEN UPPER(payment_gateway) = 'PAYU'
            THEN 'PayU'

        WHEN UPPER(payment_gateway) = 'PAYTM GATEWAY'
            THEN 'Paytm Gateway'

        WHEN UPPER(payment_gateway) = 'RAZORPAY'
            THEN 'Razorpay'

        ELSE 'Unknown'
    END AS payment_gateway


FROM deduplicated_data
WHERE rn = 1;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> -------------';

SET @batch_end_time = GETDATE();
		COMMIT TRANSACTION;
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		PRINT '=========================================='
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER'
		PRINT 'Error Message : ' + ERROR_MESSAGE();
		PRINT 'Error Number  : ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State   : ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
