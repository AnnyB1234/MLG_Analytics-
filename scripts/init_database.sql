/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'meridian_logistics_dwh' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'meridian_logistics_dwh' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'meridian_logistics_dwh' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'meridian_logistics_dwh')
BEGIN
    ALTER DATABASE meridian_logistics_dwh SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE meridian_logistics_dwh;
END;
GO

-- Create the 'meridian_logistics_dwh' database
CREATE DATABASE meridian_logistics_dwh;
GO

USE meridian_logistics_dwh;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
