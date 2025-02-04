-- This is the default template for models

WITH 

    transaction_patterns_seed AS (
        SELECT
            transactionId,
            senderLocationTag,
            receiverLocationTag,
            transactionType,
            region,
            partner,
            CAST(senderLocationGroupId AS INT) AS senderLocationGroupId,
            CAST(receiverLocationGroupId AS INT) AS receiverLocationGroupId
        FROM {{ ref('transaction_patterns') }}
    )

SELECT * FROM transaction_patterns_seed



