# Pizza Runner MySQL Analysis

This repository contains a **MySQL script** to clean, transform, and analyze the Pizza Runner dataset. It provides insights into customer orders, runner performance, and pizza metrics.

## Features
- Data cleaning and transformation for:
  - `customer_orders`
  - `runner_orders`
  - `pizza_recipes`
- Handles NULL and empty values for better analysis.
- Aggregates data to answer business questions such as:
  - Total pizzas ordered
  - Unique customer orders
  - Successful orders per runner
  - Most popular pizzas
  - Pizzas with customizations (exclusions/extras)
  - Hourly and weekly order trends
  - Average pickup time per runner
- Creates a view for easier reporting (`customer_orders_summary`).

## Skills Used
- SQL Aggregations (`COUNT`, `SUM`, `MAX`, `AVG`)
- Joins and Subqueries
- Data Cleaning (`UPDATE`, `NULL` handling)
- Views for reporting
- Date and Time functions (`DATE_FORMAT`, `DAYOFWEEK`, `WEEK`, `TIME_TO_SEC`)

## Usage
1. Clone or download the repository.
2. Open `pizza_runner.sql` in MySQL Workbench or any MySQL client.
3. Run the script to create cleaned tables and generate the business metrics.
4. Use the `customer_orders_summary` view for quick reporting and visualization.

## Notes
- This script is **compatible with traditional MySQL** (5.x and 8.x).  
- Comma-separated fields (`exclusions`, `extras`, `toppings`) are stored as-is.  

---
