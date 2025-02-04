WITH

    visits AS (
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
        FROM {{ ref('int_visits_enriched') }}
    ),

    transactions AS (
        SELECT
            assetId,
            SHA1(CONCAT(visitId, LEAD(visitId) OVER (PARTITION BY assetId ORDER BY departureTime))) AS transactionId,
            DATEDIFF(LEAD(arrivalTime) OVER (PARTITION BY assetId ORDER BY departureTime), departureTime) AS transactionTransitTime,

            visitId AS senderVisitId,
            locationId AS senderLocationId,
            longitude AS senderLocationLongitude,
            latitude AS senderLocationLatitude,
            locationType AS senderLocationType,
            locationTag AS senderLocationTag,
            locationName AS senderLocationName,
            ifcoSystemPartner AS senderLocationPartner,
            region AS senderLocationRegion,
            countryName AS senderLocationCountryName,
            dwellTimeDays AS senderLocationDwellTimeDays,
            arrivalTime AS senderArrivalTime,
            departureTime AS senderDepartureTime,

            LEAD(visitId) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverVisitId,
            LEAD(locationId) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationId,
            LEAD(longitude) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationLongitude,
            LEAD(latitude) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationLatitude,
            LEAD(locationType) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationType,
            LEAD(locationTag) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationTag,
            LEAD(locationName) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationName,
            LEAD(ifcoSystemPartner) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationPartner,
            LEAD(region) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationRegion,
            LEAD(countryName) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationCountryName,
            LEAD(dwellTimeDays) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverLocationDwellTimeDays,
            LEAD(arrivalTime) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverArrivalTime,
            LEAD(departureTime) OVER (PARTITION BY assetId ORDER BY departureTime) AS receiverDepartureTime,
            sensorId,
            sensorTechnology,
            attachedAt,
            attachedTill
        FROM visits
    )

SELECT * FROM transactions