{{
  config(
    materialized = "table"
  )
}}

WITH deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY Item_Identifier, Outlet_Identifier ORDER BY Item_Identifier) AS row_num
    FROM {{ source('big_mart', 'source_big_mart_mrp') }}
),
filtered_deduplicated AS (
    SELECT *
    FROM deduplicated
    WHERE row_num = 1
),
-- Step 2: Handling Null Values
filled_nulls AS (
    SELECT
        Item_Identifier,
        COALESCE(
          Item_Weight,
          FIRST_VALUE(Item_Weight) IGNORE NULLS OVER (PARTITION BY Item_Identifier)
        ) AS Item_Weight,
        Item_Fat_Content,
        Item_Visibility,
        Item_Type,
        Item_MRP,
        Outlet_Identifier,
        Outlet_Establishment_Year,
        COALESCE(Outlet_Size, 'Unknown') AS Outlet_Size,
        Outlet_Location_Type,
        Outlet_Type
    FROM filtered_deduplicated
)
SELECT * FROM filled_nulls