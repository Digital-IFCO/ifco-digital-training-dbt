-- This is the default template for models

WITH 

    cycle_patterns_seed AS (
        SELECT
            CAST(cycleId AS INT) AS cycleId,
            split(cyclePattern, ';') AS cyclePattern,
            cycleType,
            cycleClass,
            region,
            partner
        FROM {{ ref('cycle_patterns') }}
    )

SELECT * FROM cycle_patterns_seed
