from enum import Enum


class ColumnCollection(str, Enum):
    """Defines all usable column names in alphabetical order.
    All columns and their names should start with lower case,
        except for the columns used by Templates or Sensize.
    A column and its name should be spelled the same way,
        only whitespaces should be replaced by underscores.
    """
    assetId = "assetId"
    startTime = "startTime"
    endTime = "endTime"
    validFrom = "validFrom"
    dwellTimeDays = "dwellTimeDays"
    locationId = "locationId"
    startTimeLocal = "startTimeLocal"
    endTimeLocal = "endTimeLocal"