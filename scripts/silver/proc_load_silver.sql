/* ============================================================
   Procedure Name : silver.load_silver
   Description    : Loads and transforms data from Bronze Layer 
                    into the Silver Layer tables. 
                    - Applies business rules & data cleansing
                    - Standardizes formats
                    - Ensures data quality for downstream usage

   CRM Processing:
     - crm_cust_info:
         * Deduplicate by latest record (ROW_NUMBER)
         * Standardize marital status (Single, Married, n/a)
         * Standardize gender (Male, Female, n/a)
     - crm_prd_info:
         * Derive category_id from product_key
         * Standardize product_line values
         * Compute product_end_date using LEAD()
     - crm_sales_details:
         * Validate and format dates
         * Fix inconsistent or missing sales values
         * Standardize negative/missing prices

   ERP Processing:
     - erp_cust_az12:
         * Clean customer IDs (remove NAS prefix)
         * Validate birth dates (exclude future dates)
         * Normalize gender values
     - erp_loc_a101:
         * Remove dashes from customer IDs
         * Map country codes to full names (e.g., DE → Germany, US/USA → United States)
         * Default to 'n/a' when missing
     - erp_px_cat_g1v2:
         * Direct copy from Bronze to Silver

   Author        : Zakaria Abdelmoumen Kermouche
   Created On    : 2025-08-22
   Layer         : Silver (Cleansed & Standardized Data)

   How to Call   :
     CALL silver.load_silver();
   ============================================================ */


CREATE OR REPLACE PROCEDURE silver.load_silver ()
LANGUAGE PLPGSQL
AS $$

BEGIN

INSERT into silver.crm_cust_info
(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
) 
select 
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM(cst_lastname),
CASE WHEN cst_marital_status = 'S' THEN 'SINGLE'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
	 ELSE 'n/a'
END,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
	 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
	 ELSE 'n/a'
END,
cst_create_date
from 
(
select 
*,
ROW_NUMBER() over (partition by cst_id order by crm_cust_info.cst_create_date desc) flag_test
from bronze.crm_cust_info 

) t where flag_test=1;

TRUNCATE silver.crm_prd_info;
insert into silver.crm_prd_info
(
	prd_id ,
	cat_id,
	prd_key ,
	prd_nm ,
	prd_cost ,
	prd_line ,
	prd_start_dt ,
	prd_end_dt
)
select 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7) prd_key,
	prd_nm,
	COALESCE (prd_cost, 0) prd_cost,
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Medium'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Small'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Ride'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Train'
		ELSE 'n/a'
	END prd_line,
	prd_start_dt,
	LEAD(prd_start_dt) over (PARTITION by prd_key order by prd_start_dt) - 1 as prd_end_dt
FROM bronze.crm_prd_info;


TRUNCATE table silver.crm_sales_details;
INSERT INTO silver.crm_sales_details
(
	SLS_ORD_NUM,
	SLS_PRD_KEY,
	SLS_CUST_ID,
	SLS_ORDER_DT,
	SLS_SHIP_DT,
	SLS_DUE_DT,
	SLS_SALES,
	SLS_QUANTITY,
	SLS_PRICE
)
select 
	SLS_ORD_NUM,
	SLS_PRD_KEY,
	SLS_CUST_ID,
	CASE 
		WHEN sls_order_dt <= 0 or length(cast(sls_order_dt as text)) != 8 THEN NULL
		ELSE  CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE)
	END,
	CASE 
		WHEN SLS_SHIP_DT <= 0 or length(cast(SLS_SHIP_DT as text)) != 8 THEN NULL
		ELSE  CAST(CAST(SLS_SHIP_DT AS VARCHAR(8)) AS DATE)
	END,
	CASE 
		WHEN SLS_DUE_DT <= 0 or length(cast(SLS_DUE_DT as text)) != 8 THEN NULL
		ELSE CAST(CAST(SLS_DUE_DT AS VARCHAR(8)) AS DATE)
	END,
	CASE
		WHEN SLS_SALES != SLS_QUANTITY * ABS(SLS_PRICE)
		OR SLS_SALES IS NULL
		OR SLS_SALES <= 0 THEN SLS_QUANTITY * ABS(SLS_PRICE)
		ELSE SLS_SALES
	END,
	SLS_QUANTITY,
	CASE 
		WHEN SLS_PRICE < 0 THEN ABS(SLS_PRICE)
		WHEN SLS_PRICE IS NULL THEN SLS_SALES / NULLIF(SLS_QUANTITY, 0)
		ELSE SLS_PRICE
	END
FROM 
	bronze.crm_sales_details;



----------------------------ERP---------------------------------------
TRUNCATE TABLE silver.erp_cust_az12;

insert into silver.erp_cust_az12
(
cid, bdate, gen
)
SELECT
	CASE
		WHEN CID LIKE 'NAS%' THEN TRIM(SUBSTRING(CID, 4, LENGTH(CID)))
		ELSE TRIM(CID)
	END CID,
	CASE
		WHEN BDATE > CURRENT_DATE THEN NULL
		ELSE BDATE
	END,
	CASE
		WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'male'
		ELSE 'n/a'
	END
FROM
	BRONZE.ERP_CUST_AZ12;


TRUNCATE table silver.erp_loc_a101;
insert into silver.erp_loc_a101 (
cid, cntry
)
SELECT
	REPLACE(CID, '-', ''),
	CASE
		WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Germany'
		WHEN UPPER(TRIM(CNTRY)) = 'USA'
		OR UPPER(TRIM(CNTRY)) = 'US' THEN 'United States'
		WHEN UPPER(TRIM(CNTRY)) IS NULL
		OR UPPER(TRIM(CNTRY)) = '' THEN 'n/a'
		ELSE CNTRY
	END
FROM
	BRONZE.ERP_LOC_A101;


TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO
	SILVER.ERP_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
SELECT
	*
FROM
	BRONZE.ERP_PX_CAT_G1V2;

END

$$;
