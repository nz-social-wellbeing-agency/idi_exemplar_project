/**************************************************************************************************
Title: Neighbourhood descriptors

Inputs & Dependencies:
- [IDI_Clean].[data].[address_notification]
- [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019]
- [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_current_higher_geography]
Outputs:
- [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors]

Description:
Summary description of a person's neighbourhood including: region, SA2, and urban/rural.

Intended purpose:
Identifying the characteristics of where a person lives at a specific point in time.
Producing summaries by region.

Notes:
1) Address information in the IDI is not of sufficient quality to determine who shares an address. We would
	also be cautious about claiming that a person lives at a specific address on a specific date. However, we
	are confident using address information for the purpose of "this location has the characteristics of the
	place this person lives", and "this person has the characteristics of the people who live in this location".

2) The year of the meshblock codes used for the address notification could not be found in data documentation.
	The quality of several different years/joins were tried the final choice represents the best join available
	at time of creation.
	Another cause for this join being imperfect is not every meshblock contains residential addresses (e.g. some
	CBD areas may contain hotels but not residential addresses, and some meshblocks are uninhabited - such as 
	mountains or ocean areas).
	Re-assessment of which meshblock code to use for joining to address_notifications is recommended each refresh.

3) For simplicity this table considers address at a specific date.

Parameters & Present values:
  Current refresh = 20201020
  Prefix = defn_
  Project schema = [DL-MAA20XX-YY]
  Current 'as-at' date = 2020-06-30
   
Issues:

History (reverse order):
2021-10-26 SA v1 for exemplar project
**************************************************************************************************/

/* Remove table before (re)creating */
DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors];
GO

/* Create address table for specific date */
SELECT a.[snz_uid]
      ,a.[ant_notification_date]
      ,a.[ant_replacement_date]
      ,a.[snz_idi_address_register_uid]
	  ,CAST(a.[ant_region_code] AS INT) AS [ant_region_code]
	  ,b.[IUR2020_V1_00] -- urban/rural classification
      ,b.[IUR2020_V1_00_NAME]
	  ,CAST(b.[SA22020_V1_00] AS INT) AS [SA22020_V1_00] -- Statistical Area 2 (neighbourhood)
	  ,b.[SA22020_V1_00_NAME]
INTO [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors]
FROM [IDI_Clean_20201020].[data].[address_notification] AS a
INNER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS conc
ON conc.[MB2019_code] = a.[ant_meshblock_code]
LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_higher_geography_2020_V1_00] AS b
ON conc.[MB2018_code] = b.[MB2020_V1_00]
WHERE '2020-06-30' BETWEEN [ant_notification_date] AND [ant_replacement_date] -- at 2020-06-30
AND a.[ant_meshblock_code] IS NOT NULL
GO

/* Add index */
CREATE NONCLUSTERED INDEX my_index_name ON [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors] (snz_uid);
GO

/* Compress final table to save space */
ALTER TABLE [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
