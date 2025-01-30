{{
  config(
    materialized = "table"
  )
}}

WITH customer_sales AS (
    SELECT 
        customer_name,
        country,
        year_id,
        CAST(SUM(total_sales) AS DECIMAL(10,2)) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        CAST(SUM(total_sales) / COUNT(DISTINCT order_number)AS DECIMAL(10,2)) AS avg_order_value
    FROM {{ ref('stg_retailer__sales') }}
    GROUP BY customer_name, country, year_id
)
SELECT * FROM customer_sales