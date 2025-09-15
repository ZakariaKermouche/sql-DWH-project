/* ============================================================
   Script Name   : gold_layer_views.sql
   Description   : This script creates the Gold Layer views 
                   for CRM and ERP data sources in the DWH.
                   - Creates dimension and fact views
                   - Integrates Silver Layer data
                   - Adds surrogate keys for dimensions
                   - Cleans and standardizes data for analytics
                   
   Views         : dim_product, dim_customers, fact_sales
   Author        : Zakaria Abdelmoumen Kermouche
   Created On    : 2025-09-15
   Layer         : Gold (Analytics-Ready / Star Schema)
   ============================================================ */

------------------- DIMENSION: Products -------------------

CREATE OR REPLACE VIEW gold.dim_product AS
SELECT
    row_number() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
    pi.prd_id AS product_id,
    pi.cat_id AS category_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pcg.cat AS category,
    pcg.subcat AS subcategory,
    pcg.maintenance,
    pi.prd_cost AS product_cost,
    pi.prd_line AS production_line,
    pi.prd_start_dt AS start_date
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pcg
    ON pi.cat_id::text = pcg.id::text
WHERE pi.prd_end_dt IS NULL;

------------------- DIMENSION: Customers -------------------

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
    row_number() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr <> 'n/a'::bpchar THEN ci.cst_gndr::character varying
        ELSE COALESCE(ca.gen, 'n/a'::character varying)
    END AS gender,
    ca.bdate AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key::text = ca.cid::text
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key::text = la.cid::text;

------------------- FACT: Sales -------------------

CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
    csd.sls_ord_num AS order_number,
    pr.product_key,
    cst.customer_key,
    csd.sls_order_dt AS order_date,
    csd.sls_ship_dt AS shipping_date,
    csd.sls_due_dt AS due_date,
    csd.sls_sales AS sales_amount,
    csd.sls_quantity AS quantity,
    csd.sls_price AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_product pr
    ON csd.sls_prd_key::text = pr.product_number::text
LEFT JOIN gold.dim_customers cst
    ON csd.sls_cust_id = cst.customer_id;

/* ============================================================
   How to Use:
   ------------
   Once this script is executed, the following views are available:
   - gold.dim_product       : Product dimension
   - gold.dim_customers     : Customer dimension
   - gold.fact_sales        : Sales fact table

   Example query:
   SELECT *
   FROM gold.fact_sales
   WHERE order_date >= '2025-01-01';
   ============================================================ */
