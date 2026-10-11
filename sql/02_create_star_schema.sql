-- 02_create_star_schema.sql
-- Creates the star schema: 5 dimension tables + 1 fact table
 
USE DEPI_Superstore_DW;
GO
 
IF OBJECT_ID('dbo.FactSales', 'U') IS NOT NULL DROP TABLE dbo.FactSales;
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL DROP TABLE dbo.DimDate;
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NOT NULL DROP TABLE dbo.DimCustomer;
IF OBJECT_ID('dbo.DimProduct', 'U') IS NOT NULL DROP TABLE dbo.DimProduct;
IF OBJECT_ID('dbo.DimGeography', 'U') IS NOT NULL DROP TABLE dbo.DimGeography;
IF OBJECT_ID('dbo.DimShipMode', 'U') IS NOT NULL DROP TABLE dbo.DimShipMode;
GO
 
-- Dimension: Date
CREATE TABLE dbo.DimDate (
    DateKey      INT          NOT NULL,
    FullDate     DATE         NOT NULL,
    [Day]        TINYINT      NOT NULL,
    [Month]      TINYINT      NOT NULL,
    MonthName    VARCHAR(20)  NOT NULL,
    Quarter      TINYINT      NOT NULL,
    [Year]       SMALLINT     NOT NULL,
    Weekday      TINYINT      NOT NULL,
    WeekdayName  VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_DimDate PRIMARY KEY (DateKey),
    CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
);
GO
 
-- Dimension: Customer
CREATE TABLE dbo.DimCustomer (
    CustomerKey   INT NOT NULL,
    CustomerID    NVARCHAR(20)  NOT NULL,
    CustomerName  NVARCHAR(100) NOT NULL,
    Segment       NVARCHAR(30)  NOT NULL,
    CONSTRAINT PK_DimCustomer PRIMARY KEY (CustomerKey),
    CONSTRAINT UQ_DimCustomer_CustomerID UNIQUE (CustomerID)
);
GO
 
-- Dimension: Product
CREATE TABLE dbo.DimProduct (
    ProductKey    INT NOT NULL,
    ProductID     NVARCHAR(30)   NOT NULL,
    ProductName   NVARCHAR(300)  NOT NULL,
    Category      NVARCHAR(50)   NOT NULL,
    SubCategory   NVARCHAR(50)   NOT NULL,
    CONSTRAINT PK_DimProduct PRIMARY KEY (ProductKey),
    CONSTRAINT UQ_DimProduct_ProductID UNIQUE (ProductID)
);
GO
 
-- Dimension: Geography
CREATE TABLE dbo.DimGeography (
    GeographyKey  INT NOT NULL,
    City          NVARCHAR(100) NOT NULL,
    State         NVARCHAR(100) NOT NULL,
    PostalCode    INT           NOT NULL,
    Region        NVARCHAR(50)  NOT NULL,
    Country       NVARCHAR(50)  NOT NULL,
    CONSTRAINT PK_DimGeography PRIMARY KEY (GeographyKey)
);
GO
 
-- Dimension: Ship Mode
CREATE TABLE dbo.DimShipMode (
    ShipModeKey   INT NOT NULL,
    ShipMode      NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_DimShipMode PRIMARY KEY (ShipModeKey),
    CONSTRAINT UQ_DimShipMode_ShipMode UNIQUE (ShipMode)
);
GO
 
-- Fact table: one row per order line item
CREATE TABLE dbo.FactSales (
    SalesKey       INT NOT NULL,
    RowID          INT             NOT NULL,
    OrderID        NVARCHAR(20)    NOT NULL,
    CustomerKey    INT             NOT NULL,
    ProductKey     INT             NOT NULL,
    GeographyKey   INT             NOT NULL,
    ShipModeKey    INT             NOT NULL,
    OrderDateKey   INT             NOT NULL,
    ShipDateKey    INT             NOT NULL,
    Sales          DECIMAL(12,4)   NOT NULL,
    Quantity       INT             NOT NULL,
    Discount       DECIMAL(5,2)    NOT NULL,
    Profit         DECIMAL(12,4)   NOT NULL,
    CONSTRAINT PK_FactSales PRIMARY KEY (SalesKey),
    CONSTRAINT FK_FactSales_Customer  FOREIGN KEY (CustomerKey)  REFERENCES dbo.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_Product   FOREIGN KEY (ProductKey)   REFERENCES dbo.DimProduct(ProductKey),
    CONSTRAINT FK_FactSales_Geography FOREIGN KEY (GeographyKey) REFERENCES dbo.DimGeography(GeographyKey),
    CONSTRAINT FK_FactSales_ShipMode  FOREIGN KEY (ShipModeKey)  REFERENCES dbo.DimShipMode(ShipModeKey),
    CONSTRAINT FK_FactSales_OrderDate FOREIGN KEY (OrderDateKey) REFERENCES dbo.DimDate(DateKey),
    CONSTRAINT FK_FactSales_ShipDate  FOREIGN KEY (ShipDateKey)  REFERENCES dbo.DimDate(DateKey)
);
GO
 
PRINT 'Star schema (5 dimension tables + 1 fact table) created successfully.';
GO
 