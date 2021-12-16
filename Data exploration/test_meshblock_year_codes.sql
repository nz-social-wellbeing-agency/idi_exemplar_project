/*
Testing which meshblock year/codes to use
2021-10-26

Conclusion:
- 2018 and 2019 results are very similar
- 2017 and older results are clearly worse matches
- the leading (undated) meshblock codes are most likely the 2019 codes
- we can use either 2018 or 2019 for our purposes
*/

/* table of meshblock codes for reuse */
DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list]
GO

SELECT DISTINCT ant_meshblock_code
INTO [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list]
FROM [IDI_Clean_20201020].[data].[address_notification]
WHERE '2020-06-30' BETWEEN [ant_notification_date] AND [ant_replacement_date]
AND [ant_meshblock_code] IS NOT NULL;

/* 2019 */
SELECT match_type_2019, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.[MB2019_code] IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_2019
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.[MB2019_code] = a.[ant_meshblock_code]

) k
GROUP BY match_type_2019

/* 2018 */
SELECT match_type_2018, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.MB2018_code IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_2018
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.MB2018_code = a.[ant_meshblock_code]

) k
GROUP BY match_type_2018

/* 2017 */
SELECT match_type_2017, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.MB2017_code IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_2017
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.MB2017_code = a.[ant_meshblock_code]

) k
GROUP BY match_type_2017

/* 2016 */
SELECT match_type_2016, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.MB2016_code IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_2016
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.MB2016_code = a.[ant_meshblock_code]

) k
GROUP BY match_type_2016

/* census */
SELECT match_type_census, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.census_meshblock_code IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_census
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.census_meshblock_code = a.[ant_meshblock_code]

) k
GROUP BY match_type_census

/* leading MB code */
SELECT match_type_lead, COUNT(*) AS num
FROM (

SELECT CASE
	WHEN a.[ant_meshblock_code] IS NULL THEN 'c only'
	WHEN c.meshblock_code IS NULL THEN 'a only'
	ELSE 'both' END AS match_type_lead
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list] AS a
FULL OUTER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_concordance_2019] AS c
ON c.meshblock_code = a.[ant_meshblock_code]

) k
GROUP BY match_type_lead

/* tidy up */
/* table of meshblock codes for reuse */
DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA20XX-YY].[tmp_MB_list]
GO
