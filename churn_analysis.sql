
-- Customer Churn Analysis
-- SQL Portfolio Project


-- 1. Overall Churn
SELECT COUNT(*) AS total_customers,
SUM(CASE WHEN "Churn Label" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(100.0 * SUM(CASE WHEN "Churn Label"= 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM customer_churn;


-- 2. Churn By Contract
SELECT Contract,
COUNT(*) AS total_customers,
SUM(CASE WHEN "Churn Label" ='Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(100.0 * SUM(CASE WHEN "Churn Label" ='Yes' THEN 1 ELSE 0 END)/ COUNT(*),2) AS churn_rate
FROM customer_churn
GROUP BY Contract
ORDER BY churn_rate DESC;


-- 3. Churn By Tenure
SELECT CASE
WHEN "Tenure Months" BETWEEN 0 AND 12 THEN '0-12 months'
WHEN "Tenure Months" BETWEEN 13 AND 24 THEN '13-24 months'
WHEN "Tenure Months" BETWEEN 25 AND 48 THEN '25-48 months'
WHEN "Tenure Months" BETWEEN 49 AND 72 THEN '49-72 months'
END AS Tenure_Group,
COUNT(*) AS total_customers,
SUM(CASE WHEN "Churn Label"='Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(100.0*SUM(CASE WHEN "Churn Label"='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM customer_churn
GROUP BY Tenure_Group
ORDER BY CASE Tenure_Group
WHEN '0-12 months' THEN 1
WHEN '13-24 months' THEN 2
WHEN '25-48 months' THEN 3
WHEN '49-72 months' THEN 4
END;


-- 4. Churn By Contract+Internet Service 
WITH churn_summary AS(
SELECT Contract,
"Internet Service", 
COUNT(*) AS total_customers,
SUM(CASE WHEN "Churn Label"='Yes' THEN 1 ELSE 0 END) AS churned_customers
FROM customer_churn
GROUP BY Contract, "Internet Service")
SELECT
Contract, 
"Internet Service",
total_customers,
churned_customers,
ROUND(100.0* churned_customers/total_customers,2) AS churn_rate 
FROM churn_summary
ORDER BY churn_rate DESC;


-- 5. Segment By High Risk
WITH segment_summary AS(
SELECT 
Contract,
"Internet Service",
"Payment Method",
COUNT(*) AS total_customers,
SUM(CASE WHEN "Churn Label"='Yes' THEN 1 ELSE 0 END) AS churned_customers
FROM customer_churn
GROUP BY
Contract,
"Internet Service",
"Payment Method"),
segment_rates AS (
SELECT 
Contract,
"Internet Service",
"Payment Method",
total_customers,
churned_customers,
ROUND(100.0*churned_customers/total_customers,2) AS churn_rate
FROM segment_summary
WHERE total_customers >=100)
SELECT
Contract,
"Internet Service",
"Payment Method",
total_customers,
churned_customers,
churn_rate,
RANK() OVER(
ORDER BY churn_rate DESC) AS risk_rank
FROM segment_rates
ORDER BY risk_rank;
