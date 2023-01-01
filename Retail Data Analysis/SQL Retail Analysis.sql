SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions
---------------------------Data Preparation and Understanding----------------------------
--Ans 1
SELECT 'Customer' AS TBL_NAME, COUNT(*) AS NO_OF_RECORDS FROM [dbo].[Customer]
UNION ALL
SELECT 'prod_cat_info', COUNT(*) FROM [dbo].[prod_cat_info]
UNION ALL
SELECT 'Transactions', COUNT(*) FROM [dbo].[Transactions]


--Ans 2
SELECT COUNT(*) AS COUNT_RETURN 
FROM Transactions
WHERE QTY < 0


--Ans 3 Done while importing the data set


--Ans 4 
SELECT DATEFROMPARTS(MIN(YEAR(TRAN_DATE)), MIN(MONTH(TRAN_DATE)), MIN(DAY(TRAN_DATE))) AS MIN_TRANS_DATE, 
DATEFROMPARTS(MAX(YEAR(TRAN_DATE)), MAX(MONTH(TRAN_DATE)), MAX(DAY(TRAN_DATE))) AS MAX_TRANS_DATE
FROM Transactions


--Ans 5
SELECT prod_cat, prod_subcat FROM prod_cat_info
WHERE prod_subcat = 'DIY'
-----------------------------------Data Analysis-----------------------------------

--Ans 1
SELECT TOP 1 Store_Type, COUNT(Store_Type) AS COUNT_MOST_Used
FROM Transactions
GROUP BY Store_Type
Order BY COUNT(Store_Type) Desc


--Ans 2
SELECT GENDER,COUNT(customer_Id) AS COUNT_GENDER
FROM Customer
GROUP BY GENDER


--Ans 3
SELECT TOP 1 city_code,COUNT(customer_Id) AS COUNT_CUST
FROM Customer
GROUP BY city_code
ORDER BY COUNT(customer_Id) DESC


--Ans 4
SELECT prod_cat, COUNT(prod_subcat) AS COUNT_SUBCAT
FROM prod_cat_info
WHERE prod_cat = 'Books' 
GROUP BY prod_cat


--Ans 5
SELECT TOP 1 tran_date, COUNT(QTY) AS COUNT_MAX
FROM Transactions
GROUP BY tran_date
ORDER BY COUNT(QTY) DESC


--Ans 6
SELECT 'BOOKS AND ELECTRONICS' AS CATEGORY, SUM(T1.total_amt) as TOT_Revenue
FROM Transactions AS T1 INNER JOIN prod_cat_info AS T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code AND
T1.prod_cat_code = T2.prod_cat_code
WHERE T2.prod_cat IN ('Books', 'Electronics')


--Ans 7
SELECT cust_id, COUNT(transaction_id) as TOT_Tran
FROM Transactions
WHERE total_amt > 0
GROUP BY cust_id
HAVING COUNT(transaction_id) > 10

--There are 6 such customer


--Ans 8
SELECT 'Electronics and Clothing' AS CATEGORY, SUM(T1.total_amt) as TOT_Revenue
FROM Transactions AS T1 INNER JOIN prod_cat_info AS T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code AND
T1.prod_cat_code = T2.prod_cat_code
WHERE T2.prod_cat IN ('Electronics', 'Clothing') AND T1.Store_type = 'Flagship store'


--Ans 9
SELECT T2.prod_cat, T2.prod_subcat, Count(T1.cust_id) as TOT_CUST
FROM Transactions AS T1 INNER JOIN prod_cat_info AS T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code AND
T1.prod_cat_code = T2.prod_cat_code
INNER JOIN Customer as T3  ON
T1.cust_id = T3.customer_Id
WHERE T3.Gender= 'M' AND T2.prod_cat = 'Electronics'
GROUP BY T2.prod_subcat, T2.prod_cat


--Ans 10
SELECT TOP 5  
 T2.prod_subcat , T2.prod_cat,
      Round(SUM(cast( case when T1.Qty > 0 then T1.Qty else 0 end as float)),2)[Sales]  , 
     ABS(Round(SUM(cast( case when T1.Qty < 0 then T1.Qty   else 0 end as float)),2)) [Returns] ,
    Round(SUM(cast( case when T1.Qty > 0 then T1.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T1.Qty < 0 then T1.Qty   else 0 end as float)),2)[total_qty],
    ABS((Round(SUM(cast( case when T1.Qty < 0 then T1.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T1.Qty > 0 then T1.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T1.Qty < 0 then T1.Qty   else 0 end as float)),2)))*100[%_Returs],
    ((Round(SUM(cast( case when T1.Qty > 0 then T1.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T1.Qty > 0 then T1.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T1.Qty < 0 then T1.Qty   else 0 end as float)),2)))*100[%_sales]
    FROM Transactions as T1
    INNER JOIN prod_cat_info as T2 ON T1.prod_subcat_code = T2.prod_sub_cat_code
	AND T1.prod_subcat_code = T2.prod_sub_cat_code 
    GROUP BY T2.prod_subcat ,T2.prod_cat
    ORDER BY [%_sales] desc 


--Ans 11
SELECT cust_id, ROUND(SUM(total_amt), 2) as revenue FROM transactions as t1
INNER JOIN customer t2 on t1.cust_id=t2.customer_id
WHERE datediff(year,convert(date,dob,103),getdate()) between 25 AND 35
AND convert(date,tran_date,103) BETWEEN dateadd(day,-30,(SELECT MAX(convert(date,tran_date,103)) FROM transactions)) 
AND (SELECT MAX(convert(date,tran_date,103)) FROM transactions)
GROUP BY cust_id


--Ans 12
SELECT TOP 1  T1.prod_cat, ROUND(SUM(ABS(T2.total_amt)), 2) AS TOT_AMT
FROM prod_cat_info AS T1 
INNER JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code
AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE T2.total_amt<0 and 
convert(date, tran_date, 103) between dateadd(month,-3,(select max(convert(date,tran_date,103)) from transactions))
and (select max(convert(date,tran_date,103)) from transactions)
GROUP BY T1.prod_cat
ORDER BY TOT_AMT Desc


--Ans 13
SELECT store_type, SUM(total_amt) TOT_SALES, SUM(qty) TOT_Qty
FROM Transactions
GROUP BY store_type
HAVING SUM(total_amt) >=ALL (SELECT SUM(TOTAL_AMT) FROM Transactions GROUP BY store_type)
AND SUM(qty) >=ALL (SELECT SUM(QTY) FROM Transactions GROUP BY store_type)


--Ans 14
SELECT T1.prod_cat, AVG(T2.total_amt) as AVG_SALE FROM prod_cat_info AS T1 
INNER JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code
AND T1.prod_sub_cat_code = T2.prod_subcat_code
GROUP BY T1.prod_cat
HAVING AVG(T2.total_amt) > (SELECT AVG(total_amt) from Transactions)

--Ans 15
SELECT T1.prod_cat, T1.prod_subcat, SUM(T2.total_amt) AS TOT_REV , AVG(T2.total_amt) as AVG_REV
FROM prod_cat_info AS T1 
INNER JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code
AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE Prod_cat IN
(
SELECT TOP 5 
Prod_cat
FROM transactions as t3
INNER JOIN prod_cat_info as t4 ON t3.prod_cat_code= t4.prod_cat_code AND t3.prod_subcat_code = t4.prod_sub_cat_code
GROUP BY Prod_cat
ORDER BY SUM(QTY) DESC
)
GROUP BY T1.prod_cat, prod_subcat 
ORDER BY T1.prod_cat

















