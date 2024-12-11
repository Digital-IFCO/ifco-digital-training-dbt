with raw_portal_list as (
  select *
  from training_dbt.raw.raw_portal_list
)

select
  lower(Id) as portal_id,
  lower(SiteID) as site_id,
  PortalName as portal_name
from raw_portal_list
