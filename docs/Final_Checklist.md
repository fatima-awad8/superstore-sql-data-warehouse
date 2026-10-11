# Final Requirements Checklist — DEPI Mini-Project 2

| Requirement | Required | Delivered | Location |
|---|---|---|---|
| Normalized Fact & Dimension tables | Yes | Yes (5 dimensions + 1 fact) | `sql/02_create_star_schema.sql` |
| Primary Key / Foreign Key relationships | Yes | Yes | `sql/02_create_star_schema.sql` |
| Star Schema model | Yes | Yes | `docs/Star_Schema.md` |
| Minimum 5 relational tables | 5+ | 6 tables | `sql/02_create_star_schema.sql` |
| At least 15 SQL analytical queries | 15+ | 21 queries | `sql/05_analytical_queries.sql` |
| At least 3 JOIN operations | 3+ | Used in most queries (e.g. Q4, Q6, Q12, Q20) | `sql/05_analytical_queries.sql` |
| At least 2 CTE queries | 2+ | Q7 (YoY growth), Q16 (customer segmentation) | `sql/05_analytical_queries.sql` |
| Subqueries | Yes | Q15 (customers above average), Q18 (products above average) | `sql/05_analytical_queries.sql` |
| CASE statements | Yes | Q9, Q12, Q16, Q19, Q21 | `sql/05_analytical_queries.sql` |
| Window functions (bonus, not required) | Optional | `LAG()` in Q7, `RANK()` in Q10 | `sql/05_analytical_queries.sql` |
| SQL View(s) | 1+ | 2 views | `sql/03_views.sql` |
| Stored Procedure(s) | 1+ | 2 procedures, both parameterized | `sql/04_stored_procedures.sql` |
| KPI Analysis | Yes | 11 KPIs with formulas | `README.md` §11, notebook §9 |
| Profitability reports | Yes | Q8–Q12 | `sql/05_analytical_queries.sql` |
| Customer behavior reports | Yes | Q13–Q16 | `sql/05_analytical_queries.sql` |
| Sales trend reports | Yes | Q1–Q7 | `sql/05_analytical_queries.sql` |
| Performance optimization | Yes | 6 indexes, clustered vs nonclustered explained, STATISTICS IO/TIME, before/after example | `sql/06_indexes_optimization.sql` |
| Data warehouse integrity validation | Yes | Row counts, NULL/orphan FK checks, duplicate key checks, Sales/Profit reconciliation | `sql/07_validation_queries.sql` |
| Python/Jupyter ↔ SQL Server connection | Yes | SQLAlchemy + pyodbc, live `pd.read_sql()` queries | `notebooks/Mini_Project_2_ETL_Analysis.ipynb` §5–§7 |
| ETL pipeline (extract, clean, transform, load) | Yes | Yes | `notebooks/Mini_Project_2_ETL_Analysis.ipynb` §2–§6 |
| Visualizations (3–5 charts) | 3–5 | 5 charts | `outputs/charts/`, notebook §8 |
| README documentation | Yes | Yes | `README.md` |
| Data Dictionary | Yes | Yes | `docs/Data_Dictionary.md` |
| Project Report | Yes | Yes | `docs/Project_Report.md` |
| requirements.txt | Yes | Yes | `requirements.txt` |
| Submission-ready folder structure | Yes | Yes | (this project folder) |

**Result: every official DEPI requirement is satisfied.**
