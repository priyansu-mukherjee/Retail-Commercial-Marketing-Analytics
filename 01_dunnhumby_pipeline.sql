/* =====================================================================
   PROJECT: Dunnhumby Retail Analytics (Sales & Margin Realization)
   PURPOSE: End-to-End Pipeline: Tables, CSV Loads, View & Audit
   AUTHOR:  Portfolio Project
   ===================================================================== */

-- 1. Database Initialization
CREATE DATABASE IF NOT EXISTS dunnhumby_retail;
USE dunnhumby_retail;

-- Enable local file loading
SET GLOBAL local_infile = 1;


-- 2. Household Demographic Dimension
DROP TABLE IF EXISTS hh_demographic;
CREATE TABLE hh_demographic (
age_desc     VARCHAR(20),
marital_status_code VARCHAR(10),
income_desc   VARCHAR(50),
homeowner_desc    VARCHAR(50),
hh_comp_desc    VARCHAR(50),
household_size_desc  VARCHAR(20),
kid_category_desc   VARCHAR(20),
household_key     INT PRIMARY KEY
);

LOAD DATA LOCAL INFILE 'C:/Users/there/Downloads/archive (8)/hh_demographic.csv'
INTO TABLE hh_demographic
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 3. Product Dimension
DROP TABLE IF EXISTS product;
CREATE TABLE product (
product_id  INT PRIMARY KEY,
manufacturer   INT,
department   VARCHAR(50),
brand       VARCHAR(20),
commodity_desc  VARCHAR(100),
sub_commodity_desc VARCHAR(100),
curr_size_of_product VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/there/Downloads/archive (8)/product.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 4. Transaction Fact Table
DROP TABLE IF EXISTS transaction_data;
CREATE TABLE transaction_data (
household_key   INT,
basket_id   BIGINT,
day       INT,
product_id INT,
quantity     INT,
sales_value  DECIMAL(10,2),
store_id    INT,
retail_disc   DECIMAL(10,2),
trans_time  INT,
week_no     INT,
coupon_disc   DECIMAL(10,2),
coupon_match_disc  DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'C:/Users/there/Downloads/archive (8)/transaction_data.csv'
INTO TABLE transaction_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 5. Business View: Cleaned Transactions with Promo Realization
CREATE OR REPLACE VIEW v_clean_transactions AS
SELECT 
household_key,
basket_id,
day,
product_id,
quantity,
sales_value,
store_id,
week_no,
ABS(retail_disc)      AS retail_disc,
ABS(coupon_disc)     AS coupon_disc,
(ABS(retail_disc) + ABS(coupon_disc))   AS total_discount,
(sales_value + ABS(retail_disc) + ABS(coupon_disc))   AS gross_sales_value
FROM transaction_data
WHERE sales_value > 0
AND quantity > 0
AND quantity <= 100;


-- 6. Verification Audit
SELECT 'hh_demographic' AS table_name, COUNT(*) AS total_records FROM hh_demographic
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'transaction_data', COUNT(*) FROM transaction_data
UNION ALL
SELECT 'v_clean_transactions', COUNT(*) FROM v_clean_transactions;