{{
    config(
        materialized="ephemeral"
    )
}}

with site as (
    select
        site_id,
        site_code,
        site_name
    from {{ ref('src_site') }}
),

portal as (
    select
        portal_id,
        site_id,
        portal_name
    from {{ ref('src_portal_list') }}
)

select
    p.portal_id,
    p.site_id,
    p.portal_name,
    s.site_code,
    s.site_name
from site as s
inner join portal as p on (s.site_id = p.site_id)