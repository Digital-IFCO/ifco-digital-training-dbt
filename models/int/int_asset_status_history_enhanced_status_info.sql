{{
    config(
        materialized="ephemeral"
    )
}}

with stg_asset_status_history as (
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
    sash.asset_status_history_id,
    sash.asset_status_history_date,
    sash.portal_id,
    sash.asset_id,
    s.status_name,
    s.status_description
from stg_asset_status_history as sash
inner join status as s on (s.status_id = sash.asset_status_id)