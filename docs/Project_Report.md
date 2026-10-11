# Project Report — Advanced SQL Data Warehouse & Business Analytics

## 1. Introduction

This report documents the design and implementation of a SQL Server data
warehouse built from the Central Region extract of the Superstore dataset,
as part of DEPI Mini-Project 2. The project covers the full pipeline: data
inspection and cleaning, dimensional modeling, database creation, ETL,
analytical SQL querying, KPI reporting, and performance optimization.

## 2. Business Problem

The organization's Superstore sales data existed only as a flat operational
export (Excel), which is not well suited to analytical reporting: it mixes
transactional, customer, product, and geographic details in a single wide
table, has no enforced integrity constraints, and cannot be efficiently
queried or joined for BI purposes. The goal was to re-model this data as a
relational data warehouse that executives and analysts can query directly
for sales, profitability, and customer-behavior insights.

## 3. Dataset Overview

- Source: `Central_Superstore.xlsx`, sheet `Central_Region`
- 2,323 rows × 21 columns, one row per order line item
- Covers orders placed between January 2013 and December 2016 (ship dates
  through early January 2017)
- All rows belong to the "Central" region of the United States
- 629 unique customers, 1,310 unique products, 1,175 unique orders, 195
  unique city/state/postal-code combinations, 4 shipping modes

## 4. Data Cleaning

Inspection with pandas found the dataset to be largely clean: no missing
values and no fully duplicated rows. Two real issues were found and
resolved:

1. **16 Product IDs had two different Product Name values** in the source
   file (the same product code reused for a different item on different
   order lines). This was resolved by keeping one name per Product ID (the
   first one appearing in the file), so `DimProduct` has exactly one row per
   product.
2. **4 Product Name values had leading/trailing whitespace**, fixed by
   trimming all string columns.

Two structural checks were also run and passed without needing any fix:
`Row ID` is unique (used as the fact-table grain/business key), and
`Ship Date` is never earlier than `Order Date` for any row.

No columns were invented at any point; every warehouse column maps directly
back to a source column, aside from surrogate integer keys and derived
calendar attributes.

## 5. Data Warehouse Design

A Star Schema was chosen: one central fact table (`FactSales`) holding the
numeric measures (Sales, Quantity, Discount, Profit) plus foreign keys, and
five dimension tables holding descriptive attributes (`DimDate`,
`DimCustomer`, `DimProduct`, `DimGeography`, `DimShipMode`). `DimDate` is
used twice through two separate foreign keys (`OrderDateKey`, `ShipDateKey`)
— a standard "role-playing dimension" technique that avoids maintaining two
near-identical calendar tables. Full details are in
[`Star_Schema.md`](Star_Schema.md) and [`Data_Dictionary.md`](Data_Dictionary.md).

`DimGeography`'s grain is the full combination of City + State + PostalCode
+ Region + Country, rather than just City + State, because 4 City/State
pairs in the source data map to more than one Postal Code — using City/State
alone would have silently collapsed real distinct locations together.

## 6. ETL Implementation

The ETL pipeline (`notebooks/Mini_Project_2_ETL_Analysis.ipynb`) is written
entirely in pandas and executed from Jupyter/Anaconda. It:

1. Loads the raw Excel file and profiles it (shape, dtypes, nulls, duplicates)
2. Applies the cleaning steps above, with assertions that fail loudly if a
   data-quality assumption is violated
3. Builds one DataFrame per dimension using `drop_duplicates()` and an
   assigned integer surrogate key column
4. Builds `FactSales` by merging the cleaned line-item data against each
   dimension's business key to attach the correct surrogate key
5. Validates that `SUM(Sales)` and `SUM(Profit)` in the constructed fact
   table exactly match the totals in the original cleaned data before
   anything is loaded to SQL Server
6. Connects to SQL Server via SQLAlchemy + pyodbc and loads all six
   DataFrames with `to_sql(..., if_exists='append')`, dimensions before the
   fact table so foreign key constraints are satisfied
7. Re-queries SQL Server with `pd.read_sql()` for every subsequent analysis
   step and chart, demonstrating a genuine Python ↔ SQL Server round trip

## 7. SQL Implementation

`sql/01_create_database.sql` creates the `DEPI_Superstore_DW` database.
`sql/02_create_star_schema.sql` creates the 5 dimension tables and the fact
table with primary keys (`INT` surrogate keys assigned by the ETL, clustered), unique
constraints on business keys, foreign keys from `FactSales` to every
dimension, and check constraints on `Discount`, `Quantity`, `Month`,
`Quarter`, and `Weekday`.

## 8. Advanced Querying

`sql/05_analytical_queries.sql` contains 21 business questions, each with a
numbered comment stating the business question and a short explanation of
what the result means. They are grouped into Sales Analysis, Profitability,
Customer Behavior, Product Analysis, and Order/Shipping Analysis, and
collectively demonstrate: 3+ multi-table JOINs, 2+ CTEs (YoY growth via
`LAG()`, and CASE-based customer segmentation), scalar and correlated
subqueries (customers and products above average), CASE-based
classification (loss-making labels, discount bands, shipping speed), and two
window functions (`LAG` for year-over-year growth, `RANK` for ranking
products by profit).

## 9. KPI Analysis

Eleven executive KPIs (Total Sales, Total Profit, Profit Margin %, Total
Orders, Total Customers, Total Quantity Sold, Average Order Value, Average
Sales per Customer, Average Profit per Order, YoY Sales Growth, YoY Profit
Growth) are defined with exact formulas in the README and computed both in
SQL (`usp_GetSalesByYear`, ad-hoc queries) and in the notebook's final KPI
query against SQL Server.

## 10. Views

Two views were created (only one was required):
`vw_SalesSummary` (all dimensions pre-joined to the fact table at order-line
grain) and `vw_CustomerPerformance` (per-customer KPI roll-up with total
sales, profit, order count and average order value).

## 11. Stored Procedures

Two parameterized stored procedures were created (only one was required):
`usp_GetSalesByYear(@Year INT)` returns category-level sales/profit KPIs for
a given year, and `usp_GetRegionPerformance(@Region NVARCHAR(50))` returns
state-level performance for a given region. Both use joins and aggregation to return
reporting data for the value passed in.

## 12. Optimization

Nonclustered indexes were added on every `FactSales` foreign key column and
on `DimDate(Year)`, since almost all analytical queries either join on those
foreign keys or filter/group by year. The script also explains the difference
between clustered and nonclustered indexes.
`sql/06_indexes_optimization.sql` also includes a `SET STATISTICS IO/TIME
ON` demonstration and a worked example contrasting a non-sargable
`WHERE YEAR(FullDate) = 2016` predicate against filtering directly on the
indexed, pre-computed `Year` column. The report explains why integer
surrogate keys and the star-schema shape are more join-efficient than the
original wide, string-keyed flat table.

## 13. Python Integration

Beyond the ETL load, the notebook queries SQL Server directly with
`pd.read_sql()` for every downstream analysis: monthly sales trend, sales
and profit by category, top 10 customers, and a sales-vs-profit line-item
extract, each of which feeds directly into one of the five saved charts. A
final KPI query recomputes the full executive KPI set from SQL Server for a
last sanity check.

## 14. Results

- `DEPI_Superstore_DW` contains 6 tables (5 dimensions + 1 fact), 2 views,
  and 2 stored procedures, all enforced with primary/foreign key and check
  constraints.
- Data validation (`sql/07_validation_queries.sql`) confirms zero NULL or
  orphaned foreign keys, zero duplicate business keys, and that
  `SUM(Sales)` and `SUM(Profit)` in `FactSales` reconcile exactly to the
  original Excel totals ($501,239.89 and $39,706.36 respectively).
- 21 analytical SQL queries and 5 charts were produced covering every
  required business area.

## 15. Key Findings

- **Technology drives profit**, Office Supplies is modestly profitable, and
  **Furniture is a net loss category** overall, driven mainly by the
  Furnishings and Tables sub-categories.
- **Heavy discounting (40%+) is strongly associated with losses** — that
  discount band alone accounts for roughly –$40,793 in total profit, far
  more than any single category or sub-category.
- **Texas generates the most revenue but is the single most unprofitable
  state**, which — combined with the discount finding — suggests
  region-specific discounting practices are eroding margin there.
- Sales show a clear multi-year growth trend (2013 → 2016), with the
  largest jump between 2014 and 2015.
- Shipping performance is consistent with the chosen Ship Mode: Same Day is
  effectively instantaneous, while Standard Class (the most common choice)
  averages about 5 days.

## 16. Challenges

- Resolving the 16 conflicting Product ID → Product Name mappings required
  choosing a single consistent rule that could be applied automatically,
  rather than deciding product by product, so the ETL stays re-runnable.
- Choosing the correct grain for `DimGeography` required checking for
  hidden many-to-one relationships (City/State → multiple Postal Codes)
  before finalizing the dimension's natural key.
- Balancing "don't invent columns" against the need for a usable calendar
  dimension was resolved by deriving `DimDate` attributes purely
  mechanically from the two existing date columns.

## 17. Conclusion

The project successfully converts a flat, unconstrained Excel export into a
fully modeled, constraint-enforced, indexed SQL Server data warehouse with a
reproducible Python ETL pipeline, a rich analytical SQL layer (queries,
views, stored procedures), and validated data integrity — while surfacing
concrete, actionable business findings (discount-driven losses in Furniture
and in Texas) directly from the actual dataset.
