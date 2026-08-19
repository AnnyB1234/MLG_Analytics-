/* =============================================================
   SHOPKART — BRONZE LAYER DDL
   Raw source tables
   All source values are stored as NVARCHAR to preserve
   the original source representation during ingestion.
   ============================================================= */


-- =============================================================
-- 1. CRM.Customers
-- =============================================================
IF OBJECT_ID('silver.crm_customers', 'U') IS NOT NULL
    DROP TABLE Silver.crm_customers;
GO

CREATE TABLE silver.crm_customers
(
    customer_id             NVARCHAR(50),
    customer_name           NVARCHAR(200),
    gender                  NVARCHAR(50),
    date_of_birth           DATE,
    email                   NVARCHAR(200),
    phone                   NVARCHAR(50),
    city                    NVARCHAR(150),
    state                   NVARCHAR(150),
    pincode                 NVARCHAR(30),
    signup_date             DATE,
    customer_type           NVARCHAR(50),
    acquisition_channel     NVARCHAR(100),
    customer_status         NVARCHAR(50),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 2. ERP.Products
-- =============================================================
IF OBJECT_ID('silver.erp_products', 'U') IS NOT NULL
    DROP TABLE silver.erp_products;
GO

CREATE TABLE silver.erp_products
(
    product_id              NVARCHAR(50),
    product_name            NVARCHAR(300),
    category                NVARCHAR(150),
    subcategory             NVARCHAR(150),
    brand                   NVARCHAR(150),
    unit_cost               DECIMAL(10,2),
    selling_price           DECIMAL(10,2),
    supplier_id             NVARCHAR(50),
    launch_date             DATE,
    product_status          NVARCHAR(100),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 3. ERP.Orders
-- =============================================================
IF OBJECT_ID('silver.erp_orders', 'U') IS NOT NULL
    DROP TABLE silver.erp_orders;
GO

CREATE TABLE silver.erp_orders
(
    order_id                 NVARCHAR(50),
    customer_id              NVARCHAR(50),
    order_date               DATE,
    order_status             NVARCHAR(50),
    shipping_city            NVARCHAR(150),
    shipping_state           NVARCHAR(150),
    shipping_pincode         NVARCHAR(30),
    region_id                NVARCHAR(50),
    payment_method           NVARCHAR(100),
    promotion_id             NVARCHAR(50),
    shipping_fee             DECIMAL(10,2),
    order_total              DECIMAL(10,2),
    order_channel            NVARCHAR(100),
    shipping_method          NVARCHAR(100),
    expected_delivery_date   DATE,
    actual_delivery_date     DATE,
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 4. ERP.Order_Items
-- =============================================================
IF OBJECT_ID('silver.erp_order_items', 'U') IS NOT NULL
    DROP TABLE silver.erp_order_items;
GO

CREATE TABLE silver.erp_order_items
(
    order_item_id            NVARCHAR(50),
    order_id                 NVARCHAR(50),
    product_id               NVARCHAR(50),
    quantity                 INT,
    unit_price               DECIMAL(10,2),
    unit_cost                DECIMAL(10,2),
    discount_percentage      DECIMAL(10,2),
    discount_amount          DECIMAL(10,2),
    line_total               DECIMAL(10,2),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 5. ERP.Regions
-- =============================================================
IF OBJECT_ID('silver.erp_regions', 'U') IS NOT NULL
    DROP TABLE silver.erp_regions;
GO

CREATE TABLE silver.erp_regions
(
    region_id                NVARCHAR(50),
    region_name              NVARCHAR(100),
    state                    NVARCHAR(150),
    city                     NVARCHAR(150),
    warehouse_id             NVARCHAR(50),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 6. PaymentGateway.Payments
-- =============================================================
IF OBJECT_ID('silver.pg_payments', 'U') IS NOT NULL
    DROP TABLE silver.pg_payments;
GO

CREATE TABLE silver.pg_payments
(
    payment_id               NVARCHAR(50),
    order_id                 NVARCHAR(50),
    payment_date             DATE,
    payment_method           NVARCHAR(100),
    payment_status           NVARCHAR(50),
    transaction_reference    NVARCHAR(150),
    amount                   DECIMAL(10,2),
    refund_amount            DECIMAL(10,2),
    payment_gateway          NVARCHAR(100),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 7. RMS.Returns
-- =============================================================
IF OBJECT_ID('silver.rms_returns', 'U') IS NOT NULL
    DROP TABLE silver.rms_returns;
GO

CREATE TABLE silver.rms_returns
(
    return_id                NVARCHAR(50),
    order_id                 NVARCHAR(50),
    order_item_id            NVARCHAR(50),
    product_id               NVARCHAR(50),
    return_date              DATE,
    return_quantity          INT,
    return_reason            NVARCHAR(150),
    return_status            NVARCHAR(50),
    refund_amount            DECIMAL(10,2),
    condition                NVARCHAR(100),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO


-- =============================================================
-- 8. Marketing.Promotions
-- =============================================================
IF OBJECT_ID('silver.mkt_promotions', 'U') IS NOT NULL
    DROP TABLE silver.mkt_promotions;
GO

CREATE TABLE silver.mkt_promotions
(
    promotion_id             NVARCHAR(50),
    promotion_name           NVARCHAR(200),
    promotion_type           NVARCHAR(100),
    discount_percentage      DECIMAL(10,2),
    start_date               DATE,
    end_date                 DATE,
    minimum_order_value      DECIMAL(10,2),
    maximum_discount         DECIMAL(10,2),
    promotion_status         NVARCHAR(100),
    campaign_channel         NVARCHAR(100),
    marketing_spend          DECIMAL(10,2),
    dwh_create_date       DATETIME2 DEFAULT GETDATE()
);
GO
