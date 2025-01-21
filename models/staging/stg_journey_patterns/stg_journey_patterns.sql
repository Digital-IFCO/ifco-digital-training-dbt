-- This is the default template for models

WITH 

    journey_patterns_seed AS (
        SELECT
            CAST(journeyId AS INT) AS journeyId,
            split(journeyPattern, ';') AS journey_locations,
            journeyType AS journeyClassification,
            includeFirstLocation,
            includeLastLocation,
            journeyType_2 AS journeyType,
            region,
            partner,
            CAST(beforeStartGroupId AS INT) AS beforeStartGroupId,
            CAST(startGroupId AS INT) AS startGroupId,
            CAST(endGroupId AS INT) AS endGroupId,
            CAST(afterEndGroupId AS INT) AS afterEndGroupId
        FROM {{ ref('journey_patterns') }}
    )

SELECT * FROM journey_patterns_seed
