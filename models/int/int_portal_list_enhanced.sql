{{
    config(
        materialized="ephemeral"
    )
}}

with site as (
    select
        site_id,
        site_code,
        site_name,
        ingestion_dat
    from {{ ref('src_site') }}
),

portal as (
    select
        portal_id,
        site_id,
        portal_nam
    from {{ ref('src_portal_list') }}
)

select
    portal_id,
    site_id,
    portal_nam,
    site_code,
    site_name,
    ingestion_dat
from site
inner join portal on (site.site_id = portal.site_id)