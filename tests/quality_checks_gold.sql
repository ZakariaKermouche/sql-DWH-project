/* ============================================================
   Script Name   : gold_layer_quality_checks.sql
   Description   : This script performs data quality checks
                   on the Gold Layer views in the DWH.
                   Checks include:
                   - Row counts
                   - Nulls in mandatory fields
                   - Duplicate keys
                   - Foreign key integrity
                   - Date validations
                   - Sales amount consistency
                   - Standardized categorical values
                   - Referential consistency with Silver layer
                   
   Author        : Zakaria Abdelmoumen Kermouche
   Created On    : 2025-09-15
   Layer         : Gold (Analytics-Ready / Star Schema)
   ============================================================ */

------------------- 1️⃣ ROW COUNTS -------------------

-- Product dimension
SELECT COUNT(*) AS dim_product_rows FROM gold.dim_product;

-- Customer dimension
SELECT COUNT(*) AS dim_customers_rows FROM gold.dim_customers;

-- Fact sales
SELECT COUNT(*) AS fact_sales_rows FROM gold.fact_sales;

------------------- 2️⃣ NULL / MANDATORY FIELDS -------------------

-- Dim Product
SELECT COUNT(*) AS null_mandatory_product
FROM gold.dim_product
WHERE product_number IS NULL OR product_name IS NULL;

-- Dim Customers
SELECT COUNT(*) AS null_mandatory_customer
FROM gold.dim_customers
WHERE customer_number IS NULL OR first_name IS NULL;

-- Fact Sales
SELECT COUNT(*) AS null_mandatory_sales
FROM gold.fact_sales
WHERE order_number IS NULL OR sales_amount IS NULL;

------------------- 3️⃣ DUPLICATE KEYS -------------------

-- Product Key
SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Customer Key
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Fact Sales (order + product + customer)
SELECT order_number, product_key, customer_key, COUNT(*) AS cnt
FROM gold.fact_sales
GROUP BY order_number, product_key, customer_key
HAVING COUNT(*) > 1;

------------------- 4️⃣ FOREIGN KEY INTEGRITY -------------------

-- fact_sales -> dim_product
SELECT COUNT(*) AS missing_product_keys
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- fact_sales -> dim_customers
SELECT COUNT(*) AS missing_customer_keys
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

------------------- 5️⃣ DATE VALIDATIONS -------------------

-- Fact Sales Dates
SELECT COUNT(*) AS invalid_fact_dates
FROM gold.fact_sales
WHERE order_date > CURRENT_DATE
   OR shipping_date > CURRENT_DATE
   OR due_date > CURRENT_DATE;

-- Customer Birth Dates
SELECT COUNT(*) AS invalid_birth_dates
FROM gold.dim_customers
WHERE birth_date > CURRENT_DATE;

------------------- 6️⃣ SALES AMOUNT VALIDATION -------------------

SELECT COUNT(*) AS sales_amount_mismatch
FROM gold.fact_sales
WHERE sales_amount <> quantity * price;

------------------- 7️⃣ STANDARDIZED VALUES -------------------

-- Gender
SELECT DISTINCT gender FROM gold.dim_customers;

-- Marital Status
SELECT DISTINCT marital_status FROM gold.dim_customers;

-- Maintenance
SELECT DISTINCT maintenance FROM gold.dim_product;

------------------- 8️⃣ REFERENTIAL CONSISTENCY -------------------

-- Product
SELECT COUNT(*) AS missing_silver_products
FROM gold.dim_product g
LEFT JOIN silver.crm_prd_info s
    ON g.product_number = s.prd_key
WHERE s.prd_key IS NULL;

-- Customer
SELECT COUNT(*) AS missing_silver_customers
FROM gold.dim_customers g
LEFT JOIN silver.crm_cust_info s
    ON g.customer_number = s.cst_key
WHERE s.cst_key IS NULL;

------------------- 9️⃣ SUMMARY QUERY -------------------

-- Example summary combining row counts and null checks
SELECT 
    'dim_product' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN product_number IS NULL OR product_name IS NULL THEN 1 ELSE 0 END) AS null_count
FROM gold.dim_product
UNION ALL
SELECT 
    'dim_customers',
    COUNT(*),
    SUM(CASE WHEN customer_number IS NULL OR first_name IS NULL THEN 1 ELSE 0 END)
FROM gold.dim_customers
UNION ALL
SELECT
    'fact_sales',
    COUNT(*),
    SUM(CASE WHEN order_number IS NULL OR sales_amount IS NULL THEN 1 ELSE 0 END)
FROM gold.fact_sales;
