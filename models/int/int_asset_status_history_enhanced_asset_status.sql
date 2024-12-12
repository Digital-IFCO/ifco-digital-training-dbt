{{
    config(
        materialized="ephemeral"
    )
}}

with asset_status_history as (
    select
        asset_status_history_id,
        asset_status_history_date,
        asset_id,
        asset_status_id,
        portal_id
    from {{ ref('src_asset_status_history') }}
),

status as (
    select
        status_id,
        status_name,
        status_description
    from {{ ref('src_status') }}
)

select
    ash.asset_status_history_id,
    ash.asset_status_history_date,
    ash.portal_id,
    ash.asset_id,
    s.status_name,
    s.status_description
from asset_status_history as ash
inner join status as s on (s.status_id = ash.asset_status_id)