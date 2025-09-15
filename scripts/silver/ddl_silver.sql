/* ============================================================
   Script Name   : silver_layer_tables.sql
   Description   : This script creates the Silver Layer tables 
                   for CRM and ERP data sources in the DWH.
                   - Drops existing tables if they exist
                   - Creates new table structures
                   - Adds audit column (dwh_create_date)

   Author        : Zakaria Abdelmoumen Kermouche
   Created On    : 2025-08-22
   Layer         : Silver (Cleansed & Standardized Data)
   ============================================================ */

------------------- CRM -------------------
DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
	cst_id INTEGER,
	cst_key VARCHAR(20),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status CHAR(10),
	cst_gndr CHAR(10),
	cst_create_date DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
	prd_id INTEGER,
	cat_id VARCHAR(20),
	prd_key VARCHAR(20),
	prd_nm VARCHAR(50),
	prd_cost INTEGER,
	prd_line VARCHAR(20),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sls_ord_num VARCHAR(20),
	sls_prd_key VARCHAR(20),
	sls_cust_id INTEGER,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INTEGER,
	sls_quantity INTEGER,
	sls_price INTEGER,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


------------------- ERP -------------------
DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
 	cid VARCHAR(50),
  	bdate DATE,
  	gen VARCHAR(10),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
  	cid VARCHAR(20),
  	cntry VARCHAR(100),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
	id VARCHAR(20),
	cat VARCHAR(100),
	subcat VARCHAR(100),
	maintenance CHAR(3),   -- e.g. 'Yes' / 'No'
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
