WITH 

    sensors_seed AS (
        SELECT
            -- primary and foregin keys
            sensorId,
            assetId,

            -- datetime columns
            CAST(attachedAt AS TIMESTAMP) AS attachedAt,
            CAST(attachedTill AS TIMESTAMP) AS attachedTill,

            -- dimensions
            sensorTechnology
        FROM {{ ref('sensors') }}
    )

SELECT * FROM sensors_seed
