/* =============================================================
   SHOPKART — BRONZE LAYER DDL
   Raw source tables, loaded as-is from CRM / ERP / Payment Gateway (PG) /

   Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- =============================================================
-- 1. CRM.Customers
-- =============================================================
IF OBJECT_ID('bronze.crm_customers', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customers;
GO

CREATE TABLE bronze.crm_customers (
    customer_id             VARCHAR(20),
    customer_name           VARCHAR(150),
    gender                  VARCHAR(20),
    date_of_birth           VARCHAR(30),
    email                   VARCHAR(150),
    phone                   VARCHAR(30),
    city                    VARCHAR(100),
    state                   VARCHAR(100),
    pincode                 VARCHAR(20),
    signup_date             VARCHAR(30),
    customer_type           VARCHAR(30),
    acquisition_channel     VARCHAR(50),
    customer_status         VARCHAR(30)
);
GO

-- =============================================================
-- 2. ERP.Products
-- =============================================================
IF OBJECT_ID('bronze.erp_products', 'U') IS NOT NULL
    DROP TABLE bronze.erp_products;
GO

CREATE TABLE bronze.erp_products (
    product_id              VARCHAR(20),
    product_name            VARCHAR(200),
    category                VARCHAR(100),
    subcategory             VARCHAR(100),
    brand                   VARCHAR(100),
    unit_cost               VARCHAR(30),
    selling_price           VARCHAR(30),
    supplier_id              VARCHAR(30),
    launch_date             VARCHAR(30),
    product_status          VARCHAR(30)
);
GO

-- =============================================================
-- 3. ERP.Orders
-- =============================================================
IF OBJECT_ID('bronze.erp_orders', 'U') IS NOT NULL
    DROP TABLE bronze.erp_orders;
GO

CREATE TABLE bronze.erp_orders (
    order_id                VARCHAR(30),
    customer_id             VARCHAR(20),
    order_date               VARCHAR(30),
    order_status             VARCHAR(30),
    shipping_city             VARCHAR(100),
    shipping_state             VARCHAR(100),
    shipping_pincode             VARCHAR(20),
    region_id                VARCHAR(20),
    payment_method           VARCHAR(50),
    promotion_id             VARCHAR(30),
    shipping_fee             VARCHAR(30),
    order_total               VARCHAR(30),
    order_channel             VARCHAR(30),
    shipping_method             VARCHAR(50),
    expected_delivery_date             VARCHAR(30),
    actual_delivery_date             VARCHAR(30)
);
GO

-- =============================================================
-- 4. ERP.Order_Items
-- =============================================================
IF OBJECT_ID('bronze.erp_order_items', 'U') IS NOT NULL
    DROP TABLE bronze.erp_order_items;
GO

CREATE TABLE bronze.erp_order_items (
    order_item_id           NVARCHAR(30),
    order_id                NVARCHAR(30),
    product_id              NVARCHAR(20),
    quantity                 NVARCHAR(20),
    unit_price               NVARCHAR(30),
    unit_cost               NVARCHAR(30),
    discount_percentage             NVARCHAR(20),
    discount_amount             NVARCHAR(30),
    line_total               NVARCHAR(30)
);
GO

-- =============================================================
-- 5. ERP.Regions
-- =============================================================
IF OBJECT_ID('bronze.erp_regions', 'U') IS NOT NULL
    DROP TABLE bronze.erp_regions;
GO

CREATE TABLE bronze.erp_regions (
    region_id                NVARCHAR(20),
    region_name               NVARCHAR(50),
    state                    NVARCHAR(100),
    city                     NVARCHAR(100),
    warehouse_id             NVARCHAR(30)
);
GO

-- =============================================================
-- 6. PaymentGateway.Payments
-- =============================================================
IF OBJECT_ID('bronze.pg_payments', 'U') IS NOT NULL
    DROP TABLE bronze.pg_payments;
GO

CREATE TABLE bronze.pg_payments (
    payment_id               NVARCHAR(30),
    order_id                NVARCHAR(30),
    payment_date              NVARCHAR(30),
    payment_method           NVARCHAR(50),
    payment_status             NVARCHAR(30),
    transaction_reference             NVARCHAR(100),
    amount                   NVARCHAR(30),
    refund_amount             NVARCHAR(30),
    payment_gateway             NVARCHAR(50)
);
GO

-- =============================================================
-- 7. Returns.Returns
-- =============================================================
IF OBJECT_ID('bronze.rms_returns', 'U') IS NOT NULL
    DROP TABLE bronze.rms_returns;
GO

CREATE TABLE bronze.rms_returns (
    return_id                NVARCHAR(30),
    order_id                NVARCHAR(30),
    order_item_id             NVARCHAR(30),
    product_id               NVARCHAR(20),
    return_date               NVARCHAR(30),
    return_quantity             NVARCHAR(20),
    return_reason             NVARCHAR(100),
    return_status             NVARCHAR(30),
    refund_amount             NVARCHAR(30),
    condition                NVARCHAR(50)
);
GO

-- =============================================================
-- 8. Marketing.Promotions
-- =============================================================
IF OBJECT_ID('bronze.mkt_promotions', 'U') IS NOT NULL
    DROP TABLE bronze.mkt_promotions;
GO

CREATE TABLE bronze.mkt_promotions (
    promotion_id             NVARCHAR(30),
    promotion_name             NVARCHAR(150),
    promotion_type             NVARCHAR(50),
    discount_percentage             NVARCHAR(20),
    start_date               NVARCHAR(30),
    end_date                NVARCHAR(30),
    minimum_order_value             NVARCHAR(30),
    maximum_discount             NVARCHAR(30),
    promotion_status             NVARCHAR(30),
    campaign_channel             NVARCHAR(50),
    marketing_spend             NVARCHAR(30)
);
GO

