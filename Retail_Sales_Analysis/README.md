# 📊 Data Analysis Portfolio: Retail Sales Analysis

## 🚀 Quick Links
**[📊 View Live Interactive Dashboard →](https://adlisyahputra.github.io/retail-sales-analysis-portfolio/Retail_Sales_Analysis/dashboard.html)**

**[📝 Detailed Data Cleaning Report →](DATA_CLEANING_REPORT.md)**

---

## 🎯 Project Overview
This portfolio project demonstrates comprehensive data analysis skills including data cleaning, SQL analysis, and interactive dashboard creation. The project analyzes retail sales data to uncover business insights and present them through an interactive dashboard.

## 📁 Project Structure
```
retail-sales-analysis-portofolio/
├── raw_sales_data.csv              # Raw dataset with quality issues
├── data_cleaning_analysis.sql      # Complete SQL cleaning & analysis script
├── process_data.py                 # Python data processing pipeline
├── dashboard.html                  # Interactive web dashboard
├── sales_analysis.db              # SQLite database (generated)
├── DATA_CLEANING_REPORT.md        # Detailed cleaning documentation
└── README.md                       # Project documentation
```

## 🔍 Problem Statement
The raw sales data contains several quality issues that need to be addressed:
- **NULL values** in customer names
- **Inconsistent formatting** (whitespace, case sensitivity)
- **Missing ship dates**
- **Invalid dates** (data entry errors)
- **Negative quantities** (data anomalies)
- **Inconsistent category naming** (electronics vs Electronics)

## 🛠️ Data Cleaning Process

### Issues Identified
1. **Missing Values**: 3 customer names marked as 'NULL'
2. **Whitespace Issues**: Leading/trailing spaces in product and customer names
3. **Inconsistent Categorization**: Mixed case in category names
4. **Data Anomalies**: Negative quantities, invalid dates
5. **Missing Ship Dates**: 4 records without shipping information

### Cleaning Steps
```sql
-- 1. Standardize NULL values
CASE 
    WHEN customer_name = 'NULL' OR customer_name IS NULL 
    THEN 'Unknown Customer'
    ELSE TRIM(customer_name)
END as customer_name

-- 2. Remove whitespace
TRIM(product_name) as product_name

-- 3. Standardize categories
CASE 
    WHEN LOWER(category) = 'electronics' THEN 'Electronics'
    WHEN LOWER(category) = 'furniture' THEN 'Furniture'
    -- ... other categories
END as category

-- 4. Fix negative quantities
ABS(quantity) as quantity

-- 5. Handle invalid dates
CASE 
    WHEN order_date LIKE '%invalid%' THEN NULL
    ELSE order_date
END as order_date
```

## 📈 Key Findings

### Summary Metrics
- **Total Revenue**: $7,725.00
- **Total Orders**: 25
- **Unique Customers**: 21
- **Average Order Value**: $309.00

### Category Performance
| Category     | Orders | Revenue    | % of Total |
|-------------|--------|------------|------------|
| Electronics | 13     | $5,528.50  | 71.6%      |
| Furniture   | 5      | $1,350.00  | 17.5%      |
| Stationery  | 6      | $69.50     | 0.9%       |
| Office      | 1      | $120.00    | 1.6%       |

### Regional Performance
| Region | Orders | Revenue    | Customers |
|--------|--------|------------|-----------|
| East   | 7      | $2,142.50  | 7         |
| North  | 6      | $1,995.00  | 4         |
| West   | 7      | $1,883.50  | 7         |
| South  | 5      | $1,047.00  | 5         |

### Top Products
1. **Laptop** - $3,600.00 (3 units)
2. **Monitor** - $1,050.00 (3 units)
3. **Desk Chair** - $750.00 (3 units)

## 🔧 Technical Skills Demonstrated

### SQL Skills
- ✅ Data Quality Assessment
- ✅ Data Cleaning & Transformation
- ✅ Aggregate Functions (SUM, AVG, COUNT)
- ✅ CASE Statements
- ✅ GROUP BY & Ordering
- ✅ Window Functions
- ✅ View Creation
- ✅ Subqueries

### Python Skills
- ✅ Database Operations (SQLite)
- ✅ Data Processing with Pandas
- ✅ JSON Export
- ✅ Automation Scripts

### Data Visualization
- ✅ Interactive Dashboard Creation
- ✅ Chart.js Integration
- ✅ Responsive Web Design
- ✅ KPI Metric Cards
- ✅ Multiple Chart Types (Bar, Line, Pie, Doughnut)

## 🚀 How to Use

### Prerequisites
- Python 3.x
- SQLite (built-in with Python)
- pandas library
- Web browser (for dashboard)

### Installation
```bash
# Install required packages
pip install pandas

# Run the analysis pipeline
python3 process_data.py
```

### View Dashboard
**Option 1:** [View Live Dashboard Online](https://adlisyahputra.github.io/retail-sales-analysis-portofolio/dashboard.html) ⭐ Recommended

**Option 2:** Download `dashboard.html` and open in any modern web browser

## 📊 SQL Queries Examples

### Category Sales Analysis
```sql
SELECT 
    category,
    COUNT(*) as total_orders,
    SUM(quantity) as total_units_sold,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM cleaned_sales
GROUP BY category
ORDER BY total_revenue DESC;
```

### Customer Lifetime Value
```sql
SELECT 
    customer_id,
    customer_name,
    COUNT(*) as total_orders,
    ROUND(SUM(total_amount), 2) as lifetime_value,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM cleaned_sales
WHERE customer_name != 'Unknown Customer'
GROUP BY customer_id, customer_name
ORDER BY lifetime_value DESC;
```

## 📌 Business Insights

1. **Electronics Dominance**: Electronics category drives 71.6% of total revenue, indicating strong demand for tech products.

2. **Regional Balance**: Revenue is fairly distributed across regions, with East region slightly leading.

3. **High-Value Items**: Laptops and monitors are top revenue generators, suggesting focus on premium products.

4. **Customer Retention**: John Doe (C001) appears 4 times, indicating repeat customer behavior worth nurturing.

5. **Payment Preferences**: Credit cards are the most popular payment method, important for payment processing optimization.

## 🎓 Learning Outcomes
- Data cleaning best practices in SQL
- Handling real-world messy data
- Creating meaningful business metrics
- Building interactive dashboards
- Data storytelling and visualization
- End-to-end data analysis pipeline

## 📝 Future Enhancements
- [ ] Add customer segmentation analysis (RFM)
- [ ] Implement predictive analytics for sales forecasting
- [ ] Create automated email reports
- [ ] Add data quality monitoring dashboard
- [ ] Integrate with real-time data sources
- [ ] Add export functionality (PDF reports)

## 👤 Author
**Adlisyahputra**
- GitHub: [@Adlisyahputra](https://github.com/Adlisyahputra)
- Portfolio: [retail-sales-analysis-portofolio](https://github.com/Adlisyahputra/retail-sales-analysis-portofolio)

## 📄 License
This project is open source and available for educational purposes.

---

*Last Updated: February 2026*
