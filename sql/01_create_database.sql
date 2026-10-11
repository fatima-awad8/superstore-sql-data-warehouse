-- 01_create_database.sql
-- Create the database and switch to it

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'DEPI_Superstore_DW')
BEGIN
    ALTER DATABASE DEPI_Superstore_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DEPI_Superstore_DW;
END
GO

CREATE DATABASE DEPI_Superstore_DW;
GO

USE DEPI_Superstore_DW;
GO

PRINT 'Database DEPI_Superstore_DW created successfully.';
GO
