import pyspark.sql.functions as f
from src.operations import add_short_unknown_visit_tag, add_visit_grouping_per_asset
from src.utils import (
    remove_location_redundancy,
    set_min_start_time_in_group,
    calc_dwell_time_days,
)


def model(dbt, session):
    #
    # dbt.config(create_notebook=True)

    visits = dbt.source("demo_visits_data", "visit_consolidation")

    visits_invalid_unknowns = add_short_unknown_visit_tag(visits=visits)
    visits_without_invalid_unknowns = visits_invalid_unknowns.filter(
        ~(f.col("invalidUnknownVisit"))
    ).drop("invalidUnknownVisit")

    visits_grouping = add_visit_grouping_per_asset(visits=visits_without_invalid_unknowns)
    visits_grouping = set_min_start_time_in_group(visits=visits_grouping)
    visits_sct_prepared = remove_location_redundancy(visits=visits_grouping)
    visits_sct_prepared = calc_dwell_time_days(visits=visits_sct_prepared)

    return visits_sct_prepared
