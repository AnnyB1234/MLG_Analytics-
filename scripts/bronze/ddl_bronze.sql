/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('bronze.crd_region', 'U') IS NOT NULL 
    DROP TABLE bronze.crd_region;
GO
CREATE TABLE bronze.crd_region (
    region_id       VARCHAR(50),
    region_name     VARCHAR(200),
    region_manager  VARCHAR(200)
);
GO

IF OBJECT_ID ('bronze.vms_vendor', 'U') IS NOT NULL 
    DROP TABLE bronze.vms_vendor;
GO
  
CREATE TABLE bronze.vms_vendor (
    vendor_id            VARCHAR(50),
    vendor_name          VARCHAR(300),
    vendor_type          VARCHAR(100),
    region_id            VARCHAR(50),
    contact_email        VARCHAR(200),
    is_active             VARCHAR(20),   -- mixed boolean encodings
    contract_start_date  VARCHAR(50)    -- mixed date formats
);
GO
IF OBJECT_ID ('bronze.cmms_part', 'U') IS NOT NULL 
    DROP TABLE  bronze.cmms_part;
GO
CREATE TABLE bronze.cmms_part (
    part_number     VARCHAR(50),
    part_name       VARCHAR(300),
    part_category   VARCHAR(100),
    oem_flag        VARCHAR(20),
    standard_cost   VARCHAR(50),        -- occasionally "$1,364.32"
    supplier_id     VARCHAR(50)
);
GO
IF OBJECT_ID ('bronze.tms_iot_fault_code', 'U') IS NOT NULL 
    DROP TABLE bronze.tms_iot_fault_code;
GO
CREATE TABLE bronze.tms_iot_fault_code (
    fault_code            VARCHAR(20),
    fault_description     VARCHAR(500),
    component_category    VARCHAR(100),
    severity_level        VARCHAR(50),
    is_safety_critical    VARCHAR(20)
);
GO
IF OBJECT_ID ('bronze.oem_warranty_term', 'U') IS NOT NULL 
    DROP TABLE bronze.oem_warranty_term;
GO
CREATE TABLE bronze.oem_warranty_term (
    make                    VARCHAR(100),
    component_category      VARCHAR(100),
    coverage_months         VARCHAR(20),
    effective_start_date    VARCHAR(50),
    effective_end_date      VARCHAR(50),
    is_current              VARCHAR(20)
);
GO
IF OBJECT_ID ('bronze.tms_route', 'U') IS NOT NULL 
    DROP TABLE bronze.tms_route;
GO
CREATE TABLE bronze.tms_route (
    route_id                VARCHAR(50),
    route_name              VARCHAR(300),
    origin_city             VARCHAR(200),
    destination_city        VARCHAR(200),
    planned_distance_km     VARCHAR(50),
    region_id               VARCHAR(50),
    is_active                VARCHAR(20)
);
GO
IF OBJECT_ID ('bronze.hris_driver', 'U') IS NOT NULL 
    DROP TABLE bronze.hris_driver;
GO
CREATE TABLE bronze.hris_driver (
    driver_id            VARCHAR(50),
    driver_name          VARCHAR(300),
    license_number       VARCHAR(50),
    license_class        VARCHAR(50),
    hire_date            VARCHAR(50),
    employment_status    VARCHAR(50),
    region_id            VARCHAR(50)
);
GO
IF OBJECT_ID ('bronze.fms_vehicle', 'U') IS NOT NULL 
    DROP TABLE bronze.fms_vehicle;
GO
CREATE TABLE bronze.fms_vehicle (
    vin                VARCHAR(50),
    vehicle_id         VARCHAR(50),
    make               VARCHAR(100),
    model              VARCHAR(100),
    year               VARCHAR(20),
    vehicle_class      VARCHAR(100),
    purchase_date      VARCHAR(50),
    initial_mileage    VARCHAR(50),
    is_current          VARCHAR(20),
    region_id          VARCHAR(50)
);
GO
-- BRIDGE SOURCES (SCD2)

IF OBJECT_ID ('bronze.fms_vehicle_driver_assignment', 'U') IS NOT NULL 
    DROP TABLE bronze.fms_vehicle_driver_assignment;
GO
CREATE TABLE bronze.fms_vehicle_driver_assignment (
    vehicle_vin              VARCHAR(50),
    driver_id                VARCHAR(50),
    assignment_start_date    VARCHAR(50),
    assignment_end_date      VARCHAR(50),
    is_current                VARCHAR(20)
);
GO

IF OBJECT_ID ('bronze.vms_vehicle_vendor_contract ', 'U') IS NOT NULL 
    DROP TABLE bronze.vms_vehicle_vendor_contract ;

GO
CREATE TABLE bronze.vms_vehicle_vendor_contract (
    vehicle_vin            VARCHAR(50),
    vendor_id              VARCHAR(50),
    contract_start_date    VARCHAR(50),
    contract_end_date      VARCHAR(50),
    contract_type          VARCHAR(50),
    is_active               VARCHAR(20)
);
GO

-- FACT SOURCES


IF OBJECT_ID ('bronze.cmms_work_order ', 'U') IS NOT NULL 
    DROP TABLE bronze.cmms_work_order ;
GO
CREATE TABLE bronze.cmms_work_order (
    workorder_id                    VARCHAR(50),
    vehicle_vin                     VARCHAR(50),
    vendor_id                       VARCHAR(50),
    workorder_date                  VARCHAR(50),
    warranty_component_category     VARCHAR(100),
    vehicle_make                    VARCHAR(100),
    work_order_type                 VARCHAR(50),
    labor_hours                     VARCHAR(50),
    labor_cost                      VARCHAR(50),
    part_cost                       VARCHAR(50),
    total_cost                      VARCHAR(50),
    warranty_claimed_flag           VARCHAR(20),
    warranty_claim_status           VARCHAR(50),
    warranty_rejection_reason       VARCHAR(300)
);
GO

IF OBJECT_ID ('bronze.cmms_parts_usage', 'U') IS NOT NULL 
    DROP TABLE bronze.cmms_parts_usage ;
GO
CREATE TABLE bronze.cmms_parts_usage (
    workorder_id             VARCHAR(50),
    part_number              VARCHAR(50),
    vehicle_vin              VARCHAR(50),
    usage_date               VARCHAR(50),
    quantity_used             VARCHAR(50),
    unit_cost                VARCHAR(50),
    total_parts_cost         VARCHAR(50),
    warranty_covered_flag    VARCHAR(20)
);
GO
IF OBJECT_ID ('bronze.oem_warranty_claim', 'U') IS NOT NULL 
    DROP TABLE bronze.oem_warranty_claim ;
GO
CREATE TABLE bronze.oem_warranty_claim (
    claim_number               VARCHAR(50),
    workorder_id               VARCHAR(50),
    vehicle_vin                VARCHAR(50),
    vendor_id                  VARCHAR(50),
    claim_submitted_date       VARCHAR(50),
    claim_amount_requested     VARCHAR(50),
    claim_amount_approved      VARCHAR(50),
    claim_status                VARCHAR(50),
    rejection_reason           VARCHAR(300),
    processing_days            VARCHAR(50)
);

GO
IF OBJECT_ID ('bronze.tms_iot_telematics_fault_event', 'U') IS NOT NULL 
    DROP TABLE bronze.tms_iot_telematics_fault_event;
GO
CREATE TABLE bronze.tms_iot_telematics_fault_event (
    vehicle_vin        VARCHAR(50),
    fault_code         VARCHAR(20),
    driver_id          VARCHAR(50),
    route_id           VARCHAR(50),
    event_timestamp    VARCHAR(50),
    vehicle_mileage    VARCHAR(50),
    severity_level     VARCHAR(50),
    fault_status       VARCHAR(50)
);
GO
IF OBJECT_ID ('bronze.cmms_downtime', 'U') IS NOT NULL 
    DROP TABLE bronze.cmms_downtime;
GO
CREATE TABLE bronze.cmms_downtime (
    vehicle_vin        VARCHAR(50),
    workorder_id       VARCHAR(50),
    vendor_id          VARCHAR(50),
    downtime_start     VARCHAR(50),
    downtime_end       VARCHAR(50),
    downtime_hours     VARCHAR(50),
    downtime_reason    VARCHAR(200),
    is_planned          VARCHAR(20)
);

GO
IF OBJECT_ID ('bronze.tms_delivery_performance', 'U') IS NOT NULL 
    DROP TABLE bronze.tms_delivery_performance;
GO
CREATE TABLE bronze.tms_delivery_performance (
    delivery_id                        VARCHAR(50),
    route_id                           VARCHAR(50),
    vehicle_vin                        VARCHAR(50),
    driver_id                          VARCHAR(50),
    delivery_date                      VARCHAR(50),
    planned_distance_km                VARCHAR(50),
    actual_distance_km                 VARCHAR(50),
    planned_delivery_time_minutes      VARCHAR(50),
    actual_delivery_time_minutes       VARCHAR(50),
    on_time_flag                        VARCHAR(20),
    fuel_consumed_liters               VARCHAR(50)
);

GO
IF OBJECT_ID ('bronze.fcs_fuel_transaction', 'U') IS NOT NULL 
    DROP TABLE bronze.fcs_fuel_transaction;
GO
CREATE TABLE bronze.fcs_fuel_transaction (
    fuel_transaction_id      VARCHAR(50),
    vehicle_vin              VARCHAR(50),
    driver_id                VARCHAR(50),
    vendor_id                VARCHAR(50),
    transaction_date         VARCHAR(50),
    fuel_type                VARCHAR(50),
    fuel_quantity_liters     VARCHAR(50),
    fuel_cost                VARCHAR(50),
    vehicle_mileage          VARCHAR(50),
    fuel_efficiency_kmpl     VARCHAR(50)
);
GO
