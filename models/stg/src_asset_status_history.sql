{{
    config(
        materialized="incremental",
        partition_by=["ingestion_date"]
    )
}}

with final as (
  select *
  from {{ source("data_lake", "assetstatushistory") }}
  where validFrom_DLS between '2023-01-01' and '2024-01-01'
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
    {% if is_incremental() %}
    and cast(validFrom_DLS as date) > (select max(ingestion_date) from {{ this }})
    {% endif %}