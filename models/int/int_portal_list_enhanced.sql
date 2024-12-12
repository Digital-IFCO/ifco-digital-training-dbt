{{
    config(
        materialized="ephemeral"
    )
}}

with

portal_list as (
    select
        portal_id,
        site_id
    from {{ ref('src_portal_list') }}
),

site as (
    select
        site_id,
        site_name
    from {{ ref('src_site') }}
)

select
    pl.portal_id,
    s.site_name
from portal_list as pl
inner join site as s on (s.site_id = pl.site_id)