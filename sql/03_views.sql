-- 03_views.sql
-- SQL views for reporting

USE DEPI_Superstore_DW;
GO

IF OBJECT_ID('dbo.vw_SalesSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_SalesSummary;
GO
IF OBJECT_ID('dbo.vw_CustomerPerformance', 'V') IS NOT NULL DROP VIEW dbo.vw_CustomerPerformance;
GO

-- View 1: all dimensions joined to the fact table
CREATE VIEW dbo.vw_SalesSummary AS
SELECT
    f.SalesKey,
    f.OrderID,
    od.FullDate     AS OrderDate,
    sd.FullDate     AS ShipDate,
    sm.ShipMode,
    c.CustomerID,
    c.CustomerName,
    c.Segment,
    g.City,
    g.State,
    g.Region,
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    f.Sales,
    f.Quantity,
    f.Discount,
    f.Profit
FROM dbo.FactSales AS f
INNER JOIN dbo.DimCustomer  AS c  ON f.CustomerKey  = c.CustomerKey
INNER JOIN dbo.DimProduct   AS p  ON f.ProductKey   = p.ProductKey
INNER JOIN dbo.DimGeography AS g  ON f.GeographyKey = g.GeographyKey
INNER JOIN dbo.DimShipMode  AS sm ON f.ShipModeKey  = sm.ShipModeKey
INNER JOIN dbo.DimDate      AS od ON f.OrderDateKey = od.DateKey
INNER JOIN dbo.DimDate      AS sd ON f.ShipDateKey  = sd.DateKey;
GO

-- View 2: sales/profit totals per customer
CREATE VIEW dbo.vw_CustomerPerformance AS
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Segment,
    COUNT(DISTINCT f.OrderID)                AS TotalOrders,
    SUM(f.Sales)                             AS TotalSales,
    SUM(f.Profit)                            AS TotalProfit,
    SUM(f.Quantity)                          AS TotalQuantity,
    SUM(f.Sales) / COUNT(DISTINCT f.OrderID) AS AvgOrderValue
FROM dbo.FactSales AS f
INNER JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerID, c.CustomerName, c.Segment;
GO

PRINT 'Views vw_SalesSummary and vw_CustomerPerformance created.';
GO

SELECT TOP 10 * FROM dbo.vw_SalesSummary ORDER BY OrderDate DESC;
SELECT TOP 10 * FROM dbo.vw_CustomerPerformance ORDER BY TotalSales DESC;
GO
