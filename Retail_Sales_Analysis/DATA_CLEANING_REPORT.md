# Data Cleaning Documentation

## 📋 Executive Summary
This document provides detailed documentation of the data cleaning process performed on the retail sales dataset. The cleaning addressed 7 major data quality issues and transformed raw data into analysis-ready format.

---

## 🔍 Data Quality Assessment

### Initial Data Inspection
```sql
-- Total Records Check
SELECT COUNT(*) as total_records FROM raw_sales;
-- Result: 25 records

-- Check for NULL values
SELECT 
    SUM(CASE WHEN customer_name IS NULL OR customer_name = 'NULL' THEN 1 ELSE 0 END) as null_customers,
    SUM(CASE WHEN ship_date IS NULL OR ship_date = '' THEN 1 ELSE 0 END) as null_ship_dates,
    SUM(CASE WHEN quantity < 0 THEN 1 ELSE 0 END) as negative_quantities
FROM raw_sales;
```

### Issues Identified

| Issue Type | Count | Severity | Impact |
|-----------|-------|----------|---------|
| NULL customer names | 3 | High | Missing customer identity |
| Missing ship dates | 4 | Medium | Incomplete shipping analysis |
| Negative quantities | 1 | High | Invalid business logic |
| Invalid dates | 1 | High | Analysis errors |
| Whitespace issues | 5 | Low | Inconsistent matching |
| Inconsistent categories | 8 | Medium | Grouping errors |
| Case sensitivity | Multiple | Low | Duplicate categories |

---

## 🛠️ Cleaning Transformations

### 1. Customer Name Cleaning

**Problem**: NULL values and whitespace
```
Before:
- "NULL"
- "  Tom Clark  "
- NULL

After:
- "Unknown Customer"
- "Tom Clark"
- "Unknown Customer"
```

**SQL Implementation**:
```sql
CASE 
    WHEN customer_name = 'NULL' OR customer_name IS NULL 
    THEN 'Unknown Customer'
    ELSE TRIM(customer_name)
END as customer_name
```

**Impact**: 
- 3 NULL values replaced with "Unknown Customer"
- 2 names trimmed of whitespace
- 100% valid customer names

---

### 2. Category Standardization

**Problem**: Inconsistent capitalization
```
Before:
- "electronics"
- "Electronics"
- "furniture"
- "Furniture"
- "stationery"

After:
- "Electronics"
- "Electronics"
- "Furniture"
- "Furniture"
- "Stationery"
```

**SQL Implementation**:
```sql
CASE 
    WHEN LOWER(category) = 'electronics' THEN 'Electronics'
    WHEN LOWER(category) = 'furniture' THEN 'Furniture'
    WHEN LOWER(category) = 'stationery' THEN 'Stationery'
    WHEN LOWER(category) = 'office' THEN 'Office'
    ELSE INITCAP(category)
END as category
```

**Impact**: 
- 8 inconsistent values standardized
- From 7 variations to 4 standard categories
- Accurate grouping for analysis

---

### 3. Quantity Validation

**Problem**: Negative quantity
```
Before:
order_id: 1008, quantity: -1

After:
order_id: 1008, quantity: 1
```

**SQL Implementation**:
```sql
ABS(quantity) as quantity
```

**Business Rule**: Negative quantities assumed to be data entry errors

**Impact**: 
- 1 negative value corrected
- All quantities now positive integers

---

### 4. Date Validation

**Problem**: Invalid date format
```
Before:
order_id: 1014, order_date: "invalid-date"

After:
order_id: 1014, order_date: NULL
```

**SQL Implementation**:
```sql
CASE 
    WHEN order_date LIKE '%invalid%' THEN NULL
    ELSE order_date
END as order_date
```

**Impact**: 
- 1 invalid date set to NULL
- Prevents date parsing errors
- Can be excluded from time-series analysis

---

### 5. Ship Date Handling

**Problem**: Missing ship dates (empty strings)
```
Before:
- "" (empty string)
- NULL

After:
- NULL (standardized)
- NULL
```

**SQL Implementation**:
```sql
CASE 
    WHEN ship_date IS NULL OR ship_date = '' THEN NULL
    ELSE ship_date
END as ship_date
```

**Impact**: 
- 4 missing ship dates identified
- Standardized NULL handling
- Clear distinction between shipped and unshipped orders

---

### 6. Product Name Trimming

**Problem**: Leading/trailing whitespace
```
Before:
- "  Mouse  "
- "  Notebook  "

After:
- "Mouse"
- "Notebook"
```

**SQL Implementation**:
```sql
TRIM(product_name) as product_name
```

**Impact**: 
- 3 product names trimmed
- Consistent product matching
- Better search and filtering

---

### 7. Calculated Fields

**Addition**: Total Amount calculation
```sql
ROUND(ABS(quantity) * price, 2) as total_amount
```

**Benefit**: 
- Pre-calculated revenue per order
- Faster aggregation queries
- Ensures consistent calculation method

---

## 📊 Before vs After Comparison

### Data Quality Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Valid Customer Names | 88% | 100% | +12% |
| Standardized Categories | 68% | 100% | +32% |
| Valid Quantities | 96% | 100% | +4% |
| Valid Dates | 96% | 96% | 0% (flagged) |
| Complete Records | 84% | 84% | 0% (acceptable) |

### Sample Records Transformation

**BEFORE**:
```
order_id: 1008
customer_id: C006
customer_name: "Mike Brown"
product_name: "  Notebook  "
category: "Stationery"
quantity: -1
price: 3.50
order_date: "2024-01-21"
ship_date: "2024-01-23"
region: "West"
payment_method: "Cash"
```

**AFTER**:
```
order_id: 1008
customer_id: C006
customer_name: "Mike Brown"
product_name: "Notebook"
category: "Stationery"
quantity: 1
price: 3.50
order_date: "2024-01-21"
ship_date: "2024-01-23"
region: "West"
payment_method: "Cash"
total_amount: 3.50
```

---

## ✅ Validation Queries

### 1. Verify No NULL Customer Names
```sql
SELECT COUNT(*) FROM cleaned_sales 
WHERE customer_name IS NULL OR customer_name = 'NULL';
-- Expected: 0
```

### 2. Verify Category Standardization
```sql
SELECT DISTINCT category FROM cleaned_sales;
-- Expected: 4 values (Electronics, Furniture, Stationery, Office)
```

### 3. Verify No Negative Quantities
```sql
SELECT COUNT(*) FROM cleaned_sales WHERE quantity < 0;
-- Expected: 0
```

### 4. Verify Data Integrity
```sql
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT order_id) as unique_orders,
    SUM(CASE WHEN total_amount != ROUND(quantity * price, 2) THEN 1 ELSE 0 END) as calc_errors
FROM cleaned_sales;
-- Expected: calc_errors = 0
```

---

## 🎯 Cleaning Results Summary

### Successfully Cleaned
- ✅ 3 NULL customer names → "Unknown Customer"
- ✅ 8 category variations → 4 standard categories
- ✅ 1 negative quantity → positive value
- ✅ 1 invalid date → flagged as NULL
- ✅ 5 whitespace issues → trimmed
- ✅ 4 empty ship dates → standardized to NULL
- ✅ Added calculated total_amount field

### Data Completeness
- **100%** valid customer identifiers
- **100%** valid product names
- **100%** valid categories
- **100%** valid quantities
- **96%** valid order dates (1 flagged)
- **84%** complete ship dates (acceptable for business)

### Business Impact
- Accurate revenue calculations
- Reliable customer segmentation
- Consistent product categorization
- Trustworthy trend analysis
- Clean data for machine learning models

---

## 📝 Best Practices Applied

1. **Non-Destructive Cleaning**: Original data preserved in `raw_sales` table
2. **Documented Assumptions**: All business rules clearly documented
3. **Validation Checks**: Multiple validation queries to ensure quality
4. **Standardization**: Consistent handling of NULL, whitespace, and case
5. **Audit Trail**: Can trace back to original values if needed

---

## 🔄 Reproducibility

All cleaning steps are:
- ✅ Documented in SQL scripts
- ✅ Version controlled
- ✅ Repeatable
- ✅ Auditable
- ✅ Reversible

The cleaning pipeline can be re-run on new data with the same quality standards.

---

*Documentation completed: February 2026*
