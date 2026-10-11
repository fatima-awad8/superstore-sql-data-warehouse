-- 05_analytical_queries.sql
-- 21 business queries covering sales, profitability, customer behavior,
-- product analysis, and shipping analysis.

USE DEPI_Superstore_DW;
GO

/* ===================== SECTION A - SALES ANALYSIS ===================== */

-- Q1. Overall company KPIs
SELECT
    SUM(f.Sales)                                 AS TotalSales,
    SUM(f.Profit)                                AS TotalProfit,
    SUM(f.Profit) / SUM(f.Sales)                 AS ProfitMargin,
    COUNT(DISTINCT f.OrderID)                    AS TotalOrders,
    COUNT(DISTINCT f.CustomerKey)                AS TotalCustomers,
    SUM(f.Quantity)                              AS TotalQuantity,
    SUM(f.Sales) / COUNT(DISTINCT f.OrderID)     AS AvgOrderValue
FROM dbo.FactSales AS f;
GO

-- Q2. Sales and profit by year
SELECT
    d.[Year],
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimDate AS d ON f.OrderDateKey = d.DateKey
GROUP BY d.[Year]
ORDER BY d.[Year];
GO

-- Q3. Monthly sales trend
SELECT
    d.[Year],
    d.[Month],
    d.MonthName,
    SUM(f.Sales) AS MonthlySales
FROM dbo.FactSales AS f
JOIN dbo.DimDate AS d ON f.OrderDateKey = d.DateKey
GROUP BY d.[Year], d.[Month], d.MonthName
ORDER BY d.[Year], d.[Month];
GO

-- Q4. Sales by product category
SELECT
    p.Category,
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalSales DESC;
GO

-- Q5. Sales by sub-category
SELECT
    p.Category,
    p.SubCategory,
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.Category, p.SubCategory
ORDER BY TotalSales DESC;
GO

-- Q6. Sales and profit by state
SELECT
    g.State,
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimGeography AS g ON f.GeographyKey = g.GeographyKey
GROUP BY g.State
ORDER BY TotalSales DESC;
GO

-- Q7. Year-over-year sales growth (CTE, joined to itself on Year - 1)
WITH YearlySales AS (
    SELECT d.[Year], SUM(f.Sales) AS TotalSales
    FROM dbo.FactSales AS f
    JOIN dbo.DimDate AS d ON f.OrderDateKey = d.DateKey
    GROUP BY d.[Year]
)
SELECT
    y1.[Year],
    y1.TotalSales,
    y2.TotalSales AS PreviousYearSales,
    (y1.TotalSales - y2.TotalSales) / y2.TotalSales AS YoYGrowth
FROM YearlySales AS y1
LEFT JOIN YearlySales AS y2 ON y1.[Year] = y2.[Year] + 1
ORDER BY y1.[Year];
GO


/* ===================== SECTION B - PROFITABILITY ===================== */

-- Q8. Profit margin per category
SELECT
    p.Category,
    SUM(f.Sales)                            AS TotalSales,
    SUM(f.Profit)                           AS TotalProfit,
    SUM(f.Profit) / SUM(f.Sales)            AS ProfitMargin
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY ProfitMargin DESC;
GO

-- Q9. Loss-making sub-categories (CASE statement)
SELECT
    p.Category,
    p.SubCategory,
    SUM(f.Profit) AS TotalProfit,
    CASE
        WHEN SUM(f.Profit) < 0 THEN 'Loss-Making'
        ELSE 'Profitable'
    END AS ProfitStatus
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.Category, p.SubCategory
ORDER BY TotalProfit ASC;
GO

-- Q10. Top 10 most profitable products
SELECT TOP 10
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY TotalProfit DESC;
GO

-- Q11. Products that lose money overall
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductID, p.ProductName, p.Category, p.SubCategory
HAVING SUM(f.Profit) < 0
ORDER BY TotalProfit ASC;
GO

-- Q12. Category + segment combinations that lose money (3-table join)
SELECT
    p.Category,
    c.Segment,
    SUM(f.Profit) AS TotalProfit,
    CASE WHEN SUM(f.Profit) < 0 THEN 'Loss' ELSE 'Profit' END AS Status
FROM dbo.FactSales AS f
JOIN dbo.DimProduct  AS p ON f.ProductKey  = p.ProductKey
JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
GROUP BY p.Category, c.Segment
HAVING SUM(f.Profit) < 0
ORDER BY TotalProfit ASC;
GO


/* ===================== SECTION C - CUSTOMER BEHAVIOR ===================== */

-- Q13. Top 10 customers by total sales
SELECT TOP 10
    c.CustomerID,
    c.CustomerName,
    c.Segment,
    SUM(f.Sales)  AS TotalSales,
    SUM(f.Profit) AS TotalProfit
FROM dbo.FactSales AS f
JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerID, c.CustomerName, c.Segment
ORDER BY TotalSales DESC;
GO

-- Q14. Orders and average order value per customer
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT f.OrderID)                AS OrderCount,
    SUM(f.Sales)                             AS TotalSales,
    SUM(f.Sales) / COUNT(DISTINCT f.OrderID) AS AvgOrderValue
FROM dbo.FactSales AS f
JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalSales DESC;
GO

-- Q15. Customers who spend more than the average customer (subquery)
SELECT
    c.CustomerName,
    SUM(f.Sales) AS TotalSales
FROM dbo.FactSales AS f
JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerName
HAVING SUM(f.Sales) > (
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT SUM(Sales) AS CustomerTotal
        FROM dbo.FactSales
        GROUP BY CustomerKey
    ) AS PerCustomer
)
ORDER BY TotalSales DESC;
GO

-- Q16. Customer value tiers (CTE + CASE)
WITH CustomerTotals AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSales
    FROM dbo.FactSales AS f
    JOIN dbo.DimCustomer AS c ON f.CustomerKey = c.CustomerKey
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT
    CustomerID,
    CustomerName,
    TotalSales,
    CASE
        WHEN TotalSales >= 5000 THEN 'High Value'
        WHEN TotalSales >= 1500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS ValueTier
FROM CustomerTotals
ORDER BY TotalSales DESC;
GO


/* ===================== SECTION D - PRODUCT ANALYSIS ===================== */

-- Q17. Top 10 best-selling products by quantity
SELECT TOP 10
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(f.Quantity) AS TotalQuantitySold
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY TotalQuantitySold DESC;
GO

-- Q18. Products that sell above the average product sales (subquery)
SELECT
    p.ProductName,
    p.Category,
    SUM(f.Sales) AS TotalSales
FROM dbo.FactSales AS f
JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.Category
HAVING SUM(f.Sales) > (
    SELECT AVG(ProductTotal)
    FROM (
        SELECT SUM(Sales) AS ProductTotal
        FROM dbo.FactSales
        GROUP BY ProductKey
    ) AS PerProduct
)
ORDER BY TotalSales DESC;
GO

-- Q19. Discount level vs profit (CASE statement)
SELECT
    CASE
        WHEN f.Discount = 0     THEN 'No Discount'
        WHEN f.Discount <= 0.20 THEN 'Low (1-20%)'
        WHEN f.Discount <= 0.40 THEN 'Medium (21-40%)'
        ELSE 'High (41%+)'
    END AS DiscountBand,
    COUNT(*)                     AS LineItems,
    SUM(f.Sales)                 AS TotalSales,
    SUM(f.Profit)                AS TotalProfit,
    SUM(f.Profit) / SUM(f.Sales) AS ProfitMargin
FROM dbo.FactSales AS f
GROUP BY
    CASE
        WHEN f.Discount = 0     THEN 'No Discount'
        WHEN f.Discount <= 0.20 THEN 'Low (1-20%)'
        WHEN f.Discount <= 0.40 THEN 'Medium (21-40%)'
        ELSE 'High (41%+)'
    END
ORDER BY ProfitMargin DESC;
GO


/* ===================== SECTION E - ORDER / SHIPPING ANALYSIS ===================== */

-- Q20. Orders and average shipping days per ship mode (DimDate joined twice)
SELECT
    sm.ShipMode,
    COUNT(DISTINCT f.OrderID)                    AS OrderCount,
    SUM(f.Sales)                                 AS TotalSales,
    AVG(DATEDIFF(DAY, od.FullDate, sd.FullDate)) AS AvgShippingDays
FROM dbo.FactSales AS f
JOIN dbo.DimShipMode AS sm ON f.ShipModeKey  = sm.ShipModeKey
JOIN dbo.DimDate     AS od ON f.OrderDateKey = od.DateKey
JOIN dbo.DimDate     AS sd ON f.ShipDateKey  = sd.DateKey
GROUP BY sm.ShipMode
ORDER BY AvgShippingDays;
GO

-- Q21. Shipping speed classification (CASE statement)
SELECT
    f.OrderID,
    sm.ShipMode,
    DATEDIFF(DAY, od.FullDate, sd.FullDate) AS ShippingDays,
    CASE
        WHEN DATEDIFF(DAY, od.FullDate, sd.FullDate) <= 1 THEN 'Fast'
        WHEN DATEDIFF(DAY, od.FullDate, sd.FullDate) <= 4 THEN 'Average'
        ELSE 'Slow'
    END AS ShippingPerformance
FROM dbo.FactSales AS f
JOIN dbo.DimShipMode AS sm ON f.ShipModeKey  = sm.ShipModeKey
JOIN dbo.DimDate     AS od ON f.OrderDateKey = od.DateKey
JOIN dbo.DimDate     AS sd ON f.ShipDateKey  = sd.DateKey
ORDER BY ShippingDays DESC;
GO

PRINT '21 analytical queries complete.';
GO
