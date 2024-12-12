with raw_site as (
    select *
    from training_dbt.raw.raw_site
    where validFrom_DLS between '2024-11-01' and '2024-11-17'
)

select
    Id as site_id,
    SiteCode as site_code,
    Name as site_name
from raw_site
where
    historyStatus = 'A'
    and validTo_DLS = '9999-12-31T23:59:59.999+00:00'