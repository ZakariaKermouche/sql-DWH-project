/* ============================================================
   Script Name   : silver_layer_quality_checks.sql
   Description   : This script performs data quality checks
                   on the Silver Layer tables in the DWH.
                   Checks include:
                   - Row counts
                   - Nulls in mandatory fields
                   - Duplicate keys
                   - Referential consistency with source (Bronze) layer
                   - Standardized categorical values
                   
   Author        : Zakaria Abdelmoumen Kermouche
   Created On    : 2025-09-15
   Layer         : Silver (Cleansed & Standardized Data)
   ============================================================ */

------------------- 1️⃣ ROW COUNTS -------------------

-- CRM Tables
SELECT COUNT(*) AS crm_cust_info_rows FROM silver.crm_cust_info;
SELECT COUNT(*) AS crm_prd_info_rows FROM silver.crm_prd_info;
SELECT COUNT(*) AS crm_sales_details_rows FROM silver.crm_sales_details;

-- ERP Tables
SELECT COUNT(*) AS erp_cust_az12_rows FROM silver.erp_cust_az12;
SELECT COUNT(*) AS erp_loc_a101_rows FROM silver.erp_loc_a101;
SELECT COUNT(*) AS erp_px_cat_g1v2_rows FROM silver.erp_px_cat_g1v2;

------------------- 2️⃣ NULL / MANDATORY FIELDS -------------------

-- CRM Customer
SELECT COUNT(*) AS null_crm_cust
FROM silver.crm_cust_info
WHERE cst_id IS NULL OR cst_key IS NULL OR cst_firstname IS NULL OR cst_lastname IS NULL;

-- CRM Product
SELECT COUNT(*) AS null_crm_prod
FROM silver.crm_prd_info
WHERE prd_id IS NULL OR prd_key IS NULL OR prd_nm IS NULL;

-- CRM Sales
SELECT COUNT(*) AS null_crm_sales
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL OR sls_prd_key IS NULL OR sls_cust_id IS NULL;

-- ERP Customer
SELECT COUNT(*) AS null_erp_cust
FROM silver.erp_cust_az12
WHERE cid IS NULL OR gen IS NULL;

-- ERP Location
SELECT COUNT(*) AS null_erp_loc
FROM silver.erp_loc_a101
WHERE cid IS NULL OR cntry IS NULL;

-- ERP Product Category
SELECT COUNT(*) AS null_erp_cat
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL OR cat IS NULL;

------------------- 3️⃣ DUPLICATE KEYS -------------------

-- CRM Customer Key
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- CRM Product Key
SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- CRM Sales Composite Key (order + product + customer)
SELECT sls_ord_num, sls_prd_key, sls_cust_id, COUNT(*) AS cnt
FROM silver.crm_sales_details
GROUP BY sls_ord_num, sls_prd_key, sls_cust_id
HAVING COUNT(*) > 1;

-- ERP Customer Key
SELECT cid, COUNT(*) AS cnt
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-- ERP Location Key
SELECT cid, COUNT(*) AS cnt
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;

-- ERP Product Category Key
SELECT id, COUNT(*) AS cnt
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

------------------- 4️⃣ STANDARDIZED VALUES -------------------

-- CRM Customer Gender
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- CRM Customer Marital Status
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

-- ERP Product Category Maintenance
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;

-- ERP Location Country
SELECT DISTINCT cntry FROM silver.erp_loc_a101;

------------------- 5️⃣ DATE VALIDATIONS -------------------

-- CRM Customer Create Date
SELECT COUNT(*) AS invalid_cust_create_date
FROM silver.crm_cust_info
WHERE cst_create_date > CURRENT_DATE;

-- CRM Product Start and End Dates
SELECT COUNT(*) AS invalid_prod_dates
FROM silver.crm_prd_info
WHERE prd_start_dt > CURRENT_DATE
   OR (prd_end_dt IS NOT NULL AND prd_end_dt > CURRENT_DATE);

-- CRM Sales Dates
SELECT COUNT(*) AS invalid_sales_dates
FROM silver.crm_sales_details
WHERE sls_order_dt > CURRENT_DATE
   OR sls_ship_dt > CURRENT_DATE
   OR sls_due_dt > CURRENT_DATE;

-- ERP Customer Birthdate
SELECT COUNT(*) AS invalid_birth_date
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;

------------------- 6️⃣ SUMMARY QUERY -------------------

SELECT 'crm_cust_info' AS table_name, COUNT(*) AS total_rows,
       SUM(CASE WHEN cst_id IS NULL OR cst_key IS NULL OR cst_firstname IS NULL OR cst_lastname IS NULL THEN 1 ELSE 0 END) AS null_count
FROM silver.crm_cust_info
UNION ALL
SELECT 'crm_prd_info', COUNT(*),
       SUM(CASE WHEN prd_id IS NULL OR prd_key IS NULL OR prd_nm IS NULL THEN 1 ELSE 0 END)
FROM silver.crm_prd_info
UNION ALL
SELECT 'crm_sales_details', COUNT(*),
       SUM(CASE WHEN sls_ord_num IS NULL OR sls_prd_key IS NULL OR sls_cust_id IS NULL THEN 1 ELSE 0 END)
FROM silver.crm_sales_details
UNION ALL
SELECT 'erp_cust_az12', COUNT(*),
       SUM(CASE WHEN cid IS NULL OR gen IS NULL THEN 1 ELSE 0 END)
FROM silver.erp_cust_az12
UNION ALL
SELECT 'erp_loc_a101', COUNT(*),
       SUM(CASE WHEN cid IS NULL OR cntry IS NULL THEN 1 ELSE 0 END)
FROM silver.erp_loc_a101
UNION ALL
SELECT 'erp_px_cat_g1v2', COUNT(*),
       SUM(CASE WHEN id IS NULL OR cat IS NULL THEN 1 ELSE 0 END)
FROM silver.erp_px_cat_g1v2;
