# Data Dictionary — DEPI_Superstore_DW

Source file: `data/Central_Superstore.xlsx` (sheet `Central_Region`), 2,323 rows, 21 columns.

---

## dbo.DimDate

Calendar dimension. Reused (role-playing) for both `OrderDateKey` and `ShipDateKey` on `FactSales`.

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| DateKey | INT | PK | Derived from Order Date / Ship Date | Surrogate key, format YYYYMMDD |
| FullDate | DATE | Unique | Order Date / Ship Date | The calendar date |
| Day | TINYINT | — | Derived | Day of month (1–31) |
| Month | TINYINT | — | Derived | Month number (1–12) |
| MonthName | VARCHAR(20) | — | Derived | Month name (e.g. "January") |
| Quarter | TINYINT | — | Derived | Calendar quarter (1–4) |
| Year | SMALLINT | — | Derived | Calendar year |
| Weekday | TINYINT | — | Derived | Day of week, 1 = Monday … 7 = Sunday |
| WeekdayName | VARCHAR(20) | — | Derived | Day of week name |

## dbo.DimCustomer

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| CustomerKey | INT | PK | Assigned in ETL | Warehouse surrogate key |
| CustomerID | NVARCHAR(20) | Business Key (Unique) | Customer ID | Original customer identifier |
| CustomerName | NVARCHAR(100) | — | Customer Name | Customer's full name |
| Segment | NVARCHAR(30) | — | Segment | Consumer / Corporate / Home Office |

## dbo.DimProduct

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| ProductKey | INT | PK | Assigned in ETL | Warehouse surrogate key |
| ProductID | NVARCHAR(30) | Business Key (Unique) | Product ID | Original product identifier (SKU) |
| ProductName | NVARCHAR(300) | — | Product Name | Product description. **Note:** 16 Product IDs had two conflicting names in the source; one name per Product ID was kept |
| Category | NVARCHAR(50) | — | Category | Furniture / Office Supplies / Technology |
| SubCategory | NVARCHAR(50) | — | Sub-Category | 17 distinct sub-categories |

## dbo.DimGeography

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| GeographyKey | INT | PK | Assigned in ETL | Warehouse surrogate key |
| City | NVARCHAR(100) | Business Key (composite, Unique with others) | City | City name |
| State | NVARCHAR(100) | Business Key (composite) | State | State name |
| PostalCode | INT | Business Key (composite) | Postal Code | US ZIP code |
| Region | NVARCHAR(50) | Business Key (composite) | Region | Sales region ("Central" for all rows in this file) |
| Country | NVARCHAR(50) | Business Key (composite) | Country | Country ("United States" for all rows) |

## dbo.DimShipMode

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| ShipModeKey | INT | PK | Assigned in ETL | Warehouse surrogate key |
| ShipMode | NVARCHAR(30) | Business Key (Unique) | Ship Mode | Standard Class / Second Class / First Class / Same Day |

## dbo.FactSales

Grain: one row per original order line item (one row per source `Row ID`).

| Column | Type | Key | Source | Description |
|---|---|---|---|---|
| SalesKey | INT | PK | Assigned in ETL | Warehouse surrogate key |
| RowID | INT | Business Key (Unique) | Row ID | Original source row identifier |
| OrderID | NVARCHAR(20) | — | Order ID | Order identifier (shared by multiple line items) |
| CustomerKey | INT | FK → DimCustomer | Derived | Links to the customer |
| ProductKey | INT | FK → DimProduct | Derived | Links to the product |
| GeographyKey | INT | FK → DimGeography | Derived | Links to the ship-to location |
| ShipModeKey | INT | FK → DimShipMode | Derived | Links to the shipping method |
| OrderDateKey | INT | FK → DimDate | Order Date | Date the order was placed |
| ShipDateKey | INT | FK → DimDate | Ship Date | Date the order was shipped |
| Sales | DECIMAL(12,4) | Measure | Sales | Revenue for this line item ($) |
| Quantity | INT | Measure | Quantity | Units sold |
| Discount | DECIMAL(5,2) | Measure | Discount | Discount rate applied (0–1) |
| Profit | DECIMAL(12,4) | Measure | Profit | Profit for this line item ($), can be negative |

---

## Data Cleaning Decisions Applied Before Loading

| # | Issue Found | Rows Affected | Resolution |
|---|---|---|---|
| 1 | Leading/trailing whitespace in string columns | 4 (Product Name) | Trimmed all string columns |
| 2 | 16 Product IDs mapped to two different Product Names | 32 rows | Kept one name per Product ID (the first appearing in the file) |
| 3 | 4 City/State pairs map to more than one Postal Code | — | `DimGeography` grain is City+State+PostalCode+Region+Country, not City/State alone |
| 4 | Missing values | 0 | None found — no imputation needed |
| 5 | Duplicate rows | 0 | None found |
| 6 | Ship Date before Order Date | 0 | Validated, no violations |

No columns were invented. Every attribute in the warehouse traces back to a column in the original Excel file, except surrogate integer keys and the derived calendar attributes in `DimDate`.
