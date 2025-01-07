
            create materialized view `training_dbt`.`s3_dab_schema`.`orders_daily`
    
    COMMENT 'Number of orders by day'
    
  

    
  as
    -- This model file defines a materialized view called 'orders_daily'
--
-- Read more about materialized at https://docs.getdbt.com/reference/resource-configs/databricks-configs#materialized-views-and-streaming-tables
-- Current limitation: a "full refresh" is needed in case the definition below is changed; see https://github.com/databricks/dbt-databricks/issues/561.


select order_date, count(*) AS number_of_orders

from `training_dbt`.`s3_dab_schema`.`orders_raw`

-- During development, only process a smaller range of data

where order_date >= '2019-08-01' and order_date < '2019-09-01'


group by order_date

        