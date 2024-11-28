{{config(materialized='view')}}

with stg_rtina_asset as (select Id as id,
       IsOnSite                  as id_on_site,
       TagId                     as tag_id,
       AssetGroupId              as asset_group_id,
       HomeSiteId                as home_site_id,
       UserDefinedAttribute1     as user_defined_attribute_1,
       UserDefinedAttribute2     as user_defined_attribute_2,
       UserDefinedAttribute3     as user_defined_attribute_3,
       UserDefinedValue          as user_defined_value,
       DateDisabled              as date_disabled,
       OnSiteChanged             as on_site_changed,
       OnSiteSeen                as on_site_seen,
       DateCreated               as date_created,
       UserDefinedAttribute4     as user_defined_attribute_4,
       UserDefinedAttribute5     as user_defined_attribute_5,
       LastAssetLocationId       as last_asset_location_id,
       LastAssetStatusHistoryId  as last_asset_status_history_id,
       LastAssetShipmentDetailId as last_asset_shipment_detail_id,
       Id_cleansed               as id_cleansed,
       Asset_SID                 as asset_sid,
       columnHash_DLS            as column_hash_dls,
       sourceFile                as source_file,
       historyStatus             as history_status,
       deletedFlg                as deleted_flg,
       validFrom_DLS             as valid_from_dls,
       validTo_DLS               as valid_to_dls
from {{ source('rtina_adls_data', 'asset')}})

select * from stg_rtina_asset
