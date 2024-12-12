{% docs asset_status %}

# asset_status

## Description
The `asset_status` model is an **ephemeral** model that enhances the asset status history by joining it with status metadata. It combines data from the following source models:
- **`src_asset_status_history`**: Provides the raw asset status history data.
- **`src_status`**: Supplies metadata, including status names and descriptions.

This model adds human-readable status details (`status_name` and `status_description`) to the asset status history for better usability.

## Logic
1. Fetches asset status history from `src_asset_status_history`.
2. Retrieves status metadata from `src_status`.
3. Joins the two datasets on `status_id` to enhance the asset status history with descriptive details.

---

## Materialization
This model uses **ephemeral** materialization, meaning it is not materialized in the database but is used as an intermediate model within other transformations.

{% enddocs %}