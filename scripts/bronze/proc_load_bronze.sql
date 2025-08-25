-------------------------------------------------------------------------------
-- Procedure: bronze.load_bronze()
-- Purpose :  Load all CRM and ERP source files into the bronze layer.
--
-- Description:
--   - This procedure truncates each bronze table (CRM & ERP) before reloading.
--   - Data is ingested from CSV source files located in the local filesystem.
--   - Execution time for each table load is measured and logged with RAISE NOTICE.
--   - Global start and end time are also tracked to capture the total duration.
--   - Basic exception handling is included to capture unexpected errors.
--
-- CRM tables loaded:
--   1. bronze.crm_cust_info
--   2. bronze.crm_prd_info
--   3. bronze.crm_sales_details
--
-- ERP tables loaded:
--   1. bronze.erp_cust_az12
--   2. bronze.erp_loc_a101
--   3. bronze.erp_px_cat_g1v2
--
-- Usage:
--   CALL bronze.load_bronze();
--
-- Author : Zakaria
-- Date   : 2025-08-22
-------------------------------------------------------------------------------



CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE PLPGSQL
AS $$
	-- ============================================================
	-- Variables declaration
	-- ============================================================

	DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    global_start_time TIMESTAMP;
    global_end_time TIMESTAMP;
	-- ============================================================
	-- Load CRM Bronze Tables
	-- ============================================================
	
	-- 1. Customer Info
	BEGIN
		RAISE NOTICE 'Table loading started';


		start_time := clock_timestamp();
		global_start_time := start_time;
		TRUNCATE TABLE bronze.crm_cust_info;
		COPY bronze.crm_cust_info
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_crm\cust_info.csv'
		CSV HEADER;

		end_time := clock_timestamp();
		
		RAISE NOTICE 'cust table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

		-- 2. Product Info
		
		start_time := clock_timestamp();
		
		TRUNCATE TABLE bronze.crm_prd_info;
		COPY bronze.crm_prd_info
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_crm\prd_info.csv'
		CSV HEADER;
		
		end_time := clock_timestamp();
		RAISE NOTICE 'product table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
		
		-- 3. Sales Details

		start_time := clock_timestamp();
		
		TRUNCATE TABLE bronze.crm_sales_details;
		COPY bronze.crm_sales_details
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_crm\sales_details.csv'
		CSV HEADER;
		
		end_time := clock_timestamp();
		RAISE NOTICE 'sales table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
		
		
		-- ============================================================
		-- Load ERP Bronze Tables
		-- ============================================================
		
		-- 1. Customer Data
		
		start_time := clock_timestamp();
		
		TRUNCATE TABLE bronze.erp_cust_az12;
		COPY bronze.erp_cust_az12
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_erp\CUST_AZ12.csv'
		CSV HEADER;

		end_time := clock_timestamp();
		RAISE NOTICE 'erp cust table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
		
		-- 2. Location Data
		
		start_time := clock_timestamp();
		
		TRUNCATE TABLE bronze.erp_loc_a101;
		COPY bronze.erp_loc_a101
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_erp\LOC_A101.csv'
		CSV HEADER;

		end_time := clock_timestamp();
		RAISE NOTICE 'erp loc table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
		
		-- 3. Product Category Data

		start_time := clock_timestamp();
		
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		COPY bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ASUS\Documents\Perso\Projects\SQL DWH Project\Mine\datasets\source_erp\PX_CAT_G1V2.csv'
		CSV HEADER;

		end_time := clock_timestamp();
		RAISE NOTICE 'erp px cat table loaded successfully in % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
		

		global_end_time := end_time;
		RAISE NOTICE 'Loading All tables ended in % seconds', extract(EPOCH FROM (global_end_time - global_start_time));

	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '%','Error message: ' || SQLERRM;
	END
$$;
