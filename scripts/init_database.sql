/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'ShopKartDW' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'ShopKartDW' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'meridian_logistics_dwh' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ShopKartDW')
BEGIN
    ALTER DATABASE ShopKartDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ShopKartDW;
END;
GO

-- Create the 'meridian_logistics_dwh' database
CREATE DATABASE ShopKartDW;
GO                                 ------- Go: Separate batches when working with multiple SQL statements

USE ShopKartDW;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
