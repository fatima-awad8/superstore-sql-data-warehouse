-- 04_stored_procedures.sql
-- Stored procedures for KPI reporting

USE DEPI_Superstore_DW;
GO

IF OBJECT_ID('dbo.usp_GetSalesByYear', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetSalesByYear;
GO
IF OBJECT_ID('dbo.usp_GetRegionPerformance', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetRegionPerformance;
GO

-- Procedure 1: sales and profit per category for a given year
CREATE PROCEDURE dbo.usp_GetSalesByYear
    @Year INT
AS
BEGIN
    SELECT
        d.[Year],
        p.Category,
        COUNT(DISTINCT f.OrderID) AS TotalOrders,
        SUM(f.Sales)              AS TotalSales,
        SUM(f.Profit)             AS TotalProfit,
        SUM(f.Quantity)           AS TotalQuantity
    FROM dbo.FactSales AS f
    INNER JOIN dbo.DimDate    AS d ON f.OrderDateKey = d.DateKey
    INNER JOIN dbo.DimProduct AS p ON f.ProductKey   = p.ProductKey
    WHERE d.[Year] = @Year
    GROUP BY d.[Year], p.Category
    ORDER BY TotalSales DESC;
END
GO

-- Procedure 2: sales and profit per state for a given region
CREATE PROCEDURE dbo.usp_GetRegionPerformance
    @Region NVARCHAR(50)
AS
BEGIN
    SELECT
        g.Region,
        g.State,
        COUNT(DISTINCT f.OrderID) AS TotalOrders,
        SUM(f.Sales)              AS TotalSales,
        SUM(f.Profit)             AS TotalProfit
    FROM dbo.FactSales AS f
    INNER JOIN dbo.DimGeography AS g ON f.GeographyKey = g.GeographyKey
    WHERE g.Region = @Region
    GROUP BY g.Region, g.State
    ORDER BY TotalSales DESC;
END
GO

PRINT 'Stored procedures created.';
GO

EXEC dbo.usp_GetSalesByYear @Year = 2016;
GO

EXEC dbo.usp_GetRegionPerformance @Region = 'Central';
GO
