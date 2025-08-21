-------------------------------------------------------------------------------
-- Script: init-db.sql
-- Purpose: Initialize PostgreSQL database for Data Warehouse project
-- Author: Zakaria
-- Date: 2025-08-21
--
-- WARNING:
-- 1. This script will DROP the database 'DataWarehouse' if it exists. 
--    **All existing data in this database will be permanently lost.**
-- 2. It is strongly recommended to take a full backup of 'DataWarehouse' 
--    before executing this script.
-- 3. After dropping, it will create a new database 'DataWarehouse'.
-- 4. The script then creates three schemas: BRONZE, SILVER, GOLD.
-- 5. \connect works only in psql (terminal), not in pgAdmin Query Tool.
-------------------------------------------------------------------------------



-- Drop the database if it exists
DO
$$
BEGIN
   IF EXISTS (SELECT FROM pg_database WHERE datname = 'my_database') THEN
      EXECUTE 'DROP DATABASE DataWarehouse';
   END IF;
END
$$ LANGUAGE plpgsql;

-- Create 'Datawarehouse' Database
CREATE DATABASE DataWarehouse;

\connect DataWarehouse


CREATE SCHEMA BRONZE;

CREATE SCHEMA SILVER;

CREATE SCHEMA GOLD;
