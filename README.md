# SQL-Project
# 🚲 Adventure Works Sales Analytics: SQL Project (MySQL)

A MySQL project that prepares and analyzes Adventure Works sales data. It merges two sales tables, enriches them with product and customer details, engineers date, revenue and cost fields, and calculates total revenue, cost and profit.

---

## 🎯 Business Problem

Adventure Works sales are split across two fact tables, with no ready-made date fields, no cost of goods sold and no profit figures. Before any dashboard can be built, the data has to be combined, cleaned and enriched.

## ✅ Goal of the Project

- Combine both sales tables into a single fact table
- Link sales to product and customer details
- Build date fields (year, month, quarter, weekday, financial period) from the `OrderDateKey`
- Calculate sales amount, production cost (COGS) and profit

---

## 🛠️ Tech Stack

- 🗄️ **MySQL** (MySQL Workbench)
- **Joins**: `LEFT JOIN` across fact and dimension tables
- **Set operations**: `UNION ALL`
- **Functions**: `STR_TO_DATE`, `DATE_FORMAT`, `MONTHNAME`, `DAYNAME`, `QUARTER`, `CONCAT_WS`, `COALESCE`, `IFNULL`, `ROUND`
- **Conditional logic**: `CASE WHEN`
- **DDL / DML**: `CREATE TABLE AS`, `ALTER TABLE`, `UPDATE`

## 🗂️ Database: `adventure_project`

| Table | Type | Description |
|---|---|---|
| `FactInternetSales` | Fact | Original sales orders |
| `Fact_Internet_Sales_New` | Fact | Additional sales orders |
| `Fact_Sales_Combined` | Fact | Both tables merged (created in Question 0) |
| `DimProduct` | Dimension | Product names, list price, costs |
| `DimCustomer` | Dimension | Customer names and details |

---

## 🧩 Question-by-Question Walkthrough

| # | Task | Approach |
|---|---|---|
| **0** | Data integration and schema consolidation | `CREATE TABLE ... AS SELECT ... UNION ALL` to merge both fact tables, then a row count check |
| **1** | Data model relationship mapping | `LEFT JOIN` sales to `DimProduct` on `ProductKey` to show product names |
| **2** | Product lookup and attribute enrichment | Join `DimCustomer` and `DimProduct`, build customer full name with `CONCAT_WS`, and use `COALESCE` for unit price |
| **3** | Date engineering | Convert `OrderDateKey` to a `DATE`, then derive Year, Month No, Month Name, Quarter, Year-Month, Weekday No, Weekday Name, Financial Month and Financial Quarter |
| **4** | Revenue engineering and variance audit | Recalculate sales amount, compare with the original `SalesAmount`, and add a permanent `Calculated_Sales_Amount` column |
| **5** | Cost of goods sold (COGS) | Production cost = `ProductStandardCost × OrderQuantity`, stored as a permanent `ProductionCost` column |
| **6** | Profitability and margin | Total revenue, total cost and total profit, shown in Lakhs |

### Sample Queries

**Merge the two sales tables**
```sql
CREATE TABLE Fact_Sales_Combined AS
SELECT * FROM FactInternetSales
UNION ALL
SELECT * FROM Fact_Internet_Sales_New;
```

**Convert the date key and derive date fields**
```sql
UPDATE Fact_Sales_Combined
SET OrderDate_Temp = STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d');

UPDATE Fact_Sales_Combined
SET Year          = YEAR(OrderDate_Temp),
    MonthFullName = MONTHNAME(OrderDate_Temp),
    Quarter       = CONCAT('Q', QUARTER(OrderDate_Temp)),
    YearMonth     = DATE_FORMAT(OrderDate_Temp, '%Y-%b');
```

**Revenue, cost and profit**
```sql
SELECT
  CONCAT(ROUND(SUM(SalesAmount) / 100000, 2), ' Lakhs')      AS Total_Revenue,
  CONCAT(ROUND(SUM(TotalProductCost) / 100000, 2), ' Lakhs') AS Total_Cost,
  CONCAT(ROUND((SUM(SalesAmount) - SUM(TotalProductCost)) / 100000, 2), ' Lakhs') AS Total_Profit
FROM fact_sales_combined;
```

---

## 💡 Key Results

The same dataset analyzed in the Excel, Power BI and Tableau projects gives:

- **Total revenue:** about $29.36M (roughly 2,936 Lakhs if shown in your currency units)
- **Total cost:** about $17.28M
- **Total profit:** about $12.08M, a **41.1% margin**

> Replace these with the exact values your Question 6 query returns.

## 📁 Repository Files

- `SQL_Project_Work_Adventure_works.sql`: all queries for Questions 0 to 6

## 🧠 Skills Demonstrated

Data integration (`UNION ALL`) • Joins • Date engineering • Calculated columns • COGS and profit modeling • Data validation
