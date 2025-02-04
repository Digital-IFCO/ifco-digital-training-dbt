WITH 

    visits_seed AS (
        SELECT
            -- primary and foregin ids
            assetId,
            locationId,
            visitId,

            -- datetime columns
            CAST(arrivalTime AS TIMESTAMP) AS arrivalTime,
            CAST(departureTime AS TIMESTAMP) AS departureTime,

            -- dimensions
            longitude,
            latitude,
            timeZone,
            dwellTimeDays
        FROM {{ ref('visits') }}
    )

SELECT * FROM visits_seed
