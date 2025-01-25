from pyspark.sql import DataFrame
from pyspark.sql.window import Window
import pyspark.sql.functions as f
from src.config.columns import ColumnCollection as cc
from src.config.params import TimeDeltaDivider
import pyspark.sql.types as t

def set_min_start_time_in_group(visits: DataFrame) -> DataFrame:
    """This function sets startTime to its min value inside each group of
    consecutive asset visits to the same location.

    Notes:
        * column `consolidationGroupId` is mandatory
        * should be used together with function `remove_location_redundancy()`

    Args:
        visits (DataFrame): table where groups of consecutive asset visits to
            same locations are tagged via `consolidationGroupId`

    Returns:
        DataFrame: same table as input, now with startTime set to its min
            value inside every asset-location group
    """
    window_spec = Window.partitionBy(cc.assetId, "consolidationGroupId")
    visits = visits.withColumn(
        cc.startTime, f.min(f.col(cc.startTime)).over(window_spec)
    )
    return visits


def remove_location_redundancy(visits: DataFrame) -> DataFrame:
    """This function eliminates sequences of asset visits to a same location.
    From a sequence of same locations visits only the last one is kept.

    Notes:
        * column `consolidationGroupId` is mandatory
        * should be used together with function `set_min_start_time_in_group()`

    Args:
        visits (DataFrame): table with tagged consecutive asset visits to same
            locations and with startTime dates set to their min group value

    Returns:
        DataFrame: table without consecutive asset visits to same locations
    """
    window_spec = Window.partitionBy(cc.assetId, "consolidationGroupId")
    visits = (
        visits.withColumn("maxEndTime", f.max(f.col(cc.endTime)).over(window_spec))
        .withColumn("maxValidFrom", f.max(f.col(cc.validFrom)).over(window_spec))
        .filter(f.col("maxEndTime") == f.col(cc.endTime))
        .drop("maxEndTime", cc.validFrom, "consolidationGroupId")
        .withColumnRenamed("maxValidFrom", cc.validFrom)
    )
    return visits


def calc_dwell_time_days(visits: DataFrame) -> DataFrame:
    """This function adds the column 'dwellTimeDays' to the visits table.
    The values of 'dwellTimeDays' quantify the duration of every visit, given
    by the difference 'startTime' - 'endTime' in number of days.

    Args:
        visits (DataFrame): consolidated visits

    Returns:
        DataFrame: same table as the input, now containing a column with the
            'dwellTimeDays' values
    """
    visits = calc_time_delta(
        data_frame=visits,
        start_time_column=cc.startTime,
        end_time_column=cc.endTime,
        output_column_name=cc.dwellTimeDays,
        divider=TimeDeltaDivider.d,
    )

    result = visits.withColumn(
        cc.dwellTimeDays, f.col(cc.dwellTimeDays).cast(t.DecimalType(6, 2))
    )

    return result


def calc_time_delta(
        data_frame: DataFrame,
        divider: TimeDeltaDivider,
        output_column_name: str,
        start_time_column: str | None = None,
        end_time_column: str | None = None,
        start_time_value: str | None = None,
        end_time_value: str | None = None,
) -> DataFrame:
    """This function calculates a time delta between two timestamps/dates. Either
    a column or a constant value can be passed as start and end time. The
    divider can be used to set the unit of the resulting time delta.

    Args:
        data_frame (DataFrame): data_frame
        divider (TimeDeltaDivider): attribute of TimeDeltaDivider
        start_time_column (str): name of input column for start time
        end_time_column (str):  name of input column for end time
        start_time_value (str): constant value for start time
        end_time_value (str): constant value for end time
        output_column_name (str): name of output column

    Returns:
        DataFrame: data_frame with additional time delta column
    """
    if not start_time_column:
        start_time_column = "startTimeColumn"
        data_frame = data_frame.withColumn(
            start_time_column, f.to_timestamp(f.lit(start_time_value))
        )
    if not end_time_column:
        end_time_column = "endTimeColumn"
        data_frame = data_frame.withColumn(
            end_time_column, f.to_timestamp(f.lit(end_time_value))
        )

    result = data_frame.withColumn(
        output_column_name,
        (
                f.col(end_time_column).cast(t.TimestampType())
                - f.col(start_time_column).cast(t.TimestampType())
        ).cast(t.LongType())
        / int(divider),
    ).drop("startTimeColumn", "endTimeColumn")

    return result
