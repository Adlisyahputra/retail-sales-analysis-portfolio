-- ============================================
-- DATA CLEANING PROJECT - RETAIL SALES ANALYSIS
-- Author: Your Name
-- Date: February 2026
-- ============================================

-- STEP 1: CREATE DATABASE AND LOAD RAW DATA
-- ============================================

-- Create database (SQLite/PostgreSQL/MySQL compatible)
CREATE TABLE IF NOT EXISTS raw_sales (
    order_id INTEGER,
    customer_id TEXT,
    customer_name TEXT,
    product_name TEXT,
    category TEXT,
    quantity INTEGER,
    price DECIMAL(10,2),
    order_date TEXT,
    ship_date TEXT,
    region TEXT,
    payment_method TEXT
);

-- Load data from CSV (syntax varies by database)
-- SQLite: .import raw_sales_data.csv raw_sales
-- PostgreSQL: COPY raw_sales FROM '/path/to/raw_sales_data.csv' DELIMITER ',' CSV HEADER;
-- MySQL: LOAD DATA INFILE '/path/to/raw_sales_data.csv' INTO TABLE raw_sales FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- ============================================
-- STEP 2: DATA QUALITY ASSESSMENT
-- ============================================

-- Check total records
SELECT COUNT(*) as total_records FROM raw_sales;

-- Check for NULL values in critical columns
SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN customer_name IS NULL OR customer_name = 'NULL' THEN 1 ELSE 0 END) as null_customer_names,
    SUM(CASE WHEN ship_date IS NULL OR ship_date = '' THEN 1 ELSE 0 END) as null_ship_dates,
    SUM(CASE WHEN quantity < 0 THEN 1 ELSE 0 END) as negative_quantities,
    SUM(CASE WHEN order_date LIKE '%invalid%' THEN 1 ELSE 0 END) as invalid_dates
FROM raw_sales;

-- Check for duplicate orders
SELECT order_id, COUNT(*) as occurrence_count
FROM raw_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check for inconsistent category naming
SELECT DISTINCT category, COUNT(*) as count
FROM raw_sales
GROUP BY category
ORDER BY category;

-- Check for whitespace issues
SELECT order_id, customer_name, product_name, category
FROM raw_sales
WHERE customer_name LIKE ' %' 
   OR customer_name LIKE '% '
   OR product_name LIKE ' %'
   OR product_name LIKE '% ';

-- ============================================
-- STEP 3: DATA CLEANING
-- ============================================

-- Create cleaned table
CREATE TABLE IF NOT EXISTS cleaned_sales AS
SELECT 
    order_id,
    customer_id,
    -- Clean customer names: remove NULL strings, trim whitespace
    CASE 
        WHEN customer_name = 'NULL' OR customer_name IS NULL 
        THEN 'Unknown Customer'
        ELSE TRIM(customer_name)
    END as customer_name,
    -- Clean product names: trim whitespace
    TRIM(product_name) as product_name,
    -- Standardize category names: proper case
    CASE 
        WHEN LOWER(category) = 'electronics' THEN 'Electronics'
        WHEN LOWER(category) = 'furniture' THEN 'Furniture'
        WHEN LOWER(category) = 'stationery' THEN 'Stationery'
        WHEN LOWER(category) = 'office' THEN 'Office'
        ELSE INITCAP(category)
    END as category,
    -- Fix negative quantities (assume data entry error)
    ABS(quantity) as quantity,
    price,
    -- Handle invalid dates
    CASE 
        WHEN order_date LIKE '%invalid%' THEN NULL
        ELSE order_date
    END as order_date,
    -- Fill missing ship dates (NULL or empty)
    CASE 
        WHEN ship_date IS NULL OR ship_date = '' THEN NULL
        ELSE ship_date
    END as ship_date,
    region,
    payment_method,
    -- Add calculated fields
    ROUND(quantity * price, 2) as total_amount
FROM raw_sales;

-- ============================================
-- STEP 4: DATA VALIDATION
-- ============================================

-- Verify cleaning results
SELECT 
    COUNT(*) as total_cleaned_records,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_name) as unique_products,
    SUM(CASE WHEN customer_name = 'Unknown Customer' THEN 1 ELSE 0 END) as unknown_customers,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) as missing_ship_dates
FROM cleaned_sales;

-- Check category standardization
SELECT category, COUNT(*) as product_count
FROM cleaned_sales
GROUP BY category
ORDER BY product_count DESC;

-- ============================================
-- STEP 5: ANALYTICAL QUERIES
-- ============================================

-- 1. Sales Performance by Category
SELECT 
    category,
    COUNT(*) as total_orders,
    SUM(quantity) as total_units_sold,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM cleaned_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- 2. Top 10 Customers by Revenue
SELECT 
    customer_name,
    customer_id,
    COUNT(*) as total_orders,
    SUM(quantity) as total_items,
    ROUND(SUM(total_amount), 2) as total_spent
FROM cleaned_sales
GROUP BY customer_name, customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Sales Trends by Date
SELECT 
    order_date,
    COUNT(*) as orders,
    SUM(quantity) as units_sold,
    ROUND(SUM(total_amount), 2) as daily_revenue
FROM cleaned_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;

-- 4. Regional Performance
SELECT 
    region,
    COUNT(*) as total_orders,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM cleaned_sales
GROUP BY region
ORDER BY total_revenue DESC;

-- 5. Payment Method Analysis
SELECT 
    payment_method,
    COUNT(*) as transaction_count,
    ROUND(SUM(total_amount), 2) as total_value,
    ROUND(AVG(total_amount), 2) as avg_transaction_value
FROM cleaned_sales
GROUP BY payment_method
ORDER BY total_value DESC;

-- 6. Product Performance
SELECT 
    product_name,
    category,
    SUM(quantity) as units_sold,
    ROUND(SUM(total_amount), 2) as revenue,
    COUNT(*) as times_ordered
FROM cleaned_sales
GROUP BY product_name, category
ORDER BY revenue DESC
LIMIT 10;

-- 7. Shipping Performance (Average days to ship)
SELECT 
    category,
    COUNT(*) as orders_with_ship_date,
    ROUND(AVG(JULIANDAY(ship_date) - JULIANDAY(order_date)), 1) as avg_days_to_ship
FROM cleaned_sales
WHERE ship_date IS NOT NULL AND order_date IS NOT NULL
GROUP BY category
ORDER BY avg_days_to_ship;

-- ============================================
-- STEP 6: CREATE SUMMARY VIEWS FOR DASHBOARD
-- ============================================

-- View: Daily Sales Summary
CREATE VIEW IF NOT EXISTS vw_daily_sales AS
SELECT 
    order_date,
    COUNT(*) as total_orders,
    SUM(quantity) as total_units,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM cleaned_sales
WHERE order_date IS NOT NULL
GROUP BY order_date;

-- View: Category Performance
CREATE VIEW IF NOT EXISTS vw_category_performance AS
SELECT 
    category,
    COUNT(*) as order_count,
    SUM(quantity) as units_sold,
    ROUND(SUM(total_amount), 2) as revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value,
    ROUND(SUM(total_amount) * 100.0 / (SELECT SUM(total_amount) FROM cleaned_sales), 2) as revenue_percentage
FROM cleaned_sales
GROUP BY category;

-- View: Regional Performance
CREATE VIEW IF NOT EXISTS vw_regional_performance AS
SELECT 
    region,
    COUNT(*) as orders,
    ROUND(SUM(total_amount), 2) as revenue,
    COUNT(DISTINCT customer_id) as customers
FROM cleaned_sales
GROUP BY region;

-- View: Customer Insights
CREATE VIEW IF NOT EXISTS vw_customer_insights AS
SELECT 
    customer_id,
    customer_name,
    COUNT(*) as total_orders,
    SUM(quantity) as total_items_purchased,
    ROUND(SUM(total_amount), 2) as lifetime_value,
    ROUND(AVG(total_amount), 2) as avg_order_value,
    MIN(order_date) as first_purchase_date,
    MAX(order_date) as last_purchase_date
FROM cleaned_sales
WHERE customer_name != 'Unknown Customer'
GROUP BY customer_id, customer_name;

-- ============================================
-- STEP 7: EXPORT RESULTS FOR DASHBOARD
-- ============================================

-- Export summary metrics
SELECT 
    'Total Revenue' as metric,
    ROUND(SUM(total_amount), 2) as value
FROM cleaned_sales
UNION ALL
SELECT 
    'Total Orders' as metric,
    COUNT(*) as value
FROM cleaned_sales
UNION ALL
SELECT 
    'Total Customers' as metric,
    COUNT(DISTINCT customer_id) as value
FROM cleaned_sales
UNION ALL
SELECT 
    'Average Order Value' as metric,
    ROUND(AVG(total_amount), 2) as value
FROM cleaned_sales;

-- ============================================
-- END OF DATA CLEANING SCRIPT
-- ============================================
