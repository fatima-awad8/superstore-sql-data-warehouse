-- 06_indexes_optimization.sql
-- Indexes to speed up the analytical queries

USE DEPI_Superstore_DW;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactSales_CustomerKey')  DROP INDEX IX_FactSales_CustomerKey  ON dbo.FactSales;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactSales_ProductKey')   DROP INDEX IX_FactSales_ProductKey   ON dbo.FactSales;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactSales_GeographyKey') DROP INDEX IX_FactSales_GeographyKey ON dbo.FactSales;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactSales_OrderDateKey') DROP INDEX IX_FactSales_OrderDateKey ON dbo.FactSales;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactSales_ShipModeKey')  DROP INDEX IX_FactSales_ShipModeKey  ON dbo.FactSales;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DimDate_Year')           DROP INDEX IX_DimDate_Year           ON dbo.DimDate;
GO

-- Indexes on the foreign key columns used in JOINs
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerKey  ON dbo.FactSales(CustomerKey);
CREATE NONCLUSTERED INDEX IX_FactSales_ProductKey   ON dbo.FactSales(ProductKey);
CREATE NONCLUSTERED INDEX IX_FactSales_GeographyKey ON dbo.FactSales(GeographyKey);
CREATE NONCLUSTERED INDEX IX_FactSales_OrderDateKey ON dbo.FactSales(OrderDateKey);
CREATE NONCLUSTERED INDEX IX_FactSales_ShipModeKey  ON dbo.FactSales(ShipModeKey);
GO

-- Index on Year, used for filtering/grouping by year
CREATE NONCLUSTERED INDEX IX_DimDate_Year ON dbo.DimDate([Year]);
GO

PRINT 'Indexes created successfully.';
GO

-- Example: select specific columns and filter on an indexed column
-- instead of SELECT * with a function wrapped around the date column.
SELECT
    d.[Year],
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimDate AS d ON f.OrderDateKey = d.DateKey
WHERE d.[Year] = 2016
GROUP BY d.[Year];
GO
