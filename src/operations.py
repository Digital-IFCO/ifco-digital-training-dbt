import pyspark.sql.functions as f
import pyspark.sql.types as t
from pyspark.sql import DataFrame
from pyspark.sql.window import Window

from src.config.columns import ColumnCollection as cc
from src.config.params import TimeDeltaDivider, VisitConsolidationSCT, SpecialLocations

from src.utils import calc_time_delta


def add_short_unknown_visit_tag(visits: DataFrame) -> DataFrame:
    """Before removing invalid unknown visits, we want to extract the
    information for future processing.

    Unknown visits are invalid if before and afterwards the same known location can be
    detected which are max xh apart and the unknown visits is max yh long.

    Args:
        visits (DataFrame): visits data

    Returns:
        DataFrame: visits with added tag for invalid visits
    """
    window_spec = Window.partitionBy(cc.assetId).orderBy(cc.endTime)

    # Add information about previous and next visit - especially needed for the possible invalid visits at unknown locations
    visits_enhanced = (
        visits.withColumn(
            "previousVisitLocationId", f.lag(cc.locationId).over(window_spec)
        )
        .withColumn("previousVisitEndTime", f.lag(cc.endTime).over(window_spec))
        .withColumn("nextVisitLocationId", f.lead(cc.locationId).over(window_spec))
        .withColumn("nextVisitStartTime", f.lead(cc.startTime).over(window_spec))
    )

    # calculate time difference between visits at known locations around the unknown visit
    visits_enhanced = calc_time_delta(
        data_frame=visits_enhanced,
        start_time_column="previousVisitEndTime",
        end_time_column="nextVisitStartTime",
        output_column_name="timeDeltaAroundInvalidUnkownHours",
        divider=TimeDeltaDivider.h,
    )

    threshold_dict = VisitConsolidationSCT.invalid_unknown_visits_threshold_dict
    result = (
        visits_enhanced.withColumn(
            # checking if previous visit is unknown, the known visits around the unknown are at the same location &
            # the thresholds for max yh dwell time of unknown visit and max xh between the known visits
            # Note: Logic is appied to last visit of the 3 of interest, so that we can mark this one for the grouping later
            "invalidPreviousUnknownVisit",
            f.when(
                (f.lag(cc.locationId).over(window_spec) == SpecialLocations.unknown)
                & (
                        f.lag(cc.dwellTimeDays).over(window_spec)
                        < threshold_dict["max_dwell_time_unknown_visit_days"]
                )
                & (
                        f.lag("timeDeltaAroundInvalidUnkownHours").over(window_spec)
                        < threshold_dict["max_time_diff_known_visits_hours"]
                )
                & (
                        f.lag("previousVisitLocationId").over(window_spec)
                        == f.lag("nextVisitLocationId").over(window_spec)
                ),
                True,
            ).otherwise(False),
        )
        # mark the unknown visits as invalid
        .withColumn(
            "invalidUnknownVisit",
            f.when(
                f.lead("invalidPreviousUnknownVisit").over(window_spec), True
            ).otherwise(False),
        )
        .drop(
            "timeDeltaAroundInvalidUnkownHours",
            "previousVisitLocationId",
            "previousVisitEndTime",
            "nextVisitLocationId",
            "nextVisitStartTime",
        )
    )

    return result


def add_visit_grouping_per_asset(visits: DataFrame) -> DataFrame:
    """This function groups and labels consecutive visits with same
    assetId and location based condition if the previous unknown visit is removed and
    the previous known location is the same and max yh before the current one has started.

    Args:
        visits (DataFrame): table containing sequences of known visits

    Returns:
        DataFrame: table where consecutive assets visits to same locations
            are tagged
    """
    window_spec = Window.partitionBy(cc.assetId).orderBy(cc.endTime)

    visits = visits.withColumn(
        "consolidationGroupId",
        f.sum(f.when(f.col("invalidPreviousUnknownVisit"), 0).otherwise(1))
        .over(window_spec)
        .cast(t.IntegerType()),
    ).drop("invalidPreviousUnknownVisit")

    return visits
