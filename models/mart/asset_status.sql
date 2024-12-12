with asset_status_with_metadata as (
    select
        asset_status_history_id,
        asset_status_history_date,
        portal_id,
        asset_id,
        status_name,
        status_description
    from {{ ref('int_asset_status_history_enhanced_asset_status') }}
),

portal_list_with_metadata as(
    select
        portal_id,
        site_name
    from {{ ref('int_portal_list_enhanced') }}
)

select
    ashwm.asset_status_history_id,
    ashwm.asset_status_history_date,
    plwm.site_name,
    ashwm.asset_id,
    ashwm.status_name,
    ashwm.status_description
from asset_status_with_metadata as ashwm
inner join portal_list_with_metadata as plwm on (plwm.portal_id = ashwm.portal_id)
order by
    ashwm.asset_status_history_id asc,
    ashwm.asset_status_history_date desc,
    ashwm.asset_id asc