# Databricks notebook source


import sys

from databricks.sdk.runtime import spark


your_user = ''
repo_name = "ifco-digital-training-dbt"

catalog = "training_dbt"
schema = "s5_schema"

repo_path = f"/Workspace/Users/{your_user}/{repo_name}/src"

if repo_path not in sys.path:
    sys.path.append(repo_path)

# COMMAND ----------

import pyspark.sql.functions as f

from src.operations import add_short_unknown_visit_tag, add_visit_grouping_per_asset
from src.utils import (
    remove_location_redundancy,
    set_min_start_time_in_group, calc_dwell_time_days,
)


# COMMAND ----------

visits = spark.table(f"{catalog}.{schema}.visit_consolidation")

# COMMAND ----------

# Remove invalid unknown visits
# Unknown visits are invalid if before and afterwards the same known location can be
# detected which are max 'x' hours apart and the unknown visits is max 'y' hours long.
visits_invalid_unknowns = add_short_unknown_visit_tag(visits=visits)
visits_without_invalid_unknowns = visits_invalid_unknowns.filter(
    ~(f.col("invalidUnknownVisit"))
).drop("invalidUnknownVisit")


# COMMAND ----------

# Groups and labels consecutive visits with same assetId and location if previous unknown visits was removed
visits_grouping = add_visit_grouping_per_asset(visits=visits_without_invalid_unknowns)
visits_grouping = set_min_start_time_in_group(visits=visits_grouping)


# COMMAND ----------

# Eliminates sequences of asset visits to a same location.
#  From a sequence of same locations visits only the last one is kept.
visits_sct_prepared = remove_location_redundancy(visits=visits_grouping)

visits_sct_prepared = calc_dwell_time_days(visits=visits_sct_prepared)

# COMMAND ----------

visits_sct_prepared.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.visits_preparation_{your_user}")