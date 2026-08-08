/* =============================================================
   SHOPKART — BRONZE LAYER DDL
   Raw source tables
   Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
   ============================================================= */

-- =============================================================
-- 1. CRM.Customers
-- =============================================================
IF OBJECT_ID('bronze.crm_customers', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customers;
GO

CREATE TABLE bronze.crm_customers
(
    customer_id             NVARCHAR(50),
    customer_name           NVARCHAR(200),
    gender                  NVARCHAR(50),
    date_of_birth           NVARCHAR(50),
    email                   NVARCHAR(200),
    phone                   NVARCHAR(50),
    city                    NVARCHAR(150),
    state                   NVARCHAR(150),
    pincode                 NVARCHAR(30),
    signup_date             NVARCHAR(50),
    customer_type           NVARCHAR(50),
    acquisition_channel     NVARCHAR(100),
    customer_status         NVARCHAR(50)
);
GO


-- =============================================================
-- 2. ERP.Products
-- =============================================================
IF OBJECT_ID('bronze.erp_products', 'U') IS NOT NULL
    DROP TABLE bronze.erp_products;
GO

CREATE TABLE bronze.erp_products
(
    product_id              NVARCHAR(50),
    product_name            NVARCHAR(300),
    category                NVARCHAR(150),
    subcategory             NVARCHAR(150),
    brand                   NVARCHAR(150),
    unit_cost               NVARCHAR(50),
    selling_price           NVARCHAR(50),
    supplier_id             NVARCHAR(50),
    launch_date             NVARCHAR(50),
    product_status          NVARCHAR(100)
);
GO


-- =============================================================
-- 3. ERP.Orders
-- =============================================================
IF OBJECT_ID('bronze.erp_orders', 'U') IS NOT NULL
    DROP TABLE bronze.erp_orders;
GO

CREATE TABLE bronze.erp_orders
(
    order_id                 NVARCHAR(50),
    customer_id              NVARCHAR(50),
    order_date               NVARCHAR(50),
    order_status             NVARCHAR(50),
    shipping_city            NVARCHAR(150),
    shipping_state           NVARCHAR(150),
    shipping_pincode         NVARCHAR(30),
    region_id                NVARCHAR(50),
    payment_method           NVARCHAR(100),
    promotion_id             NVARCHAR(50),
    shipping_fee             NVARCHAR(50),
    order_total              NVARCHAR(50),
    order_channel            NVARCHAR(100),
    shipping_method          NVARCHAR(100),
    expected_delivery_date   NVARCHAR(50),
    actual_delivery_date     NVARCHAR(50)
);
GO


-- =============================================================
-- 4. ERP.Order_Items
-- =============================================================
IF OBJECT_ID('bronze.erp_order_items', 'U') IS NOT NULL
    DROP TABLE bronze.erp_order_items;
GO

CREATE TABLE bronze.erp_order_items
(
    order_item_id            NVARCHAR(50),
    order_id                 NVARCHAR(50),
    product_id               NVARCHAR(50),
    quantity                 NVARCHAR(50),
    unit_price               NVARCHAR(50),
    unit_cost                NVARCHAR(50),
    discount_percentage      NVARCHAR(50),
    discount_amount          NVARCHAR(50),
    line_total               NVARCHAR(50)
);
GO


-- =============================================================
-- 5. ERP.Regions
-- =============================================================
IF OBJECT_ID('bronze.erp_regions', 'U') IS NOT NULL
    DROP TABLE bronze.erp_regions;
GO

CREATE TABLE bronze.erp_regions
(
    region_id                NVARCHAR(50),
    region_name              NVARCHAR(100),
    state                    NVARCHAR(150),
    city                     NVARCHAR(150),
    warehouse_id             NVARCHAR(50)
);
GO


-- =============================================================
-- 6. PaymentGateway.Payments
-- =============================================================
IF OBJECT_ID('bronze.pg_payments', 'U') IS NOT NULL
    DROP TABLE bronze.pg_payments;
GO

CREATE TABLE bronze.pg_payments
(
    payment_id               NVARCHAR(50),
    order_id                 NVARCHAR(50),
    payment_date             NVARCHAR(50),
    payment_method           NVARCHAR(100),
    payment_status           NVARCHAR(50),
    transaction_reference    NVARCHAR(150),
    amount                   NVARCHAR(50),
    refund_amount            NVARCHAR(50),
    payment_gateway          NVARCHAR(100)
);
GO


-- =============================================================
-- 7. RMS.Returns
-- =============================================================
IF OBJECT_ID('bronze.rms_returns', 'U') IS NOT NULL
    DROP TABLE bronze.rms_returns;
GO

CREATE TABLE bronze.rms_returns
(
    return_id                NVARCHAR(50),
    order_id                 NVARCHAR(50),
    order_item_id            NVARCHAR(50),
    product_id               NVARCHAR(50),
    return_date              NVARCHAR(50),
    return_quantity          NVARCHAR(50),
    return_reason            NVARCHAR(150),
    return_status            NVARCHAR(50),
    refund_amount            NVARCHAR(50),
    condition                NVARCHAR(100)
);
GO


-- =============================================================
-- 8. Marketing.Promotions
-- =============================================================
IF OBJECT_ID('bronze.mkt_promotions', 'U') IS NOT NULL
    DROP TABLE bronze.mkt_promotions;
GO

CREATE TABLE bronze.mkt_promotions
(
    promotion_id             NVARCHAR(50),
    promotion_name           NVARCHAR(200),
    promotion_type           NVARCHAR(100),
    discount_percentage      NVARCHAR(50),
    start_date               NVARCHAR(50),
    end_date                 NVARCHAR(50),
    minimum_order_value      NVARCHAR(50),
    maximum_discount         NVARCHAR(50),
    promotion_status         NVARCHAR(100),
    campaign_channel         NVARCHAR(100),
    marketing_spend          NVARCHAR(50)
);
GO
