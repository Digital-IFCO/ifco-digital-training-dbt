with raw_portal_list as (
  select *
  from training_dbt.raw.raw_portal_list
)

select
  lower(PortalId) as portal_id,
  lower(SiteId) as site_id,
  PortalName as portal_name
from raw_portal_list