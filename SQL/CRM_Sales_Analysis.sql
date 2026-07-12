/*===========================================================
Project  : CRM Sales Analytics using SQL Server
Author   : Dinky Vadera
Tools    : SQL Server Management Studio (SSMS)

Objective:
Analyze CRM sales data to evaluate lead generation,
sales pipeline, customer accounts, and salesperson
performance through SQL-based business analysis.

Dataset:
- Lead
- Opportunity
- Account
- Users

Skills Demonstrated:
✔ SQL Joins
✔ Aggregate Functions
✔ Window Functions
✔ Business KPI Analysis
✔ Sales Analytics
✔ CRM Analytics
✔ Data Quality Analysis
===========================================================*/

CREATE DATABASE crm_sales;
USE crm_sales;

SELECT Top 5 * FROM lead
SELECT Top 5 * FROM account
SELECT Top 5 * FROM opportunity
SELECT Top 5 * FROM users

-- Lead Analysis
-- How many leads are there?
SELECT COUNT(*) AS Total_Leads FROM Lead;

-- Which Lead Source generates the most leads?
SELECT lead_source, COUNT(*) AS Total_Leads
FROM lead
GROUP BY lead_source
ORDER BY Total_Leads DESC;

-- How many leads are converted?
SELECT is_converted, COUNT(*) As Total_Leads
FROM lead
GROUP BY is_converted;

-- What is the Lead Conversion Rate?
SELECT
    COUNT(*) AS Total_Leads,
    COUNT(CASE WHEN is_converted = 1 THEN 1 END) AS Leads_Converted,
    ROUND(
    COUNT(CASE WHEN is_converted = 1 THEN 1 END) * 100.0 /
    COUNT(*),2) AS Conversion_Rate
FROM lead;

-- Lead Status Distribution
SELECT status, COUNT(*) AS Total
FROM lead
GROUP BY status
ORDER BY Total DESC;

-- Which Sales Representative owns the most leads?
SELECT u.name AS Sales_Representative, 
       COUNT(l.id) AS Total_Leads
FROM lead l 
JOIN users u on l.owner_id= u.id
GROUP BY u.name
ORDER BY Total_Leads DESC;

-- Opportunity Analysis
-- How many sales opportunities are currently in the CRM?
SELECT COUNT(*) AS Total_Opportunities
FROM opportunity;

-- What is the total potential revenue currently in the sales pipeline?
SELECT SUM(amount) AS Total_Pipeline_Revenue
FROM opportunity;

-- What is the average value of each opportunity?
SELECT AVG(amount) AS Average_Deal_Size
FROM opportunity;

-- Which stage contains the highest revenue?
SELECT stage_name, COUNT(*) AS Opportunities,
       SUM(amount) AS Pipeline_Value
FROM opportunity
GROUP BY stage_name
ORDER BY Pipeline_Value DESC;

-- What is the average probability of closing deals at each stage?
SELECT stage_name, COUNT(*) AS Opportunities,
       AVG(Probability) AS Average_Probability
FROM opportunity
GROUP BY stage_name
ORDER BY Average_Probability DESC;

-- Lead Source Performance
SELECT lead_source, COUNT(*) AS Opportunities,
       SUM(amount) AS Pipeline_Value,
       AVG(amount) AS Average_Deal_Size
FROM opportunity
GROUP BY lead_source
ORDER BY Pipeline_Value DESC, Average_Deal_Size DESC;

-- Monthly Pipeline Trend
SELECT YEAR(close_date) AS Year,
       MONTH(close_date) AS MONTH,
       COUNT(*) AS Opportunities,
       SUM(amount) AS Total_Pipeline
FROM opportunity
GROUP BY YEAR(close_date), MONTH(close_date)
ORDER BY Year, Month;

-- Running Pipeline
SELECT close_date,
       SUM(amount) AS Daily_Pipeline,
       SUM(SUM(amount)) OVER (ORDER BY close_date) AS Running_Pipeline
FROM opportunity
GROUP BY close_date
ORDER BY close_date;

-- Revenue Forecast based on Probability
SELECT SUM(amount * probability / 100.0) AS Forecasted_Revenue
FROM opportunity;

-- User perfomance analysis
-- Total Users
SELECT COUNT(*) AS Total_Sales_Representatives
FROM users;

-- Which salesperson owns the highest revenue pipeline?
SELECT u.name AS Sales_Representative,
       COUNT(o.id) AS Total_Opportunities,
       SUM(o.amount) AS Pipeline_Value
FROM opportunity o
INNER JOIN users u ON o.owner_id= u.id
GROUP BY u.name
ORDER BY Pipeline_Value DESC;

-- How many leads has each salesperson been assigned?
SELECT u.name AS Sales_Representative,
       COUNT(l.id) AS Total_Leads
FROM lead l
INNER JOIN users u ON l.owner_id= u.id
GROUP BY u.name
ORDER BY Total_Leads DESC;

-- Lead Conversion by Salesperson
SELECT u.name AS Sales_Representative,
       COUNT(l.id) AS Total_Leads,
       SUM(CAST(is_converted AS INT)) AS Leads_Converted,
       ROUND(
       SUM(CAST(is_converted AS INT)) * 100.0 /
       COUNT(l.id),2) AS Conversion_Rate
FROM lead l
INNER JOIN users u ON l.owner_id= u.id
GROUP BY u.name
ORDER BY Conversion_Rate DESC;

-- Pipeline by Department
SELECT u.department AS Department,
       COUNT(o.id) AS Total_Opportunities,
       SUM(o.amount) AS Pipeline_Value
FROM opportunity o
INNER JOIN users u ON o.owner_id= u.id
GROUP BY u.department
ORDER BY Pipeline_Value DESC;

-- Revenue by Job Title
SELECT u.title AS Job_Title,
       SUM(o.amount) AS Revenue
FROM opportunity o
INNER JOIN users u ON o.owner_id= u.id
GROUP BY u.title
ORDER BY Revenue DESC;

-- Top 5 Sales Representatives by Revenue
SELECT Top 5 
       u.name,
       SUM(o.amount) AS Revenue
FROM opportunity o
JOIN users u on o.owner_id= u.id
GROUP BY u.name
ORDER BY Revenue DESC;

-- Sales Ranking by Revenue
SELECT u.name,
       SUM(o.amount) AS Revenue,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS Revenue_Rank
FROM opportunity o
JOIN users u ON o.owner_id = u.id
GROUP BY u.name;

-- Accounts Analysis
-- Total Accounts
SELECT COUNT(*) AS Total_Accounts
FROM account;

-- Which customers contribute the highest revenue?
SELECT a.name AS Account_Name,
       COUNT(o.id) AS Opportunities,
       SUM(o.amount) AS Total_Revenue
FROM opportunity o
INNER JOIN account a ON o.account_id= a.id
GROUP BY a.name
ORDER BY Total_Revenue DESC;

-- Opportunity Details by Salesperson and Customer Account
SELECT u.name AS Sales_Representative,
       a.name AS Account_Name,
       o.amount,
       o.stage_name
FROM opportunity o
JOIN account a on o.account_id= a.id
JOIN users u on o.owner_id= u.id;

-- Data Quality in the CRM
-- Missing email
SELECT COUNT(*) AS Missing_Email
FROM lead WHERE email IS NULL;

-- Duplicate Companies
SELECT company,COUNT(*) AS  Duplicate
FROM lead
GROUP BY company HAVING COUNT(*)>1;
