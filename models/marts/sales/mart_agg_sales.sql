{{
  config(
    materialized = "table"
  )
}}

WITH sales_analysis AS (
    SELECT 
        customer_name,
        country,
        SUM(total_sales) as total_sales,
        AVG(avg_order_value) AS avg_order_value,
        CASE 
            WHEN SUM(total_sales) > 100000 THEN 'High'
            WHEN SUM(total_sales) > 50000 THEN 'Medium'
            ELSE 'Low'
        END AS sales_category
    FROM  {{ ref('int_retailer_sales') }}
    GROUP BY customer_name, country
)

SELECT * FROM sales_analysis