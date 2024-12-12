{{
    config(
        materialized="incremental",
        on_schema_change="fail",
        partition_by=["ingestion_date"]
    )
}}

with raw_site as (
    select *
    from {{ source('rtina_adls_data', 'site') }}
    where validFrom_DLS between '2021-01-01' and '2024-12-31'
)

select
    Id as site_id,
    SiteCode as site_code,
    Name as site_name,
    cast(validFrom_DLS as date) as ingestion_date
from raw_site
where
    historyStatus = 'A'
    and validTo_DLS = '9999-12-31T23:59:59.999+00:00'
    {% if is_incremental() %}
    and cast(validFrom_DLS as date) > (select max(ingestion_date) from {{ this }})
    {% endif %}