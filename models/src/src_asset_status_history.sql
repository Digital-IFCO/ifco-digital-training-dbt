with raw_asset_status_history as (
    select *
    from training_dbt.raw.raw_asset_status_history
)

select
    Id as asset_status_history_id,
    AssetId as asset_id,
    StatusId as asset_status_id,
    PortalId as portal_id,
    Date as asset_status_history_date
from raw_asset_status_history
where
    historyStatus = 'A'
    and validTo_DLS = '9999-12-31T23:59:59.999+00:00'