WITH 

    locations_seed AS (
        SELECT
            -- primary and foregin keys
            extLocationId AS locationId,

            -- dimensions
            region,
            countryName,
            ifcoSystemPartner,
            locationType,
            locationTag,
            locationName        
        FROM {{ ref('locations') }}
    )

SELECT * FROM locations_seed
