--------------------------------------
-- DATA PREPARATION AND UNDERSTANDING
--------------------------------------

-- Q1: What is the total number of rows in each of the 3 tables in the database?
SELECT 'Customer' AS Table_Name, COUNT(*) AS Record_Count FROM Customer
UNION ALL
SELECT 'Product Category', COUNT(*) FROM prod_cat_info
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions;


-- Q2: What is the total number of transactions that have a return?
SELECT COUNT(*) AS Count_Returns FROM Transactions WHERE QTY < 0;


-- Q3: The dates provided across the datasets are not in a correct format. 
-- Convert the date variables into valid date formats.
-- (Handled during data import process)


-- Q4: What is the time range of the transaction data available for analysis? Show the output in 
-- number of days, months and years simultaneously in different columns.
SELECT 
    DATEDIFF(DAY, MIN(tran_date), MAX(tran_date)) AS Days_Range,
    DATEDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS Months_Range,
    DATEDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS Years_Range
FROM Transactions;

-- Q5: Which product category does the sub-category “DIY” belong to?
SELECT prod_cat, prod_subcat FROM prod_cat_info WHERE prod_subcat = 'DIY';

--------------------------------------
-- DATA ANALYSIS
--------------------------------------

-- Q1: Which channel is most frequently used for transactions?
SELECT TOP 1 Store_Type, COUNT(*) AS Usage_Count
FROM Transactions
GROUP BY Store_Type
ORDER BY Usage_Count DESC;


-- Q2: What is the count of Male and Female customers in the database?
SELECT GENDER, COUNT(customer_Id) AS Count_Gender FROM Customer GROUP BY GENDER;


-- Q3: From which city do we have the maximum number of customers and how many?
SELECT TOP 1 city_code, COUNT(customer_Id) AS Count_Customers
FROM Customer
GROUP BY city_code
ORDER BY Count_Customers DESC;


-- Q4: How many sub-categories are there under the Books category?
SELECT prod_cat, COUNT(prod_subcat) AS Count_Subcategories
FROM prod_cat_info
WHERE prod_cat = 'Books'
GROUP BY prod_cat;


-- Q5: What is the maximum quantity of products ever ordered?
SELECT TOP 1 tran_date, COUNT(QTY) AS Max_Qty
FROM Transactions
GROUP BY tran_date
ORDER BY COUNT(QTY) DESC;


-- Q6: What is the net total revenue generated in categories Electronics and Books?
SELECT 'Books & Electronics' AS Category, SUM(total_amt) AS Total_Revenue
FROM Transactions AS T
JOIN prod_cat_info AS P 
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat IN ('Books', 'Electronics');


-- Q7: How many customers have >10 transactions with us, excluding returns?
SELECT cust_id, COUNT(transaction_id) AS Total_Transactions
FROM Transactions
WHERE total_amt > 0
GROUP BY cust_id
HAVING COUNT(transaction_id) > 10;


-- Q8: What is the combined revenue earned from the “Electronics” & “Clothing” 
-- categories, from “Flagship stores”?
SELECT 'Electronics & Clothing' AS Category, SUM(T.total_amt) AS Total_Revenue
FROM Transactions AS T
JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat IN ('Electronics', 'Clothing') AND T.Store_type = 'Flagship store';


-- Q9: What is the total revenue generated from “Male” customers in the “Electronics” 
-- category? Output should display total revenue by product sub-category.
SELECT P.prod_cat, P.prod_subcat, COUNT(T.cust_id) AS Total_Customers
FROM Transactions AS T
JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
JOIN Customer AS C ON T.cust_id = C.customer_Id
WHERE C.Gender = 'M' AND P.prod_cat = 'Electronics'
GROUP BY P.prod_subcat, P.prod_cat;


-- Q10: What is the percentage of sales and returns by product sub-category?
-- Display only the top 5 sub-categories in terms of sales.
SELECT TOP 5  
    P.prod_subcat, P.prod_cat,
    ROUND(SUM(CASE WHEN T.Qty > 0 THEN T.Qty ELSE 0 END), 2) AS Sales,
    ABS(ROUND(SUM(CASE WHEN T.Qty < 0 THEN T.Qty ELSE 0 END), 2)) AS Returns,
    ROUND(SUM(CASE WHEN T.Qty > 0 THEN T.Qty ELSE 0 END), 2) 
    - ROUND(SUM(CASE WHEN T.Qty < 0 THEN T.Qty ELSE 0 END), 2) AS Net_Qty,
    ABS((ROUND(SUM(CASE WHEN T.Qty < 0 THEN T.Qty ELSE 0 END), 2)) /
       (ROUND(SUM(CASE WHEN T.Qty > 0 THEN T.Qty ELSE 0 END), 2)
       - ROUND(SUM(CASE WHEN T.Qty < 0 THEN T.Qty ELSE 0 END), 2)) * 100) AS [%_Returns],
    ((ROUND(SUM(CASE WHEN T.Qty > 0 THEN T.Qty ELSE 0 END), 2)) /
       (ROUND(SUM(CASE WHEN T.Qty > 0 THEN T.Qty ELSE 0 END), 2)
       - ROUND(SUM(CASE WHEN T.Qty < 0 THEN T.Qty ELSE 0 END), 2)) * 100) AS [%_Sales]
FROM Transactions AS T
JOIN prod_cat_info AS P 
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
GROUP BY P.prod_subcat, P.prod_cat
ORDER BY [%_Sales] DESC;


-- Q11: For all customers aged between 25 to 35 years, find the net total revenue 
-- generated by these consumers in the last 30 days of transactions.
SELECT cust_id, ROUND(SUM(total_amt), 2) AS Total_Revenue
FROM Transactions AS T
JOIN Customer AS C ON T.cust_id = C.customer_Id
WHERE DATEDIFF(YEAR, CONVERT(DATE, C.dob, 103), GETDATE()) BETWEEN 25 AND 35
AND CONVERT(DATE, tran_date, 103) BETWEEN DATEADD(DAY, -30, 
      (SELECT MAX(CONVERT(DATE, tran_date, 103)) FROM Transactions)) 
      AND (SELECT MAX(CONVERT(DATE, tran_date, 103)) FROM Transactions)
GROUP BY cust_id;


-- Q12: Which product category has seen the max value of returns in the last 3 months?
SELECT TOP 1 P.prod_cat, ROUND(SUM(ABS(T.total_amt)), 2) AS Total_Returns
FROM prod_cat_info AS P
JOIN Transactions AS T
ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE T.total_amt < 0 
AND CONVERT(DATE, tran_date, 103) BETWEEN DATEADD(MONTH, -3, 
      (SELECT MAX(CONVERT(DATE, tran_date, 103)) FROM Transactions)) 
      AND (SELECT MAX(CONVERT(DATE, tran_date, 103)) FROM Transactions)
GROUP BY P.prod_cat
ORDER BY Total_Returns DESC;


-- Q13: Which store-type sells the maximum products, by value of sales amount and by quantity sold?
SELECT store_type, SUM(total_amt) AS Total_Sales, SUM(qty) AS Total_Qty
FROM Transactions
GROUP BY store_type
HAVING SUM(total_amt) >= ALL (SELECT SUM(total_amt) FROM Transactions GROUP BY store_type)
AND SUM(qty) >= ALL (SELECT SUM(qty) FROM Transactions GROUP BY store_type);


-- Q14: What are the categories for which average revenue is above the overall average?
SELECT P.prod_cat, AVG(T.total_amt) AS Avg_Sales
FROM prod_cat_info AS P
JOIN Transactions AS T
ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY P.prod_cat
HAVING AVG(T.total_amt) > (SELECT AVG(total_amt) FROM Transactions);
