{{
    config(
        materialized='table',
    )
}}

select
    transaction_id,
    product_id,
    date,
    amount,
    currency
from
    {{ ref('seed_transactions') }}