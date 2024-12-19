with asset_status as (
    select asset_id,
        min(asset_status_history_date) as cycle_start_date,
        max(asset_status_history_date) as cycle_end_date,
        datediff(max(asset_status_history_date), min(asset_status_history_date)) as cycle_duration
    from {{ ref('asset_status') }} group by asset_id
)

select
    asset_id,
    cycle_start_date,
    cycle_end_date,
    cycle_duration
from asset_status
