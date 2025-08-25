-------------------------------------------------------------------------------
-- Script: ddl_bronze.sql
-- Purpose: Define CRM and ERP source tables in the bronze layer.
-- 
-- CRM: Contains customer, product, and sales details.
-- ERP: Contains customer demographics, location, and product category mappings.
-- 
-- These tables serve as raw ingestion sources for further transformation 
-- and integration in the data warehouse pipeline.
-- Author: Zakaria
-- Date: 2025-08-22
-------------------------------------------------------------------------------
  
-------------------CRM--------------
DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
	cst_id INTEGER,
	cst_key VARCHAR(20),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status CHAR(1),
	cst_gndr CHAR(1),
	cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
	prd_id INTEGER,
	prd_key VARCHAR(20),
	prd_nm VARCHAR(50),
	prd_cost INTEGER,
	prd_line VARCHAR(2),
	prd_start_dt DATE,
	prd_end_dt DATE
);

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num VARCHAR(20),
	sls_prd_key VARCHAR(20),
	sls_cust_id INTEGER,
	sls_order_dt INTEGER,
	sls_ship_dt INTEGER,
	sls_due_dt INTEGER,
	sls_sales INTEGER,
	sls_quantity INTEGER,
	sls_price INTEGER
);


-------------------------ERP---------------------------
DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
  cid VARCHAR(50),
  bdate DATE,
  gen VARCHAR(10)
);


DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
  cid VARCHAR(20),
  cntry VARCHAR(100)
);


DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
  id VARCHAR(20),
  cat VARCHAR(100),
  subcat VARCHAR(100),
  maintenance CHAR(3)   -- e.g. 'Yes' / 'No'
);

