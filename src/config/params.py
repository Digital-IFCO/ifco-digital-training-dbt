from enum import IntEnum


class TimeDeltaDivider(IntEnum):
    s = 1
    m = 60
    h = 3600
    d = 86400


class SpecialLocations:
    unknown = "00000000-0000-0000-0000-000000000000"


class VisitConsolidationSCT:
    invalid_unknown_visits_threshold_dict = {
        "max_time_diff_known_visits_hours": 12,
        "max_dwell_time_unknown_visit_days": 0.5,
    }
