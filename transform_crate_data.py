# Databricks notebook source

# Import necessary libraries
from pyspark.sql.functions import col, sum

# Read the crate data table
df = spark.table("training_dbt.dev_rodrigo.crate_data")

# Perform analysis: Calculate total quantity per crate_id
agg_df = df.groupBy("crate_id").agg(sum("quantity").alias("total_quantity"))

# Write the aggregated DataFrame to a new table in Unity Catalog
agg_df.write.mode("overwrite").saveAsTable("training_dbt.dev_rodrigo.crate_data_summary")