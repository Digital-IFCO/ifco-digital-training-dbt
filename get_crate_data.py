# Databricks notebook source

# Import necessary libraries
from pyspark.sql.functions import col, to_date

# Sample crate data
data = [
    (1, "2025-01-01", "crate_001", 100),
    (2, "2025-01-02", "crate_002", 150),
    (3, "2025-01-03", "crate_001", 200),
    (4, "2025-01-04", "crate_003", 250)
]

# Define the schema
schema = ["id", "date", "crate_id", "quantity"]

# Create a DataFrame
df = spark.createDataFrame(data, schema)

# Transform the data: Convert date column to DateType
df = df.withColumn("date", to_date(col("date"), "yyyy-MM-dd"))

# Write the transformed DataFrame to a table in Unity Catalog
df.write.mode("overwrite").saveAsTable("training_dbt.dev_rodrigo.crate_data")
