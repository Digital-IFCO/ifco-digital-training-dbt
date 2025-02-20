{% macro convert_currency(amount, currency) %}
    {% set exchange_rates = {
        'USD': {'USD': 1, 'EUR': 1.1, 'JPY': 0.009, 'GBP': 1.3},
        'EUR': {'USD': 0.9091, 'EUR': 1, 'JPY': 0.00818, 'GBP': 1.1818}
    } %}
    case
        {% for currency, rate in exchange_rates[base_currency].items() %}
            when currency = '{{ currency }}' then amount * {{ rate }}
        {% endfor %}
        else null
    end
{% endmacro %}