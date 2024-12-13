with raw_status as (
  select *
  from training_dbt.raw.raw_status
)

select
  Id as status_id,
  Name as status_name,
  Description as status_description
from raw_status