{{
    config(
        materialized='table'
    )
}}

with visits_enhanced as
    (select assetId,
            visitId,
            locationId,
            startTime,
            endTime,
            dwellTimeDays,
            validFrom,
            sourceFolder,
            fileDate,
            timeZone,
            incomplete,
            latitude,
            longitude,
            lag(locationId) over (partition by assetId order by endTime) as previousVisitLocationId,
             lag(endTime) over (partition by assetId order by endTime) as previousVisitEndTime,
             lead(locationId) over (partition by assetId order by endTime) as nextVisitLocationId,
             lead(startTime) over (partition by assetId order by endTime) as nextVisitStartTime
    from {{ source('visits', 'visit_consolidation') }}
),

visits_with_delta as
    (select assetId,
            visitId,
            locationId,
            startTime,
            endTime,
            dwellTimeDays,
            validFrom,
            sourceFolder,
            fileDate,
            timeZone,
            incomplete,
            latitude,
            longitude,
            previousVisitLocationId,
            previousVisitEndTime,
            nextVisitLocationId,
            nextVisitStartTime,
            datediff(hour, previousVisitEndTime, nextVisitStartTime) as timeDeltaAroundInvalidUnknownHours
    from visits_enhanced
),

 visits_with_invalid_flags as
     (select assetId,
            visitId,
            locationId,
            startTime,
            endTime,
            dwellTimeDays,
            validFrom,
            sourceFolder,
            fileDate,
            timeZone,
            incomplete,
            latitude,
            longitude,
            previousVisitLocationId,
            previousVisitEndTime,
            nextVisitLocationId,
            nextVisitStartTime,
            timeDeltaAroundInvalidUnknownHours,
          case
              when previousVisitLocationId = '00000000-0000-0000-0000-000000000000'
                  and
                   lag(previousVisitLocationId) over (partition by assetId order by endTime) = lag(nextVisitLocationId) over (partition by assetId order by endTime)
              and lag(timeDeltaAroundInvalidUnknownHours) over (partition by assetId order by endTime) < 12
        and lag(dwellTimeDays) over (partition by assetId order by endTime) < 0.5
    then true
    else false
end
as invalidPreviousUnknownVisit
    from visits_with_delta
),

visits_with_invalid_unknown_visit as (
    select assetId,
            visitId,
            locationId,
            startTime,
            endTime,
            dwellTimeDays,
            validFrom,
            sourceFolder,
            fileDate,
            timeZone,
            incomplete,
            latitude,
            longitude,
            previousVisitLocationId,
            previousVisitEndTime,
            nextVisitLocationId,
            nextVisitStartTime,
            timeDeltaAroundInvalidUnknownHours,
            invalidPreviousUnknownVisit,
    case
        when lead(invalidPreviousUnknownVisit) over (partition by assetId order by endTime) = 'true'
        then true
        else false
    end as invalidUnknownVisit
    from visits_with_invalid_flags
),

visits_without_invalid_unknowns as (
    select
        assetId,
        visitId,
        locationId,
        startTime,
        endTime,
        dwellTimeDays,
        invalidPreviousUnknownVisit,
        invalidUnknownVisit,
        validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude
    from visits_with_invalid_unknown_visit
    where invalidUnknownVisit = 'false'
),

grouped_visits as (
    select
        assetId,
        visitId,
        locationId,
        startTime,
        endTime,
        dwellTimeDays,
        invalidPreviousUnknownVisit,
        validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude,
    sum(case when invalidPreviousUnknownVisit then 0 else 1 end)
    over (partition by assetId order by endTime) as consolidationGroupId
    from visits_without_invalid_unknowns
),

grouped_visits_with_min_start_time as (
    select
        assetId,
        visitId,
        locationId,
        startTime,
        endTime,
        dwellTimeDays,
        invalidPreviousUnknownVisit,
        consolidationGroupId,
        validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude,
    min(startTime) over (partition by assetId, consolidationGroupId) as updated_startTime
    from grouped_visits
),

visits_with_max_endTime as (
    select
        assetId,
        visitId,
        locationId,
        startTime,
        endTime,
        dwellTimeDays,
        updated_startTime,
        invalidPreviousUnknownVisit,
        consolidationGroupId,
        validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude,
        max(endTime) over (partition by assetId, consolidationGroupId) as maxEndTime,
        max(validFrom) over (partition by assetId, consolidationGroupId) as maxValidFrom
    from grouped_visits_with_min_start_time
),


visits_without_redundant_locations as (
    select
        assetId,
        visitId,
        locationId,
        updated_startTime as startTime,
        endTime,
        maxValidFrom as validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude
    from visits_with_max_endTime
    where endTime = maxEndTime
),

visits_with_dwell_time as (
    select
        assetId,
        visitId,
        locationId,
        startTime,
        endTime,
        validFrom,
        sourceFolder,
        fileDate,
        timeZone,
        incomplete,
        latitude,
        longitude,
        round(datediff(SECOND, startTime, endTime) / 86400.0, 2) AS dwellTimeDays
        from visits_without_redundant_locations
)

select assetId,
       visitId,
       locationId,
       startTime,
       endTime,
       validFrom,
       sourceFolder,
       fileDate,
       timeZone,
        incomplete,
       latitude,
       longitude,
       dwellTimeDays
from visits_with_dwell_time