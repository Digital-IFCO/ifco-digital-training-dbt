-- This is the default template for models

WITH 

location_groups_seed AS (
    SELECT *
    FROM {{ ref('location_groups') }}
)

SELECT * FROM location_groups_seed
