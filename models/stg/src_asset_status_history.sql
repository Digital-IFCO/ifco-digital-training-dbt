with final as (
  select *
  from training_dbt.raw.raw_asset_status_history
  where validFrom_DLS between '2023-01-01' and '2023-12-31'
)

select
  Id as asset_status_history_id,
  AssetId as asset_id,
  StatusId as asset_status_id,
  PortalId as portal_id,
  Date as asset_status_history_date,
  cast(validFrom_DLS as date) as ingestion_date
from final
where
  historyStatus = 'A'
  and validTo_DLS = '9999-12-31T23:59:59.999+00:00'