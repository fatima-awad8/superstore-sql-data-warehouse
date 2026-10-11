-- 07_validation_queries.sql
-- Checks that the data loaded correctly into the star schema

USE DEPI_Superstore_DW;
GO

-- V1. Row counts for every table
SELECT 'DimDate'      AS TableName, COUNT(*) AS RowCount FROM dbo.DimDate
UNION ALL
SELECT 'DimCustomer',  COUNT(*) FROM dbo.DimCustomer
UNION ALL
SELECT 'DimProduct',   COUNT(*) FROM dbo.DimProduct
UNION ALL
SELECT 'DimGeography', COUNT(*) FROM dbo.DimGeography
UNION ALL
SELECT 'DimShipMode',  COUNT(*) FROM dbo.DimShipMode
UNION ALL
SELECT 'FactSales',    COUNT(*) FROM dbo.FactSales;
GO

-- V2. FactSales row count (should match the source Excel row count)
SELECT COUNT(*) AS FactSalesRowCount FROM dbo.FactSales;
GO

-- V3. Check for NULL foreign keys in FactSales (should return 0 rows)
SELECT *
FROM dbo.FactSales
WHERE CustomerKey  IS NULL
   OR ProductKey   IS NULL
   OR GeographyKey IS NULL
   OR ShipModeKey  IS NULL
   OR OrderDateKey IS NULL
   OR ShipDateKey  IS NULL;
GO

-- V4. Check for orphan foreign keys (should return 0 rows for each)
SELECT f.SalesKey, 'Orphan CustomerKey' AS Issue
FROM dbo.FactSales f
LEFT JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL

UNION ALL

SELECT f.SalesKey, 'Orphan ProductKey'
FROM dbo.FactSales f
LEFT JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL

UNION ALL

SELECT f.SalesKey, 'Orphan GeographyKey'
FROM dbo.FactSales f
LEFT JOIN dbo.DimGeography g ON f.GeographyKey = g.GeographyKey
WHERE g.GeographyKey IS NULL

UNION ALL

SELECT f.SalesKey, 'Orphan ShipModeKey'
FROM dbo.FactSales f
LEFT JOIN dbo.DimShipMode sm ON f.ShipModeKey = sm.ShipModeKey
WHERE sm.ShipModeKey IS NULL

UNION ALL

SELECT f.SalesKey, 'Orphan OrderDateKey'
FROM dbo.FactSales f
LEFT JOIN dbo.DimDate d1 ON f.OrderDateKey = d1.DateKey
WHERE d1.DateKey IS NULL

UNION ALL

SELECT f.SalesKey, 'Orphan ShipDateKey'
FROM dbo.FactSales f
LEFT JOIN dbo.DimDate d2 ON f.ShipDateKey = d2.DateKey
WHERE d2.DateKey IS NULL;
GO

-- V5. Check for duplicate business keys (should return 0 rows)
SELECT CustomerID, COUNT(*) AS Occurrences
FROM dbo.DimCustomer GROUP BY CustomerID HAVING COUNT(*) > 1;

SELECT ProductID, COUNT(*) AS Occurrences
FROM dbo.DimProduct GROUP BY ProductID HAVING COUNT(*) > 1;

SELECT RowID, COUNT(*) AS Occurrences
FROM dbo.FactSales GROUP BY RowID HAVING COUNT(*) > 1;
GO

-- V6. Reconciliation against the original Excel totals
-- Expected: Total Sales = 501239.8908, Total Profit = 39706.3625
SELECT
    SUM(Sales)  AS FactSales_TotalSales,
    SUM(Profit) AS FactSales_TotalProfit
FROM dbo.FactSales;
GO

PRINT 'Validation checks complete. All orphan/NULL/duplicate checks should return 0 rows.';
GO
