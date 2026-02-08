# 📊 Data Analysis Portfolio: Retail Sales Analysis

## 🚀 Quick Links
**[📊 View Live Interactive Dashboard →](https://adlisyahputra.github.io/retail-sales-analysis-portfolio/Retail_Sales_Analysis/dashboard.html)**

**[📝 Detailed Data Cleaning Report →](DATA_CLEANING_REPORT.md)**


---

## 🎯 What This Project Does

This project tackles a common real-world problem: messy sales data. I took 25 transactions with quality issues (NULL values, inconsistent formatting, negative quantities) and cleaned them using SQL, then built an interactive dashboard to visualize the insights.

**The Challenge:** Raw data is rarely perfect. This dataset had 7 different data quality issues that needed fixing before analysis could begin.

**The Solution:** End-to-end pipeline using SQL for cleaning, Python for processing, and Chart.js for visualization.

## 📁 Project Structure
```
retail-sales-analysis-portfolio/
├── README.md
├── data/
│   └── raw_sales_data.csv           # Original messy dataset
├── sql/
│   └── data_cleaning_analysis.sql   # All SQL cleaning & analysis queries
├── scripts/
│   └── process_data.py              # Python automation script
├── dashboard/
│   └── dashboard.html               # Interactive visualization
└── docs/
    └── DATA_CLEANING_REPORT.md      # Detailed before/after documentation
```

**Note:** Running the Python script generates `sales_analysis.db` (SQLite database)

## 🧹 The Data Cleaning Journey

### Problems I Found
When I first opened this dataset, here's what needed fixing:

1. **3 customer names** were literally "NULL" (string, not actual NULL)
2. **Whitespace everywhere** - products like `"  Mouse  "` instead of `"Mouse"`
3. **Inconsistent categories** - same category spelled 3 different ways
4. **One negative quantity** (-1 notebook... what does that even mean?)
5. **Invalid date** - one order had `"invalid-date"` as the date
6. **4 missing ship dates** - orders without shipping info

### How I Fixed It

Used SQL CASE statements and string functions:

```sql
-- Example: Cleaning customer names
CASE 
    WHEN customer_name = 'NULL' THEN 'Unknown Customer'
    ELSE TRIM(customer_name)
END as customer_name

-- Example: Standardizing categories
CASE 
    WHEN LOWER(category) IN ('electronics', 'ELECTRONICS') THEN 'Electronics'
    -- ... more standardization
END as category
```

See the [full SQL script](sql/data_cleaning_analysis.sql) for all cleaning steps.

## 📊 What I Discovered

After cleaning, here's what the data revealed:

### Quick Stats
- **$7,725** in total revenue from 25 orders
- **21 unique customers** with an average order value of **$309**
- **Electronics dominate**: 71.6% of revenue

### Interesting Findings

**1. Electronics is King**  
Technology products (laptops, monitors) drive the majority of revenue. The top 3 products alone account for $5,400.

**2. Regional Balance**  
Revenue is evenly distributed across all 4 regions (East, North, West, South), suggesting good market penetration.

**3. One Loyal Customer**  
Customer C001 (John Doe) placed 4 orders - 16% of all transactions. Perfect candidate for a loyalty program.

### Top Products
| Product | Revenue | Units Sold |
|---------|---------|------------|
| Laptop | $3,600 | 3 |
| Monitor | $1,050 | 3 |
| Desk Chair | $750 | 3 |

## 🛠️ Tech Stack

**Data Processing:**
- SQL (SQLite) - Data cleaning & transformation
- Python 3.13.7 & Pandas - Automation & export
  
**Visualization:**
- HTML/CSS - Dashboard structure
- Chart.js - Interactive charts
- GitHub Pages - Hosting

## 🚀 Running This Project

**Quick Start:**
```bash
# 1. Install dependencies
pip install pandas

# 2. Run the analysis
python3 scripts/process_data.py

# 3. Open dashboard
open dashboard/dashboard.html
```

**Or just [view it live](https://adlisyahputra.github.io/retail-sales-analysis-portofolio/dashboard/dashboard.html)!**

## 📈 Sample SQL Queries

**Category Performance:**
```sql
SELECT 
    category,
    COUNT(*) as orders,
    ROUND(SUM(total_amount), 2) as revenue
FROM cleaned_sales
GROUP BY category
ORDER BY revenue DESC;
```

**Customer Lifetime Value:**
```sql
SELECT 
    customer_name,
    COUNT(*) as total_orders,
    ROUND(SUM(total_amount), 2) as lifetime_value
FROM cleaned_sales
WHERE customer_name != 'Unknown Customer'
GROUP BY customer_name
ORDER BY lifetime_value DESC;
```

## 💡 What I Learned

**Technical Skills:**
- Writing production-quality SQL for data cleaning (not just SELECT *)
- Handling edge cases (NULL as a string, negative quantities)
- Building automated pipelines that others can reproduce
- Creating dashboards that tell a story, not just show data

**Biggest Challenge:**  
Deciding when to clean vs. when to remove data. I had to balance data quality with preserving business insights.

## 🔮 What's Next

Planning to add:
- Customer segmentation using RFM analysis
- Time-series forecasting for sales prediction
- Automated PDF report generation

Feedback and suggestions welcome!

## 👤 Author

**Adli Syahputra**
- 💻 [GitHub](https://github.com/Adlisyahputra)
- 💼 [LinkedIn](https://www.linkedin.com/in/adli-syahputra-1b275a3ab)
- 📧 adlisaputra869@gmail.com

---

**Project Type:** Portfolio / Educational  
**Last Updated:** February 2026

*Feel free to fork, star ⭐, or use this as a template for your own data cleaning projects!*
