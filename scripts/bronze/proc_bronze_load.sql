/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
    - Wraps the full load in a single transaction: all 8 tables load successfully
      and commit together, or any single failure rolls the entire batch back,
      leaving Bronze exactly as it was before the procedure ran.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    BEGIN TRY

        DECLARE
            @start_time       DATETIME,
            @end_time         DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time   DATETIME;

        SET @batch_start_time = GETDATE();

        BEGIN TRANSACTION;

        PRINT '===============================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===============================================';


        /* =============================================================
           1. CRM - Customers
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading CRM Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_customers';

        TRUNCATE TABLE bronze.crm_customers;

        PRINT '>> Inserting Data Into: bronze.crm_customers';

        BULK INSERT bronze.crm_customers
        FROM 'D:\Raw Data\CRM_Customers.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           2. ERP - Products
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading ERP Products Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_products';

        TRUNCATE TABLE bronze.erp_products;

        PRINT '>> Inserting Data Into: bronze.erp_products';

        BULK INSERT bronze.erp_products
        FROM 'D:\Raw Data\ERP_Products.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           3. ERP - Orders
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading ERP Orders Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_orders';

        TRUNCATE TABLE bronze.erp_orders;

        PRINT '>> Inserting Data Into: bronze.erp_orders';

        BULK INSERT bronze.erp_orders
        FROM 'D:\Raw Data\ERP_Orders.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           4. ERP - Order Items
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading ERP Order Items Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_order_items';

        TRUNCATE TABLE bronze.erp_order_items;

        PRINT '>> Inserting Data Into: bronze.erp_order_items';

        BULK INSERT bronze.erp_order_items
        FROM 'D:\Raw Data\ERP_Order_Items.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           5. ERP - Regions
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading ERP Regions Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_regions';

        TRUNCATE TABLE bronze.erp_regions;

        PRINT '>> Inserting Data Into: bronze.erp_regions';

        BULK INSERT bronze.erp_regions
        FROM 'D:\Raw Data\ERP_Regions.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           6. PG - Payments
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading PG Payments Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.pg_payments';

        TRUNCATE TABLE bronze.pg_payments;

        PRINT '>> Inserting Data Into: bronze.pg_payments';

        BULK INSERT bronze.pg_payments
        FROM 'D:\Raw Data\PG_Payments.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           7. RMS - Returns
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading RMS Returns Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.rms_returns';

        TRUNCATE TABLE bronze.rms_returns;

        PRINT '>> Inserting Data Into: bronze.rms_returns';

        BULK INSERT bronze.rms_returns
        FROM 'D:\Raw Data\RMS_Returns.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           8. MKT - Promotions
           ============================================================= */

        PRINT '-----------------------------------------------';
        PRINT 'Loading MKT Promotions Table';
        PRINT '-----------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.mkt_promotions';

        TRUNCATE TABLE bronze.mkt_promotions;

        PRINT '>> Inserting Data Into: bronze.mkt_promotions';

        BULK INSERT bronze.mkt_promotions
        FROM 'D:\Raw Data\MKT_Promotions.csv'
        WITH
        (
            FIRSTROW        = 2,
            FORMAT          = 'CSV',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0a',
            FIELDQUOTE      = '"',
            CODEPAGE        = '65001',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Loading Time : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' Seconds';

        PRINT '>> -----------------------------';


        /* =============================================================
           Batch Completion
           ============================================================= */

        COMMIT TRANSACTION;

        SET @batch_end_time = GETDATE();

        PRINT '===============================================';
        PRINT 'Bronze Layer Loading Completed';
        PRINT 'Total Batch Time : '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
            + ' Seconds';
        PRINT '===============================================';


    END TRY


    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT '===================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================';

    END CATCH

END;
GO
