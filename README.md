# 🛒 ShopKart — E-Commerce Data Warehouse & Customer Analytics

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---
## 📖 Project Overview

ShopKart is a fictional growing e-commerce startup operating across India. The company sells products across categories such as Electronics, Fashion, Home & Kitchen, Beauty & Personal Care, Sports & Fitness, Books, and Mobile Accessories.

As ShopKart grows, its data is becoming distributed across multiple operational systems. Business teams currently struggle to answer important questions about sales, customers, products, profitability, returns, payments, promotions, and customer retention.

The objective of this project is to build a complete SQL-based Data Warehouse and Business Intelligence solution that integrates data from multiple source systems, cleans and transforms the data through an ETL pipeline, creates an analytical data model, performs RFM Customer Segmentation, and presents business insights through Power BI dashboards.

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.
   
---
# 🎯 Business Problem

ShopKart's management wants to understand:

* Which products and categories are driving sales?
* Which regions are performing best?
* Who are the most valuable customers?
* Which customers are loyal?
* Which customers are at risk of disappearing?
* Why are customers returning products?
* Which promotions are actually effective?
* Which payment methods perform best?
* How profitable are the company's sales?
* Are orders being delivered on time?

The existing source systems store this information separately, making cross-functional analysis difficult.

A centralized analytical data warehouse is therefore required.

---

# 🏢 Source Systems

The project integrates data from **5 operational source systems**.

| Source System                    | Source Tables                          |
| -------------------------------- | -------------------------------------- |
| Customer Relationship Management | Customers                              |
| Enterprise Resource Planning     | Products, Orders, Order_Items, Regions |
| Payment Gateway                  | Payments                               |
| Returns Management System        | Returns                                |
| Marketing System                 | Promotions                             |

### Source Architecture

CRM
 └── Customers

ERP
 ├── Products
 ├── Orders
 ├── Order_Items
 └── Regions

PG
 └── Payments

RMS
 └── Returns

MKT
 └── Promotions

---

## 🏗️ Data Architecture

<img width="1203" height="685" alt="image" src="https://github.com/user-attachments/assets/cf59e9d5-fc4e-44a1-b7ea-055ab76a8a81" />

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

# 🥉 Bronze Layer

The Bronze layer stores data as received from the source systems.

The objective is to preserve the original source data while maintaining source lineage.

Typical characteristics include:

* Raw source values
* VARCHAR-based ingestion
* Original date formats
* Original numeric formats
* Duplicate records
* Missing values
* Inconsistent capitalization
* Invalid values
* Referential-integrity issues
* Business-rule violations

No major business transformation is performed at this stage.

---

# 🥈 Silver Layer

The Silver layer contains cleaned, standardized, and validated data.

Typical transformations include:

* Data type conversion
* Date standardization
* Numeric conversion
* Text standardization
* NULL handling
* Duplicate handling
* Boolean normalization
* Invalid-record detection
* Referential-integrity validation
* Business-rule validation

Records that fail critical validation rules can be separated into a **quarantine/error area** instead of being loaded into the clean Silver dataset. 

---

# 🥇 Gold Layer

The Gold layer is designed for analytical consumption.

The cleaned Silver data is transformed into a business-friendly dimensional model containing:

* Fact tables
* Dimension tables
* Date dimension
* Customer analytics
* Product analytics
* Sales metrics
* Return metrics
* Payment metrics
* Promotion metrics
* RFM segmentation

Calculated KPIs are derived in the analytical layer rather than being stored as raw source attributes.

---

# 📊 Core Business KPIs

## Sales

* Total Revenue
* Gross Sales
* Net Sales
* Total Orders
* Units Sold
* Average Order Value
* Revenue Growth
* Order Growth
* Customer Growth

## Profitability

* COGS
* Gross Profit
* Gross Margin %
* Discount Amount
* Discount %

## Customer

* Total Customers
* New Customers
* Active Customers
* Repeat Customers
* One-Time Customers
* Customer Revenue
* Average Customer Value

## RFM

* Recency
* Frequency
* Monetary
* RFM Score
* RFM Segment

Segments include:

* Champions
* Loyal Customers
* Potential Loyalists
* New Customers
* Promising Customers
* At-Risk Customers
* Hibernating Customers
* Lost Customers

## Returns

* Return Rate
* Returned Units
* Refund Amount
* Returns by Category
* Returns by Product
* Return Reasons

## Payments

* Payment Success Rate
* Payment Failure Rate
* Payment Method Mix
* Payment Volume
* Refund Amount

## Promotions

* Promotion Revenue
* Promotion Orders
* Promotion Discount
* Marketing Spend
* ROAS

## Operations

* Delivery Delay
* On-Time Delivery Rate
* Delivery Performance by Region
* Delivery Performance by Shipping Method

---

# 📈 Power BI Dashboards

The analytical model supports four major Power BI dashboards.

### 1. Executive Sales Dashboard

Provides management with a high-level view of:

* Revenue
* Orders
* Customers
* Units Sold
* AOV
* Growth
* Profitability
* Returns
* Cancellations

### 2. Sales & Product Dashboard

Focuses on:

* Category performance
* Subcategory performance
* Product performance
* Regional sales
* Discounts
* Profitability
* Top and bottom products

### 3. Customer & RFM Dashboard

Focuses on:

* Customer growth
* Customer value
* Repeat purchasing
* Customer acquisition
* RFM scores
* Customer segments
* At-risk customers
* Loyal customers
* Champions

### 4. Finance & Operations Dashboard

Focuses on:

* Revenue
* COGS
* Gross Profit
* Gross Margin
* Refunds
* Returns
* Payments
* Promotions
* Delivery performance

---

# 🧠 RFM Customer Segmentation

One of the key analytical components of this project is **RFM analysis**.

RFM evaluates customers using three dimensions:

### Recency

How recently did the customer make a purchase?

### Frequency

How frequently does the customer purchase?

### Monetary

How much revenue does the customer generate?

The three metrics are converted into scores and combined to classify customers into meaningful business segments.

For example:

```text
Customer Transactions
        ↓
Recency
Frequency
Monetary
        ↓
RFM Scoring
        ↓
Customer Segmentation
        ↓
Champions / Loyal / At-Risk / Lost / etc.
```

RFM values are **derived during the analytical transformation** and are not stored in the raw source systems.

---

# 🧹 Data Quality

The raw dataset intentionally contains realistic data-quality issues commonly found in production environments.

Examples include:

* NULL values
* Duplicate records
* Invalid dates
* Multiple date formats
* Currency symbols inside numeric fields
* Inconsistent capitalization
* Leading/trailing spaces
* Invalid numeric values
* Invalid foreign-key references
* Duplicate transactions
* Incorrect order totals
* Invalid return quantities
* Payment inconsistencies
* Invalid promotion date ranges

The objective is not simply to clean the data, but to demonstrate how a data professional identifies, validates, transforms, and manages poor-quality source data.

---

# 🛠️ Technology Stack

| Technology       | Purpose                                       |
| ---------------- | --------------------------------------------- |
| **SQL Server**   | Data warehouse and ETL                        |
| **SQL**          | Data transformation, validation and analytics |
| **Power BI**     | Business intelligence and dashboards          |
| **DAX**          | Power BI measures and calculations            |
| **Excel / CSV**  | Source data and initial inspection            |
| **Git / GitHub** | Version control and project documentation     |

---

# 📁 Project Structure

```text
ShopKart/
│
├── README.md
│
├── data/
│   ├── raw/
│   └── sample/
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── transformations/
│   ├── validations/
│   └── stored_procedures/
│
├── documentation/
│   ├── business_requirements/
│   ├── data_dictionary/
│   ├── data_model/
│   └── data_quality/
│
├── powerbi/
│   └── ShopKart_Dashboard.pbix
│
└── screenshots/
```

---

# 🎯 Project Objective

The final solution demonstrates how a Data Analyst / Analytics Engineer can transform fragmented operational data into a centralized analytical platform.

The project combines:

**Data Engineering**

→ Source ingestion

→ Data profiling

→ ETL

→ Data quality

→ Data warehousing

**Data Analytics**

→ SQL analytics

→ KPI development

→ RFM segmentation

→ Customer analysis

**Business Intelligence**

→ Power BI dashboards

→ Interactive reporting

→ Business insights

The final objective is to enable ShopKart's stakeholders to make **data-driven decisions around sales, customers, products, profitability, marketing, returns, payments, and retention.**

---
