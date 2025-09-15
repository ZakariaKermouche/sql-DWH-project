# 📂 Gold Layer – Data Dictionary

The **Gold Layer** contains curated, analytics-ready views for reporting and BI.  
It integrates and enriches data from **Silver Layer** sources.

---

## 🟦 `gold.dim_product`

**Description:** Product dimension containing product, category, and cost details.  
**Grain:** One row per active product (latest valid product without end date).

| Column Name      | Type        | Description                                                                 |
|------------------|------------|-----------------------------------------------------------------------------|
| `product_key`    | INTEGER     | Surrogate key for the product (sequentially generated).                     |
| `product_id`     | INTEGER     | Business identifier of the product (from CRM source).                       |
| `category_id`    | VARCHAR(20)| Derived category identifier from `prd_key`.                                 |
| `product_number` | VARCHAR(20)| Original product key/code from CRM.                                         |
| `product_name`   | VARCHAR(50)| Name of the product.                                                        |
| `category`       | VARCHAR(100)| Product category from ERP catalog.                                          |
| `subcategory`    | VARCHAR(100)| Product subcategory from ERP catalog.                                       |
| `maintenance`    | CHAR(3)     | Indicates if product requires maintenance (`Yes` / `No`).                   |
| `product_cost`   | INTEGER     | Product cost value.                                                         |
| `production_line`| VARCHAR(20)| Standardized product line (Small, Medium, Ride, Train, n/a).                |
| `start_date`     | DATE        | Start date of product validity (latest record).                              |

---

## 🟦 `gold.dim_customers`

**Description:** Customer dimension with demographic and location details.  
**Grain:** One row per unique customer.

| Column Name      | Type        | Description                                                                 |
|------------------|------------|-----------------------------------------------------------------------------|
| `customer_key`   | INTEGER     | Surrogate key for the customer (sequentially generated).                    |
| `customer_id`    | INTEGER     | Business identifier of the customer (from CRM).                             |
| `customer_number`| VARCHAR(20)| External customer key (from CRM).                                           |
| `first_name`     | VARCHAR(50)| Customer’s first name.                                                      |
| `last_name`      | VARCHAR(50)| Customer’s last name.                                                       |
| `country`        | VARCHAR(100)| Customer’s country (mapped from ERP location data).                         |
| `marital_status` | CHAR(10)    | Standardized marital status (`Single`, `Married`, or `n/a`).                |
| `gender`         | VARCHAR(10)| Standardized gender (from CRM if available, otherwise ERP).                 |
| `birth_date`     | DATE        | Customer’s birth date (from ERP, validated).                                |
| `create_date`    | DATE        | Date when customer record was created in CRM.                               |

---

## 🟦 `gold.fact_sales`

**Description:** Fact table capturing customer sales transactions.  
**Grain:** One row per sales order line.

| Column Name      | Type        | Description                                                                 |
|------------------|------------|-----------------------------------------------------------------------------|
| `order_number`   | VARCHAR(20)| Unique sales order identifier.                                              |
| `product_key`    | INTEGER     | Foreign key referencing `gold.dim_product.product_key`.                      |
| `customer_key`   | INTEGER     | Foreign key referencing `gold.dim_customers.customer_key`.                   |
| `order_date`     | DATE        | Date when the order was placed.                                             |
| `shipping_date`  | DATE        | Date when the order was shipped.                                            |
| `due_date`       | DATE        | Expected delivery due date.                                                 |
| `sales_amount`   | INTEGER     | Total sales amount (validated against quantity × price).                    |
| `quantity`       | INTEGER     | Quantity of items ordered.                                                  |
| `price`          | INTEGER     | Price per unit of product (standardized to non-negative).                   |
