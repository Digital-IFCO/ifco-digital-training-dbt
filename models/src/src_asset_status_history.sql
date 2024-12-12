{{
    config(
        materialized="incremental",
        on_schema_change="fail",
        partition_by=["ingestion_date"]
    )
}}

with raw_asset_status_history as (
    select *
    from {{ source('rtina_adls_data', 'assetstatushistory') }}
    where validFrom_DLS between '2024-11-01' and '2024-11-15'
)

select
    Id as asset_status_history_id,
    AssetId as asset_id,
    StatusId as asset_status_id,
    PortalId as portal_id,
    Date as asset_status_history_date,
    cast(validFrom_DLS as date) as ingestion_date
from raw_asset_status_history
where
    historyStatus = 'A'
    and validTo_DLS = '9999-12-31T23:59:59.999+00:00'
    {% if is_incremental() %}
    and cast(validFrom_DLS as date) > (select max(ingestion_date) from {{ this }})
    {% endif %}