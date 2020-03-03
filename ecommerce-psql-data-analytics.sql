-- A. M. ABEID HASSAN
-- CDIP ID # 905191030
-- Email: amabeid@gmail.com
-- Cell: 0173 191 5360


-- PostgreSQL SCRIPT
-- DATA ANALYSIS OF E-COMMERCE KAGGLE DATA SET


-- My Data Source: https://www.kaggle.com/carrie1/ecommerce-data


-- Short Description:
-- I have chosen an E-Commerce data set from
-- Kaggle to work on my data analysis project. Real e-commerce data
-- are difficult to find. This data set has been made available and
-- maintained by the UCI Machine Learning Repository. It contains data
-- of actual transactions made by a registered non-store online retail
-- company based in the UK from 2010 to 2011. Main products of the
-- company are all-occasion gift items, and many customers are
-- wholesalers.


-- a list of questions that I have tried to answer from this data set
-- in chronological order is as follows:

--1 read database from csv file
--2 count of rows & columns?
--3 description of variables/column labels?
--4 NULL values by column?
--5 How many rows & columns after deleting NULL values?
--6 transaction_value of each transaction?
--7 time period of data?
--8 explore quantity
--9 explore price
--10 explore transaction_value
--11 most frequently returned item?
--12 top 10 products by net sales value?
--13 net_sales_value by month?
--14 quarterly net_sales_value?
--15 frequently ordered items?
--16 which country has the highest number of orders?

---------------------------------------------------------------------
---------------------------------------------------------------------

--1 read database from csv file
drop table ecommerce cascade;
--1.i Create ecommerce TABLE
CREATE TABLE ecommerce(
-- sl_no INT
 invoice_no VARCHAR(15)
 ,stock_code VARCHAR(50)
 ,description VARCHAR(500)
 ,quantity NUMERIC
 ,invoice_date TIMESTAMP
 ,unit_price NUMERIC
 ,customer_id INT
 ,country VARCHAR(50)
);

--1.ii Load Data from original CSV file into e-commerce Table
COPY ecommerce
FROM '/home/abeid/Desktop/portfolio/e-commerce-data-analysis/ecommerce-data-original/ecommerce-data.csv'
DELIMITER ',' CSV HEADER;


--2 count of rows & columns in original data set?
SELECT
	COUNT (*) AS total_rows,
	(SELECT
		COUNT(*) AS total_col
	FROM
		information_schema.columns
	WHERE
		table_name='ecommerce')
FROM
	ecommerce;

--total_rows|total_col|
------------|---------|
--    541909|        9|

-- 8 columns in original dataset.
-- 1 column sl_no was added later.


--3 description of variables/column labels?
-- sl_no
-- invoice_no: transaction invoice
-- stock_code: unique code for each type of item/transaction
-- description: describes the types of transactions
-- quantity: order quantity
-- invoice_date: date and time of the order
-- unit_price: unit price of items
-- customer_id: unique id of each customer
-- country: country of origin of the order


--4.i NULL values by column?
SELECT
--	SUM(CASE WHEN sl_no IS NULL THEN 1 ELSE 0 END) AS sl_no,
	SUM(CASE WHEN invoice_no IS NULL THEN 1 ELSE 0 END) AS invoice_no,
	SUM(CASE WHEN stock_code IS NULL THEN 1 ELSE 0 END) AS stock_code,
	SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description,
	SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity,
	SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS invoice_date,
	SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country
FROM
	ecommerce;

-- description has 1,454 rows with NULL values (0.27%).
-- customer_id has 135,080 rows with NULL values (24.93%).
-- chart in excel

--4.ii rows with NULL description dropped
DELETE FROM
	ecommerce
WHERE
	description IS NULL;

-- description has 0.24% NULL values, which is a very small number.
-- types of transactions of these entries could not be identified.
-- therefore, 1,454 rows where description is null were dropped.

--4.iii column customer_id was dropped
ALTER TABLE
	ecommerce
DROP COLUMN
	customer_id;

-- customer_id has 24.93% NULL values, which is quite a number of
-- rows with NULL values.
-- therefore, this whole column was deleted.

select * from ecommerce;


--5.i How many rows & columns after deleting NULL values?
SELECT
	COUNT (*) AS total_rows,
	(
	SELECT
		COUNT(*) AS total_col
	FROM
		information_schema.columns
	WHERE table_name='ecommerce')
FROM
	ecommerce

--total_rows|total_col|
------------|---------|
--    540455|        7|

--5.ii Any NULL values?
SELECT
--	SUM(CASE WHEN sl_no IS NULL THEN 1 ELSE 0 END) AS sl_no,
	SUM(CASE WHEN invoice_no IS NULL THEN 1 ELSE 0 END) AS invoice_no,
	SUM(CASE WHEN stock_code IS NULL THEN 1 ELSE 0 END) AS stock_code,
	SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description,
	SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity,
	SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS invoice_date,
	SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price,
	--SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id,
 	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country
FROM
	ecommerce;

-- no NULL values.


--6 transaction_value? (quantity*unit_price)
CREATE VIEW ecommerce_v1_transval AS
	SELECT
		*, unit_price * quantity AS transaction_value
	FROM
		ecommerce
	ORDER BY
		transaction_value ASC;

SELECT * FROM ecommerce_v1_transval order by invoice_date limit 5;

-- a new column transaction_value (unit_price * quantity) was created.
-- the ecommerce dataset with this column was stored in view
-- ecommerce_v1_transval.


--7.i time period of data?
SELECT MIN(invoice_date), MAX(invoice_date) from ecommerce;

-- data available from 2010-12-01 to 2011-12-09.

-- for analysis, we will take 1 year data from 2010-12-01 to
-- 2011-11-30.

--7.ii create view ecommerce_v2_master with transaction_value column
-- and data from 2010-12-01 to 2011-11-30
CREATE VIEW ecommerce_v2_master AS
	SELECT
		*
	FROM
		ecommerce_v1_transval
	WHERE
		DATE_TRUNC('month', invoice_date) BETWEEN '2010-12-01' AND '2011-11-01';

select * from ecommerce_v2_master order by invoice_date limit 5;

-- 1 year data from 12-01 to 2011-11-30 with transaction_value column
-- was stored in view ecommerce_v2_master.

--we will use ecommerce_v2_master for further analysis of data.

--7.iii Data size after dropping data after Nov 30, 2011?
SELECT COUNT (*) AS total_rows FROM ecommerce_v2_master;

--total_rows|total_col|
------------|---------|
--    514945|        8|


--8 explore quantity
--8.i veiw of description and quantity
SELECT
	description, quantity
FROM
	ecommerce_v2_master
ORDER BY
	2 ASC
Limit 5;

-- there are -ve figures in quantity.
-- we can assume that these are items returned by customers.

--8.ii item with the highest -ve quantity?
SELECT
	description, SUM(quantity)
FROM
	ecommerce_v2_master
WHERE
	quantity < 0
GROUP BY
	description
ORDER BY
	2 ASC;

-- MEDIUM CERAMIC TOP STORAGE JAR: -74,494 units.

-- examination of top 100 items with -ve quantity reveals the
-- different types of description other than the description/name
-- of all-occassion unique gift items.

-- these 'other' descriptions include key words such as 'thrown away',
-- 'destroyed', 'check', '?', 'damaged/damages', 'incorrect entry',
-- 'manual', 'wrongly marked', 'missing', 'wet', 'mystery', 'given away',
-- 'adjustment', 'sold as set', 'discount', 'lost', and 'counted'.

-- it would be interesting to check thrown away, destroyed, damaged, missing, lost,
-- discount, and given_away

--8.iii no_of_items & total_quantity destroyed, damaged, missing, lost, and thrown away?
SELECT 'destroyed' AS description, SUM(quantity) AS total_qty, COUNT(DISTINCT stock_code) AS no_of_items FROM ecommerce_v2_master WHERE description ILIKE '%destroy%'
UNION
SELECT 'damaged' AS description, SUM(quantity) AS total_qty, COUNT(DISTINCT stock_code) AS no_of_items FROM ecommerce_v2_master WHERE description ILIKE '%damage%'
UNION
SELECT 'missing' AS description, SUM(quantity) AS total_qty, COUNT(DISTINCT stock_code) AS no_of_items FROM ecommerce_v2_master WHERE description ILIKE '%missing%'
UNION
SELECT 'lost' AS description, SUM(quantity) AS total_qty, COUNT(DISTINCT stock_code) AS no_of_items FROM ecommerce_v2_master WHERE description ILIKE '%lost%'
UNION
SELECT 'thrown_away' AS description, SUM(quantity) AS total_qty, COUNT(DISTINCT stock_code) AS no_of_items FROM ecommerce_v2_master WHERE description ILIKE '%thrown%'

--description|total_qty|no_of_items|
-------------|---------|-----------|
--thrown_away|   -42229|         19|
--damaged    |   -21490|        119|
--destroyed  |   -15644|          9|
--missing    |    -4452|         10|
--lost       |    -2761|          5|

--8.iv Discount
select * from ecommerce_v2_master where description ILIKE '%discount%' order by invoice_date;

--8.iv.a total_value of discount?
SELECT
	SUM(transaction_value) as discount_total_value
FROM
	ecommerce_v2_master
WHERE
	description ILIKE '%discount%';

-- Total value of discounts = -5667.54

--8.iv.b when did the company offered the discounts?
-- discount by month
SELECT
	date_trunc('month', invoice_date) as month,
	SUM(transaction_value) as discount_value
FROM
	ecommerce_v2_master
WHERE
	description ILIKE '%discount%'
GROUP BY
 	month
ORDER BY
	1, 2 ASC;

--month              |discount_value|
---------------------|--------------|
--2010-12-01 00:00:00|       -693.98|
--2011-01-01 00:00:00|        -22.97|
--2011-02-01 00:00:00|       -284.99|
--2011-03-01 00:00:00|       -224.21|
--2011-04-01 00:00:00|      -1999.62|
--2011-05-01 00:00:00|        -94.42|
--2011-06-01 00:00:00|       -312.48|
--2011-07-01 00:00:00|       -164.03|
--2011-08-01 00:00:00|      -1013.04|
--2011-09-01 00:00:00|       -326.87|
--2011-10-01 00:00:00|        -56.08|
--2011-11-01 00:00:00|       -474.85|


--9.i explore price
SELECT
	*
FROM
	ecommerce_v2_master
ORDER BY
	unit_price ASC;

-- there are items with 0 unit_price.

--9.ii quantity by description with  unit_price=0 & qty<1

--select * from ecommerce_v2_master where unit_price = 0 AND quantity <1 order by invoice_date asc;

SELECT
	description,
	sum(quantity) as qty
FROM
	ecommerce_v2_master
WHERE
	unit_price = 0
	AND quantity <1
GROUP BY
	description
ORDER BY
	2;

-- examination of items with 0 unit_price and -ve quantity
-- represents items that are thrown away, destroyed, damaged,
-- missing, lost, etc.

--9.iii quantity by description with  unit_price=0 & qty>0
SELECT
	description, SUM(quantity) as qty
FROM
	ecommerce_v2_master
WHERE
	unit_price=0 AND quantity > 0
GROUP BY
	1
ORDER BY
	2 ASC;

-- for items with 0 unit_price and +ve quantity we can assume that
-- these were given away as gifts
-- there is another description called 'found'; these are lost items
-- which were found


--10 explore transaction_value
SELECT
	description, SUM(transaction_value) AS total_sales_value
FROM
	ecommerce_v2_master
WHERE
	quantity < 0 AND unit_price > 0
GROUP BY
	1
ORDER BY
	2 ASC;
-- examination of transaction_value by items with +ve qty reveals a
-- transaction called 'DOTCOM POSTAGE'.

-- examination of transaction_value by items with -ve qty reveals
-- transactions such as 'AMAZON FEE', 'Manual', 'POSTAGE',
-- 'Bank Charges', and 'CRUK Commission'.

select * from ecommerce_v2_master where description ILIKE '%commission%';


--11 summary report on returns

--11.i sales
CREATE VIEW ecommerce_v3_sales AS
	SELECT
		*
	FROM
		ecommerce_v2_master
	WHERE
		quantity > 0 AND unit_price > 0;

select * from ecommerce_v3_sales order by invoice_date;

--11.ii returns
CREATE VIEW ecommerce_v4_returns AS
	SELECT
		*
	FROM
		ecommerce_v2_master
	WHERE
		quantity < 0 AND unit_price >1;

select * from ecommerce_v4_returns order by invoice_date;

--11.iii most frequently returned items?
SELECT
	description,
	COUNT(description) AS frequency,
	SUM(quantity) AS total_qty,
	SUM(transaction_value) AS total_returns_value
FROM
	ecommerce_v4_returns
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 20;

--description                       |frequency|total_qty|total_returns_value|
------------------------------------|---------|---------|-------------------|
--REGENCY CAKESTAND 3 TIER          |      177|     -848|           -9618.60|
--JAM MAKING SET WITH JARS          |       85|     -244|           -1000.04|
--SET OF 3 CAKE TINS PANTRY DESIGN  |       69|     -149|            -705.35|
--STRAWBERRY CERAMIC TRINKET BOX    |       55|     -363|            -415.75|
--ROSES REGENCY TEACUP AND SAUCER   |       53|     -436|           -1147.40|
--WOOD 2 DRAWER CABINET WHITE FINISH|       44|     -204|           -1226.80|
--RECIPE BOX PANTRY YELLOW DESIGN   |       44|     -146|            -406.30|
--LUNCH BAG RED RETROSPOT           |       44|     -574|            -854.70|
--RED RETROSPOT CAKE STAND          |       42|     -322|           -2480.50|
--GREEN REGENCY TEACUP AND SAUCER   |       41|     -142|            -390.10|


--12 top 10 products by net sales value? (net sales = sales minus returns)
-- net_sales_value by products
SELECT
	description, SUM(transaction_value) AS net_sales_value
FROM
	ecommerce_v2_master
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 11;

--description                       |net_sales_value|
------------------------------------|---------------|
--DOTCOM POSTAGE                    |      186372.79|
--REGENCY CAKESTAND 3 TIER          |      158859.27|
--WHITE HANGING HEART T-LIGHT HOLDER|       97464.40|
--PARTY BUNTING                     |       97384.50|
--JUMBO BAG RED RETROSPOT           |       90160.33|
--POSTAGE                           |       63505.85|
--RABBIT NIGHT LIGHT                |       57138.58|
--PAPER CHAIN KIT 50'S CHRISTMAS    |       56921.23|
--ASSORTED COLOUR BIRD ORNAMENT     |       56796.99|
--CHILLI LIGHTS                     |       51134.07|

-- the item with the highest amount is DOTCOM POSTAGE.
-- this is probably the amount the customers paid for delivery of their orders.


--13 net_sales_value by month?
SELECT
	DATE_TRUNC('month',invoice_date) AS month,
	SUM(transaction_value) AS net_sales_value
FROM
	ecommerce_v2_master
GROUP BY 1
ORDER BY 1 asc;

-- *note: net_sales_value includes 'DOTCOM POSTAGE', AMAZON FEE',
-- 'Manual', 'POSTAGE', 'Bank Charges', and 'CRUK Commission'

--month              |net_sales_value|
---------------------|---------------|
--2010-12-01 00:00:00|      748957.02|
--2011-01-01 00:00:00|      560000.26|
--2011-02-01 00:00:00|      498062.65|
--2011-03-01 00:00:00|      683267.08|
--2011-04-01 00:00:00|     493207.121|
--2011-05-01 00:00:00|      723333.51|
--2011-06-01 00:00:00|      691123.12|
--2011-07-01 00:00:00|     681300.111|
--2011-08-01 00:00:00|      682680.51|
--2011-09-01 00:00:00|    1019687.622|
--2011-10-01 00:00:00|     1070704.67|
--2011-11-01 00:00:00|     1461756.25|


--14 quarterly net_sales_value?
SELECT
	DATE_TRUNC('quarter',invoice_date) AS quarter,
	SUM(transaction_value) as net_sales_value
FROM
	ecommerce_v2_master
GROUP BY 1
ORDER BY 1 ASC;

quarter            |net_sales_value|
-------------------|---------------|
2011-01-01 00:00:00|     1741329.99|
2011-04-01 00:00:00|    1907663.751|
2011-07-01 00:00:00|    2383668.243|

-- the table above shows q1,q2 and q3 figures of 2011.


--15 frequently ordered items?
-- top 10 items by no_of_orders & max purchase amount
-- count of description, max of transaction_value grouped by
-- description
SELECT
	description, COUNT(description) AS no_of_orders,
	MAX(transaction_value) as max_purchase_amount
FROM
	ecommerce_v2_master
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 10;

--description                       |no_of_orders|max_purchase_amount|
------------------------------------|------------|-------------------|
--WHITE HANGING HEART T-LIGHT HOLDER|        2306|            4921.50|
--REGENCY CAKESTAND 3 TIER          |        2134|            2978.40|
--JUMBO BAG RED RETROSPOT           |        2101|            1980.00|
--PARTY BUNTING                     |        1699|            1542.97|
--LUNCH BAG RED RETROSPOT           |        1594|             302.56|
--ASSORTED COLOUR BIRD ORNAMENT     |        1454|            4176.00|
--SET OF 3 CAKE TINS PANTRY DESIGN  |        1426|            3170.16|
--PACK OF 72 RETROSPOT CAKE CASES   |        1348|             604.80|
--LUNCH BAG  BLACK SKULL.           |        1298|             290.00|
--NATURAL SLATE HEART CHALKBOARD    |        1235|             367.20|


-- 16 which country has the highest number of orders?
-- NO_OF_ORDERS BY COUNTRIES
SELECT
	country, COUNT(country) AS no_of_orders
FROM
	ecommerce_v2_master
GROUP BY
	country
ORDER BY
	2 DESC;
LIMIT 5;

--country       |no_of_orders|
----------------|------------|
--United Kingdom|      470113|
--Germany       |        9155|
--France        |        8218|
--EIRE          |        7861|
--Spain         |        2462|

-- UK has the highest number of orders, followed by Germany, France &
-- Ireland
