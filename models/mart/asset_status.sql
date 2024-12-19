with enhanced_asset_status as (
    select
        asset_status_history_id,
        asset_status_history_date,
        portal_id,
        asset_id,
        status_name,
        status_description
    from {{ ref('int_asset_status_history_enhanced_status_info') }}
),

enhanced_portal_list as (
    select
        portal_id,
        portal_name,
        site_code,
        site_name
    from {{ ref('int_portal_list_enhanced') }}
)

select
        eas.asset_status_history_id,
        eas.asset_status_history_date,
        epl.portal_name,
        eas.asset_id,
        eas.status_name,
        eas.status_description,
        epl.site_code,
        epl.site_name
from enhanced_asset_status as eas
inner join enhanced_portal_list as epl on (epl.portal_id = eas.portal_id)