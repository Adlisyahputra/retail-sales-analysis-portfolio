#!/usr/bin/env python3
"""
Data Analysis Dashboard Generator
Processes sales data and creates visualizations
"""

import sqlite3
import pandas as pd
import json
from datetime import datetime

# Create SQLite database and load data
def create_database():
    conn = sqlite3.connect('/home/claude/sales_analysis.db')
    
    # Read CSV data
    df = pd.read_csv('/home/claude/raw_sales_data.csv')
    
    # Save raw data
    df.to_sql('raw_sales', conn, if_exists='replace', index=False)
    
    return conn

def clean_data(conn):
    """Clean the raw sales data"""
    
    cleaning_sql = """
    CREATE TABLE IF NOT EXISTS cleaned_sales AS
    SELECT 
        order_id,
        customer_id,
        CASE 
            WHEN customer_name = 'NULL' OR customer_name IS NULL 
            THEN 'Unknown Customer'
            ELSE TRIM(customer_name)
        END as customer_name,
        TRIM(product_name) as product_name,
        CASE 
            WHEN LOWER(category) = 'electronics' THEN 'Electronics'
            WHEN LOWER(category) = 'furniture' THEN 'Furniture'
            WHEN LOWER(category) = 'stationery' THEN 'Stationery'
            WHEN LOWER(category) = 'office' THEN 'Office'
            ELSE category
        END as category,
        ABS(quantity) as quantity,
        price,
        CASE 
            WHEN order_date LIKE '%invalid%' THEN NULL
            ELSE order_date
        END as order_date,
        CASE 
            WHEN ship_date IS NULL OR ship_date = '' THEN NULL
            ELSE ship_date
        END as ship_date,
        region,
        payment_method,
        ROUND(ABS(quantity) * price, 2) as total_amount
    FROM raw_sales;
    """
    
    conn.execute("DROP TABLE IF EXISTS cleaned_sales")
    conn.execute(cleaning_sql)
    conn.commit()
    
    print("✓ Data cleaning completed!")

def generate_analytics(conn):
    """Generate analytics from cleaned data"""
    
    # Category Performance
    category_df = pd.read_sql_query("""
        SELECT 
            category,
            COUNT(*) as total_orders,
            SUM(quantity) as total_units_sold,
            ROUND(SUM(total_amount), 2) as total_revenue,
            ROUND(AVG(total_amount), 2) as avg_order_value
        FROM cleaned_sales
        GROUP BY category
        ORDER BY total_revenue DESC
    """, conn)
    
    # Regional Performance
    regional_df = pd.read_sql_query("""
        SELECT 
            region,
            COUNT(*) as total_orders,
            ROUND(SUM(total_amount), 2) as total_revenue,
            COUNT(DISTINCT customer_id) as unique_customers
        FROM cleaned_sales
        GROUP BY region
        ORDER BY total_revenue DESC
    """, conn)
    
    # Daily Sales
    daily_df = pd.read_sql_query("""
        SELECT 
            order_date,
            COUNT(*) as orders,
            ROUND(SUM(total_amount), 2) as revenue
        FROM cleaned_sales
        WHERE order_date IS NOT NULL
        GROUP BY order_date
        ORDER BY order_date
    """, conn)
    
    # Top Products
    product_df = pd.read_sql_query("""
        SELECT 
            product_name,
            category,
            SUM(quantity) as units_sold,
            ROUND(SUM(total_amount), 2) as revenue
        FROM cleaned_sales
        GROUP BY product_name, category
        ORDER BY revenue DESC
        LIMIT 10
    """, conn)
    
    # Summary Metrics
    summary = pd.read_sql_query("""
        SELECT 
            ROUND(SUM(total_amount), 2) as total_revenue,
            COUNT(*) as total_orders,
            COUNT(DISTINCT customer_id) as total_customers,
            ROUND(AVG(total_amount), 2) as avg_order_value
        FROM cleaned_sales
    """, conn).iloc[0]
    
    return {
        'category': category_df,
        'regional': regional_df,
        'daily': daily_df,
        'product': product_df,
        'summary': summary
    }

def export_to_json(analytics):
    """Export analytics to JSON for dashboard"""
    
    data = {
        'summary': {
            'total_revenue': float(analytics['summary']['total_revenue']),
            'total_orders': int(analytics['summary']['total_orders']),
            'total_customers': int(analytics['summary']['total_customers']),
            'avg_order_value': float(analytics['summary']['avg_order_value'])
        },
        'category': analytics['category'].to_dict('records'),
        'regional': analytics['regional'].to_dict('records'),
        'daily': analytics['daily'].to_dict('records'),
        'product': analytics['product'].to_dict('records')
    }
    
    with open('/home/claude/dashboard_data.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print("✓ Analytics exported to JSON!")
    return data

if __name__ == "__main__":
    print("Starting Data Analysis Pipeline...")
    print("=" * 50)
    
    # Create database
    print("\n1. Creating database...")
    conn = create_database()
    print("✓ Database created!")
    
    # Clean data
    print("\n2. Cleaning data...")
    clean_data(conn)
    
    # Generate analytics
    print("\n3. Generating analytics...")
    analytics = generate_analytics(conn)
    
    # Export to JSON
    print("\n4. Exporting data...")
    data = export_to_json(analytics)
    
    # Print summary
    print("\n" + "=" * 50)
    print("DATA ANALYSIS SUMMARY")
    print("=" * 50)
    print(f"Total Revenue: ${data['summary']['total_revenue']:,.2f}")
    print(f"Total Orders: {data['summary']['total_orders']}")
    print(f"Total Customers: {data['summary']['total_customers']}")
    print(f"Average Order Value: ${data['summary']['avg_order_value']:,.2f}")
    print("\nTop Category by Revenue:")
    print(f"  {analytics['category'].iloc[0]['category']}: ${analytics['category'].iloc[0]['total_revenue']:,.2f}")
    print("\n✓ Analysis complete!")
    
    conn.close()
