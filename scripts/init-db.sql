


-- Drop the database if it exists
DO
$$
BEGIN
   IF EXISTS (SELECT FROM pg_database WHERE datname = 'my_database') THEN
      EXECUTE 'DROP DATABASE my_database';
   END IF;
END
$$ LANGUAGE plpgsql;

-- Create 'Datawarehouse' Database
CREATE DATABASE DataWarehouse;

\connect DataWarehouse


CREATE SCHEMA BRONZE;

CREATE SCHEMA SILVER;

CREATE SCHEMA GOLD;
