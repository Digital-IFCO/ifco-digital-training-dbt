{{config(materialized='view')}}

with int_assets_filtered_by_status as (
select * from {{ref('stg_rtina__asset')}}
where    valid_to_dls = '9999-12-31 23:59:59.9990000' and history_status = 'A')
select *
from int_assets_filtered_by_status