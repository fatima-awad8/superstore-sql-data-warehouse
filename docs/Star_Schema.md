# Star Schema — DEPI_Superstore_DW

## Textual Diagram

```
                         DimCustomer
                              |
                              |
    DimShipMode ------- FactSales ------- DimProduct
                          |      |
                          |      |
                    DimDate   DimGeography
                 (Order Date &
                    Ship Date,
                  role-playing)
```

`FactSales` sits at the center and connects to every dimension through a
surrogate integer foreign key. `DimDate` is used twice — once for
`OrderDateKey` and once for `ShipDateKey` — a standard "role-playing
dimension" pattern, so there is only one calendar table to maintain.

## Mermaid ER Diagram

```mermaid
erDiagram
    DimDate ||--o{ FactSales : "OrderDateKey"
    DimDate ||--o{ FactSales : "ShipDateKey"
    DimCustomer ||--o{ FactSales : "CustomerKey"
    DimProduct ||--o{ FactSales : "ProductKey"
    DimGeography ||--o{ FactSales : "GeographyKey"
    DimShipMode ||--o{ FactSales : "ShipModeKey"

    DimDate {
        int DateKey PK
        date FullDate
        tinyint Day
        tinyint Month
        varchar MonthName
        tinyint Quarter
        smallint Year
        tinyint Weekday
        varchar WeekdayName
    }

    DimCustomer {
        int CustomerKey PK
        nvarchar CustomerID
        nvarchar CustomerName
        nvarchar Segment
    }

    DimProduct {
        int ProductKey PK
        nvarchar ProductID
        nvarchar ProductName
        nvarchar Category
        nvarchar SubCategory
    }

    DimGeography {
        int GeographyKey PK
        nvarchar City
        nvarchar State
        int PostalCode
        nvarchar Region
        nvarchar Country
    }

    DimShipMode {
        int ShipModeKey PK
        nvarchar ShipMode
    }

    FactSales {
        int SalesKey PK
        int RowID
        nvarchar OrderID
        int CustomerKey FK
        int ProductKey FK
        int GeographyKey FK
        int ShipModeKey FK
        int OrderDateKey FK
        int ShipDateKey FK
        decimal Sales
        int Quantity
        decimal Discount
        decimal Profit
    }
```

## Why a Star Schema

- **Query performance**: analytical queries filter/group on small dimension
  tables (e.g. `Category`, `Region`, `Year`) and aggregate measures from one
  large fact table — the optimizer can filter dimensions first and join to
  the fact table using indexed integer keys.
- **Simplicity**: one join "hop" from fact to any dimension, which keeps SQL
  readable and BI-tool-friendly (Power BI, Tableau, Excel PivotTables all
  work naturally against a star schema).
- **Surrogate keys**: `INT` surrogate keys are smaller and faster to join on
  than the original string business keys (`Customer ID`, `Product ID`), and
  they insulate the warehouse from changes to source-system identifiers.
