{{
    config(
        materialized='table',
    )
}}

{% set base_currency = 'EUR' %}

{% set exchange_rates = {
    'USD': {'USD': 1, 'EUR': 1.1, 'JPY': 0.009, 'GBP': 1.3},
    'EUR': {'USD': 0.9091, 'EUR': 1, 'JPY': 0.00818, 'GBP': 1.1818}
} %}

with converted_transactions as (
    select
        transaction_id,
        product_id,
        date,
        amount,
        currency,
        case
            {% for currency, rate in exchange_rates[base_currency].items() %}
                when currency = '{{ currency }}' then amount * {{ rate }}
            {% endfor %}
            else null
        end as standardized_amount
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