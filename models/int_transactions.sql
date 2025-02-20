{{
    config(
        materialized='table',
    )
}}

with converted_transactions as (
    select
        transaction_id,
        product_id,
        date,
        amount,
        currency,
        {{ convert_currency('amount', 'currency')}} as standardized_amount
    from
        {{ ref('stg_transactions') }}
)
select
    transaction_id,
    product_id,
    date,
    standardized_amount as amount,
    '{{ base_currency }}' as currency
from converted_transactions;