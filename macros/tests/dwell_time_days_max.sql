{% test dwell_time_days_max(model, column_name, max_value) %}

/*
  This test checks that no records in the specified model have a `dwellTimeDays` value exceeding `max_value`.
  If any such records exist, the test will fail and return the `locationId` and `visitId` of those records.
*/

with violations as (select locationId,
                           visitId,
                           dwellTimeDays
                    from {{ model }}
                    where {{ column_name }} > {{ max_value }})

select *
from violations

{% endtest %}