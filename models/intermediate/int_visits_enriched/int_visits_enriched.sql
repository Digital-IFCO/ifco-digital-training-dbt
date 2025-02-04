-- This is the default template for models

WITH 

    staged_visits AS (
        SELECT
            assetId,
            locationId,
            visitId,
            arrivalTime,
            departureTime,
            longitude,
            latitude,
            timeZone,
            dwellTimeDays
        FROM {{ ref('stg_visits') }}
    ),

    staged_locations AS (
        SELECT
            locationId,
            region,
            countryName,
            ifcoSystemPartner,
            locationType,
            locationTag,
            locationName   
        FROM {{ ref('stg_locations') }}
    ),

    staged_sensors AS (
        SELECT            
            sensorId,
            assetId,
            attachedAt,
            attachedTill,
            sensorTechnology
        FROM {{ ref('stg_sensors') }}
    ),

    visits_enriched_with_location_data AS (
        SELECT
            v.*,
            l.region,
            l.countryName,
            l.ifcoSystemPartner,
            l.locationType,
            l.locationTag,
            l.locationName  
        FROM staged_visits v
        LEFT JOIN staged_locations l ON v.locationId = l.locationId
    ),

    visits_enriched_with_scanner_data AS (
        SELECT
            v.*,
            s.sensorId,
            s.attachedAt,
            s.attachedTill,
            s.sensorTechnology
        FROM visits_enriched_with_location_data v
        LEFT JOIN staged_sensors s ON v.assetId = s.assetId
        WHERE 
            v.arrivalTime >= s.attachedAt
            AND v.departureTime <= s.attachedTill
    ),

    visits_enriched AS (
        SELECT
            assetId,
            visitId,
            locationId,
            region,
            countryName,
            locationType,
            locationTag,
            locationName,
            ifcoSystemPartner,
            arrivalTime,
            departureTime,
            longitude,
            latitude,
            timeZone,
            dwellTimeDays,
            sensorId,
            attachedAt,
            attachedTill,
            sensorTechnology
        FROM visits_enriched_with_scanner_data
    )

SELECT * FROM visits_enriched