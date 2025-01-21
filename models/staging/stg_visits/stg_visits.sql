WITH 

    visits_seed AS (
        SELECT
            -- primary and foregin ids
            assetId,
            locationId,
            visitId,

            -- datetime columns
            CAST(startTime AS TIMESTAMP) AS startTime,
            CAST(endTime AS TIMESTAMP) AS endTime,

            -- dimensions
            timeZone,
            dwellTimeDays
        FROM {{ ref('visits') }}
    )

SELECT * FROM visits_seed
