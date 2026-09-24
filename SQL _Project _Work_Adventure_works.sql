select count(*) from factinternetsales;
select count(*) from fact_internet_sales_new;

USE adventure_project;

SELECT COUNT(*) AS Total_Rows 
FROM Fact_Internet_Sales_New;

# Question 0 :- Data Integration & Schema Consolidation

CREATE TABLE Fact_Sales_Combined AS
SELECT * FROM FactInternetSales
UNION ALL
SELECT * FROM Fact_Internet_Sales_New;

SELECT COUNT(*) AS Combined_Total_Rows FROM Fact_Sales_Combined;

# QUESTION 1 :- Data Model Relationship Mapping

USE adventure_project;

SELECT 
    s.*, 
    p.EnglishProductName AS ProductName
FROM fact_sales_combined s
LEFT JOIN dimproduct p 
    ON s.ProductKey = p.ProductKey
LIMIT 10;

#QUESTION 2 :- Product Catalog Lookup & Attribute Enrichment

USE adventure_project;

SELECT 
    s.*, 
    CONCAT_WS(' ', c.FirstName, c.LastName) AS Customerfullname,
    COALESCE(p.ListPrice, s.UnitPrice) AS UnitPrice
FROM fact_sales_combined s            
LEFT JOIN dimcustomer c             
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct p                
    ON s.ProductKey = p.ProductKey
LIMIT 10;

# Question 3 :- Data Integration & Schema Consolidation

use adventure_project; 

 select orderdatekey, orderdate from fact_sales_combined limit 10;
 describe fact_sales_combined;
-- Calculate the following fields from the OrderDateKey field (First Create a Date Field from OrderDateKey)
-- A. Year
-- B. Monthno
-- C. Monthfullname
-- D. Quarter (Q1,Q2,Q3,Q4)
-- E. YearMonth (YYYY-MMM)
-- F. Weekdayno
-- G. Weekdayname
-- H. FinancialMonth
-- I. Financial Quarter
SET SQL_SAFE_UPDATES = 0;

UPDATE Fact_Sales_Combined
SET OrderDate_Temp = STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d');

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE Fact_Sales_Combined
ADD COLUMN OrderDate_Temp DATE;

UPDATE Fact_Sales_Combined
SET OrderDate_Temp = STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d');
set sql_safe_updates=0;
UPDATE Fact_Sales_Combined
SET OrderDate_Temp = STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d');
set sql_safe_updates=1;
SELECT OrderDateKey, OrderDate_Temp
FROM Fact_Sales_Combined
LIMIT 10;

USE adventure_project;

ALTER TABLE Fact_Sales_Combined 
RENAME COLUMN `ï»¿ProductKey` TO ProductKey;

SET SQL_SAFE_UPDATES = 0;

UPDATE Fact_Sales_Combined
SET 
    Year             = YEAR(OrderDate_Temp),
    MonthNo          = MONTH(OrderDate_Temp),
    MonthFullName    = MONTHNAME(OrderDate_Temp),
    Quarter          = CONCAT('Q', QUARTER(OrderDate_Temp)),
    YearMonth        = DATE_FORMAT(OrderDate_Temp, '%Y-%b'),
    WeekdayNo        = DAYOFWEEK(OrderDate_Temp),
    WeekdayName      = DAYNAME(OrderDate_Temp),
    FinancialMonth   = CASE 
                         WHEN MONTH(OrderDate_Temp) >= 7 THEN MONTH(OrderDate_Temp) - 6
                         ELSE MONTH(OrderDate_Temp) + 6
                       END,
    FinancialQuarter = CASE 
                         WHEN MONTH(OrderDate_Temp) BETWEEN 7 AND 9 THEN 'Q1'
                         WHEN MONTH(OrderDate_Temp) BETWEEN 10 AND 12 THEN 'Q2'
                         WHEN MONTH(OrderDate_Temp) BETWEEN 1 AND 3 THEN 'Q3'
                         ELSE 'Q4'
                       END;

SET SQL_SAFE_UPDATES = 1;

SELECT 
    OrderDateKey, 
    OrderDate_Temp,
    Year, 
    MonthNo, 
    MonthFullName, 
    Quarter, 
    YearMonth,
    WeekdayNo,
    WeekdayName,
    FinancialMonth,
    FinancialQuarter
FROM Fact_Sales_Combined
LIMIT 10;

SET SQL_SAFE_UPDATES = 0;

UPDATE Fact_Sales_Combined
SET
    WeekdayNo = WEEKDAY(OrderDate_Temp) + 1,
    FinancialMonth = CASE
        WHEN MONTH(OrderDate_Temp) >= 7 THEN MONTH(OrderDate_Temp) - 6
        ELSE MONTH(OrderDate_Temp) + 6
    END,
    FinancialQuarter = CASE
        WHEN MONTH(OrderDate_Temp) BETWEEN 7 AND 9 THEN 'Q1'
        WHEN MONTH(OrderDate_Temp) BETWEEN 10 AND 12 THEN 'Q2'
        WHEN MONTH(OrderDate_Temp) BETWEEN 1 AND 3 THEN 'Q3'
        WHEN MONTH(OrderDate_Temp) BETWEEN 4 AND 6 THEN 'Q4'
    END;

SET SQL_SAFE_UPDATES = 1;
    
    SELECT
    OrderDateKey,
    OrderDate_Temp,
    Year,
    MonthNo,
    MonthFullName,
    Quarter,
    YearMonth,
    WeekdayNo,
    WeekdayName,
    FinancialMonth,
    FinancialQuarter
FROM Fact_Sales_Combined
LIMIT 10;

SELECT OrderDateKey, OrderDate_Temp, MonthFullName, FinancialMonth, FinancialQuarter
FROM Fact_Sales_Combined
LIMIT 5;

#Question 4 :- Revenue Engineering & Financial Variance Audit

select 
salesordernumber,
salesorderlinenumber,
unitprice,
orderquantity,
unitpricediscountpct,
(unitprice * orderquantity) * (1-ifnull(unitpricediscountpct, 0)) as calculated_sales_amount,
salesamount as original_sales_amount
from fact_sales_combined;

#adding perminant column calculated_sales_amount in the fact_sales_combined

SHOW COLUMNS FROM Fact_Sales_Combined LIKE 'Calculated_Sales_Amount';
SELECT Calculated_Sales_Amount 
FROM Fact_Sales_Combined 
LIMIT 10;

ALTER TABLE Fact_Sales_Combined 
DROP COLUMN Calculated_Sales_Amount;

ALTER TABLE Fact_Sales_Combined 
ADD COLUMN Calculated_Sales_Amount DECIMAL(18, 4);

SET SQL_SAFE_UPDATES = 0;

UPDATE Fact_Sales_Combined
SET Calculated_Sales_Amount = (OrderQuantity * UnitPrice) - COALESCE(DiscountAmount, 0);

SET SQL_SAFE_UPDATES = 1;

SELECT 
    SalesOrderNumber, 
    UnitPrice, 
    OrderQuantity, 
    DiscountAmount, 
    Calculated_Sales_Amount 
FROM Fact_Sales_Combined 
LIMIT 10;

#Question 5 :- Cost of Goods Sold (COGS) Modeling

SELECT 
    SalesOrderNumber, 
    UnitPrice, 
    OrderQuantity, 
    DiscountAmount, 
    Calculated_Sales_Amount ,
round((ProductStandardCost*OrderQuantity),2) as "ProductionCost" 
FROM Fact_Sales_Combined 
LIMIT 10;

#adding perminant column ProductionCost in the fact_sales_combined

ALTER TABLE Fact_Sales_Combined
ADD COLUMN ProductionCost DECIMAL(18, 4);

SET SQL_SAFE_UPDATES = 0;

UPDATE Fact_Sales_Combined
SET ProductionCost  = round((ProductStandardCost*OrderQuantity),2);

SET SQL_SAFE_UPDATES = 1;

SELECT 
    SalesOrderNumber, 
    UnitPrice, 
    OrderQuantity, 
    DiscountAmount, 
    Calculated_Sales_Amount ,
ProductionCost 
FROM Fact_Sales_Combined 
LIMIT 10;


#QUESTION 6 :- Bottom-Line Profitability & Margin Realization

SELECT 
    CONCAT(ROUND(SUM(SalesAmount) / 100000, 2), ' Lakhs') AS Total_Revenue,
    CONCAT(ROUND(SUM(TotalProductCost) / 100000, 2), ' Lakhs') AS Total_Cost,
    CONCAT(ROUND((SUM(SalesAmount) - SUM(TotalProductCost)) / 100000, 2), ' Lakhs') AS Total_Profit
FROM fact_sales_combined;

