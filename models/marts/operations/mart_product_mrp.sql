{{
  config(
    materialized = "table"
  )
}}

WITH ranked_items AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Item_Identifier, Outlet_Identifier 
            ORDER BY Item_MRP DESC
        ) AS row_num
    FROM {{ ref('stg_big_mart__mrp') }}
)
, filtered_items AS (
    SELECT *
    FROM ranked_items 
    WHERE row_num = 1
)
-- Step 2: Standardize Item_Fat_Content values
, standardized_fat_content AS (
    SELECT 
        Item_Identifier,
        Item_Weight,
        CASE 
            WHEN Item_Fat_Content = 'reg' THEN 'Regular'
            WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
            ELSE Item_Fat_Content
        END AS Item_Fat_Content,
        Item_Type,
        Item_MRP,
        Outlet_Identifier,
        Outlet_Location_Type,
        Outlet_Type
    FROM filtered_items
)
-- Step 3: Select columns
SELECT
    Item_Identifier,
    Item_Weight,
    Item_Fat_Content,
    Item_Type,
    Item_MRP,
    Outlet_Identifier,
    Outlet_Location_Type,
    Outlet_Type 
FROM standardized_fat_content