# sql-DWH-project: Sales Data Warehouse and Analytics Solution 🚀

This repository demonstrates a comprehensive **Data Warehouse and Analytics Solution** built using industry best practices. Designed as a portfolio project, it covers the entire data journey from integrating multiple source systems to generating actionable, SQL-based business insights.

---

## 🚀 Project Requirements and Objectives

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern dimensional data warehouse using **PostgreSQL** to consolidate sales data, enabling robust analytical reporting and informed decision-making.

#### Specifications
* **Data Sources**: Import and unify data from two distinct source systems: **ERP** and **CRM** (provided as CSV files).
* **Data Quality**: Implement specific cleansing and validation steps to resolve data quality issues prior to analysis.
* **Integration**: Combine both sources into a single, user-friendly **dimensional data model** designed for high-performance analytical queries.
* **Scope**: Focus on the latest dataset only; historization of data (Type 2 SCDs) is not required for this iteration.
* **Documentation**: Provide clear documentation of the data model and architecture to support both business stakeholders and analytics teams.

#### 🛠️ Core Tools
| Category | Tool | Purpose |
| :--- | :--- | :--- |
| **Data Warehouse** | 🐘 **PostgreSQL** | Primary DWH platform for schema and data storage. |
| **Visualization** | 🎨 **Draw.io** | Architecture and dimensional data model diagrams. |
| **Management** | 📝 **Notion** | Project documentation, task tracking, and design notes. |
| **Containerization**| 🐳 **Docker** | *(Future Enhancement: For environment reproducibility)* |

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop and execute complex SQL-based analytics to deliver detailed, mission-critical insights across key business areas.

#### Key Insight Areas
* **Customer Behavior** (e.g., top customers, purchasing frequency).
* **Product Performance** (e.g., highest revenue items, product category analysis).
* **Sales Trends** (e.g., Month-over-Month/Year-over-Year comparison, geographical analysis).

These insights are structured to empower stakeholders with key business metrics, enabling strategic decision-making.

---

## 📂 Repository Structure

The project follows a standard data engineering structure for clarity and maintainability:

| Folder | Content |
| :--- | :--- |
| **`datasets`** | Raw source data files (ERP and CRM CSVs). |
| **`scripts`** | Ordered SQL files for the ETL/ELT process: DDL, Staging, Data Quality, and Dimensional Loading. |
| **`docs`** | Documentation files, including design notes and detailed data dictionaries. |
| **`assets`** | **NEW!** Placeholder for embedded images (e.g., schemas, dashboards). |
| **`tests`** | Data validation or quality assurance scripts. |

---

## 🖼️ Project Visuals (Architecture & Schema)

### Data Warehouse Architecture

```markdown
![Architecture Diagram: Source Systems to PostgreSQL DWH](docs/dwh_architecture.png)
