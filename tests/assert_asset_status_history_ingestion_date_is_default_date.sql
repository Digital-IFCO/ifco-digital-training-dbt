with test_data as (
    select * from {{ ref('src_asset_status_history') }}
)
select *
from test_data
where ingestion_date = date'9999-12-31T23:59:59.999+00:00'