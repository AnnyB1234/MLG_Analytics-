/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
        SET @batch_start_time = GETDATE();
        PRINT'===============================================';
        PRINT'Loading Bronze Layer';
        PRINT'===============================================';
    
        PRINT'-----------------------------------------------';
        PRINT'Loading CRD Table';
        PRINT'-----------------------------------------------';
        
        SET @start_time = GETDATE();
        PRINT'>> Truncating Table: bronze.crd_region';
        TRUNCATE TABLE bronze.crd_region;
        PRINT'>> Inserting Data Into: bronze.crd_region';
        BULK INSERT bronze.crd_region
        FROM 'D:\source_crd\src_region.csv'
        WITH (
            FORMAT = 'CSV',                  -- Source file is a CSV
            FIRSTROW = 2,                    -- Skip header row
            FIELDTERMINATOR = ',',           -- Columns separated by comma
            ROWTERMINATOR = '0x0A',          -- New line indicates a new record , your computer inserts a special hidden character called a newline.
                                             -- SQL Server needs to know which newline character your file uses. So this line ROWTERMINATOR = '0x0A'
                                             -- means: "Whenever you find a newline (line break), stop reading the current row and start the next one."
   
            CODEPAGE = '65001',              -- CSV files are UTF-8 encoded, so SQL Server can correctly read special characters.
            TABLOCK                          -- Improves bulk load performance
                                                /* SQL Server thinks:   Lock the table.
                                                                        Import all 100,000 rows.
                                                                        Unlock the table
                                                                        This is much faster.    */
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';

        -- 2. VENDOR


        PRINT'-----------------------------------------------';
        PRINT'Loading VMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.vms_vendor';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.vms_vendor;
        PRINT'>> Inserting Data Into: bronze.vms_vendor';
        BULK INSERT bronze.vms_vendor
        FROM 'D:\source_vms\src_vendor.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
   

        -- 3. PART

        PRINT'-----------------------------------------------';
        PRINT'Loading CMMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.cmms_part';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.cmms_part;
        PRINT'>> Inserting Data Into: bronze.cmms_part';
        BULK INSERT bronze.cmms_part
        FROM 'D:\source_cmms\src_part.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
   

        -- 4. FAULT CODE

        PRINT'-----------------------------------------------';
        PRINT'Loading TMS/IOT Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.tms_iot_fault_code';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.tms_iot_fault_code;
        PRINT'>> Inserting Data Into: bronze.tms_iot_fault_code';
        BULK INSERT bronze.tms_iot_fault_code
        FROM 'D:\source_tms_iot\src_fault_code.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    

        -- 5. WARRANTY TERM

        PRINT'-----------------------------------------------';
        PRINT'Loading OEM Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table:  bronze.oem_warranty_term';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.oem_warranty_term ;
        PRINT'>> Inserting Data Into:  bronze.oem_warranty_term';
        BULK INSERT bronze.oem_warranty_term
        FROM 'D:\source_oem\src_warranty_term.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    
   

        -- 6. ROUTE

    
        PRINT'-----------------------------------------------';
        PRINT'Loading TMS Table';
        PRINT'-----------------------------------------------';

    
        PRINT'>> Truncating Table: bronze.tms_route';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.tms_route;
        PRINT'>> Inserting Data Into: bronze.tms_route';
        BULK INSERT bronze.tms_route
        FROM 'D:\source_tms\src_route.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
  

        -- 7. DRIVER

        
        PRINT'-----------------------------------------------';
        PRINT'Loading HRIS Table';
        PRINT'-----------------------------------------------';

        
        PRINT'>> Truncating Table: bronze.hris_driver';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.hris_driver;
        PRINT'>> Inserting Data Into: bronze.hris_driver';
        BULK INSERT bronze.hris_driver
        FROM 'D:\source_hris\src_driver.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    

        -- 8. VEHICLE

        PRINT'-----------------------------------------------';
        PRINT'Loading FMS Table';
        PRINT'-----------------------------------------------';
            
        PRINT'>> Truncating Table: bronze.fms_vehicle';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.fms_vehicle;
        PRINT'>> Inserting Data Into: bronze.fms_vehicle';
        BULK INSERT bronze.fms_vehicle
        FROM 'D:\source_fms\src_vehicle.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';

        -- 9. VEHICLE DRIVER ASSIGNMENT

        PRINT'-----------------------------------------------';
        PRINT'Loading FMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table:  bronze.fms_vehicle_driver_assignment';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.fms_vehicle_driver_assignment;
        PRINT'>> Inserting Data Into: bronze.fms_vehicle_driver_assignment';
        BULK INSERT bronze.fms_vehicle_driver_assignment
        FROM 'D:\source_fms\src_vehicle_driver_assignment.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';

        -- 10. VEHICLE VENDOR CONTRACT
    
        PRINT'-----------------------------------------------';
        PRINT'Loading VMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.vms_vehicle_vendor_contract';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.vms_vehicle_vendor_contract;
        PRINT'>> Inserting Data Into: bronze.vms_vehicle_vendor_contract';
        BULK INSERT bronze.vms_vehicle_vendor_contract
        FROM 'D:\source_vms\src_vehicle_vendor_contract.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';


        -- 11. WORK ORDER

        PRINT'-----------------------------------------------';
        PRINT'Loading CMMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table:  bronze.cmms_work_order';
        SET @start_time = GETDATE();
        TRUNCATE TABLE  bronze.cmms_work_order;
        PRINT'>> Inserting Data Into:  bronze.cmms_work_order';
        BULK INSERT bronze.cmms_work_order
        FROM 'D:\source_cmms\src_work_order.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    


        -- 12. PARTS USAGE

        PRINT'-----------------------------------------------';
        PRINT'Loading CMMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.cmms_parts_usage';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.cmms_parts_usage;
        PRINT'>> Inserting Data Into: bronze.cmms_parts_usage';
        BULK INSERT bronze.cmms_parts_usage
        FROM 'D:\source_cmms\src_parts_usage.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
   


        -- 13. WARRANTY CLAIM

    
        PRINT'-----------------------------------------------';
        PRINT'Loading OEM Table';
        PRINT'-----------------------------------------------';

    
        PRINT'>> Truncating Table: bronze.oem_warranty_claim';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.oem_warranty_claim;
        PRINT'>> Inserting Data Into: bronze.oem_warranty_claim';
        BULK INSERT bronze.oem_warranty_claim
        FROM 'D:\source_oem\src_warranty_claim.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';

        -- 14. TELEMATICS FAULT EVENT

        PRINT'-----------------------------------------------';
        PRINT'Loading TMS/IOT Table';
        PRINT'-----------------------------------------------';

      
        PRINT'>> Truncating Table: bronze.tms_iot_telematics_fault_event';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.tms_iot_telematics_fault_event;
        PRINT'>> Inserting Data Into: bronze.tms_iot_telematics_fault_event';
        BULK INSERT bronze.tms_iot_telematics_fault_event
        FROM 'D:\source_tms_iot\src_telematics_fault_event.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
  


        -- 15. DOWNTIME


        PRINT'-----------------------------------------------';
        PRINT'Loading CMMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.cmms_downtime';
        SET @start_time = GETDATE();
        TRUNCATE TABLE  bronze.cmms_downtime;
        PRINT'>> Inserting Data Into: bronze.cmms_downtime';
        BULK INSERT bronze.cmms_downtime
        FROM 'D:\source_cmms\src_downtime.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    

        -- 16. DELIVERY PERFORMANCE

        PRINT'-----------------------------------------------';
        PRINT'Loading TMS Table';
        PRINT'-----------------------------------------------';

        PRINT'>> Truncating Table: bronze.tms_delivery_performance';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.tms_delivery_performance ;
        PRINT'>> Inserting Data Into: bronze.tms_delivery_performance';
        BULK INSERT bronze.tms_delivery_performance
        FROM 'D:\source_tms\src_delivery_performance.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
    

        -- 17. FUEL TRANSACTION

        PRINT'-----------------------------------------------';
        PRINT'Loading FCS Table';
        PRINT'-----------------------------------------------';

    
        PRINT'>> Truncating Table: bronze.fcs_fuel_transaction';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.fcs_fuel_transaction;
        PRINT'>> Inserting Data Into: bronze.fcs_fuel_transaction';
        BULK INSERT bronze.fcs_fuel_transaction
        FROM 'D:\source_fcs\src_fuel_transaction.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> Loading Time : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)  + ' Seconds';
        PRINT'>> -----------------------------';
        SET @batch_end_time = GETDATE();
        PRINT'===================================================';
        PRINT'Loading Bronze Layer Completed';
        PRINT'Loading Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'Seconds';
        PRINT'===================================================';
    END TRY
    BEGIN CATCH
        PRINT'===================================================';
        PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT'Error Message' + ERROR_MESSAGE();
        PRINT'Error Message' + CAST(ERROR_NUMBER () AS NVARCHAR);
        PRINT'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT'===================================================';
    END CATCH
END


