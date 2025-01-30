{{
  config(
    materialized = "table"
  )
}}

WITH cleaned AS (
    SELECT 
        ORDERNUMBER AS order_number,
        QUANTITYORDERED AS quantity_ordered,
        PRICEEACH AS price_each,
        YEAR_ID AS year_id,
        -- Convert order_date to a proper DATE format
        TO_DATE(ORDERDATE, 'M/d/yyyy H:mm') AS order_date,
        SALES AS total_sales,
        PRODUCTCODE AS product_code,
        CUSTOMERNAME AS customer_name,
        COUNTRY AS country,
        -- Handle missing values
        COALESCE(ADDRESSLINE2, 'Unknown') AS address_line2,
        COALESCE(STATE, 'Unknown') AS state,
        COALESCE(TERRITORY, 'Unknown') AS territory
    FROM {{ source('retailer', 'source_retailer_sales') }}
)
SELECT * FROM cleaned