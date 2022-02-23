/**************************************************************************************************
Title: Assemble research dataset for exemplar project

Inputs & Dependencies:
- "residential_population_2020.sql" --> [IDI_UserCode].[DL-MAA20XX-YY].[defn_residents]
- [IDI_Clean_20201020].[data].[personal_detail]
- "address_descriptors.sql" --> [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors]
- "annual_taxable_income.sql" --> [IDI_UserCode].[DL-MAA20XX-YY].[defn_annual_taxable_income]

Outputs:
- [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular]

Notes:
- This assembly has been designed to be equivalent to the output produced be the Dataset Assembly Tool
	(though the assembly process is different). A more polished SQL-only approach is possible.
 
History (reverse order):
2021-11-01 SA v1 for exemplar project
**************************************************************************************************/

/* remove table before recreating */
DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular];
GO

/* assemble data together */
SELECT r.snz_uid AS identity_column
	,'res' AS label_identity
	,CAST('2020-01-01' AS DATE) AS summary_period_start_date
	,CAST('2020-12-31' AS DATE) AS summary_period_end_date
	,'2020' AS label_summary_period
	/* demographics */
	,MAX(p.[snz_birth_year_nbr]) AS birth_year
	,MAX(IIF(p.[snz_ethnicity_grp4_nbr] = 1, 1, 0)) AS eth_asian
	,MAX(IIF(p.[snz_ethnicity_grp1_nbr] = 1, 1, 0)) AS eth_euorpean
	,MAX(IIF(p.[snz_ethnicity_grp2_nbr] = 1, 1, 0)) AS eth_maori
	,MAX(IIF(p.[snz_ethnicity_grp5_nbr] = 1, 1, 0)) AS eth_MELAA
	,MAX(IIF(p.[snz_ethnicity_grp6_nbr] = 1, 1, 0)) AS eth_other
	,MAX(IIF(p.[snz_ethnicity_grp3_nbr] = 1, 1, 0)) AS eth_pacific
	,MAX(IIF(p.[snz_sex_gender_code] = 1, 1, NULL)) AS [sex_code=1]
	,MAX(IIF(p.[snz_sex_gender_code] = 2, 1, NULL)) AS [sex_code=2]
	,MAX(IIF(p.[snz_sex_gender_code] = '', 1, NULL)) AS [sex_code=]
	/* address */
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Inland water', 1, NULL)) AS [urbal_rural=Inland water]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Inlet', 1, NULL)) AS [urbal_rural=Inlet]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Large urban area', 1, NULL)) AS [urbal_rural=Large urban area]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Major urban area', 1, NULL)) AS [urbal_rural=Major urban area]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Medium urban area', 1, NULL)) AS [urbal_rural=Medium urban area]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Oceanic', 1, NULL)) AS [urbal_rural=Oceanic]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Rural other', 1, NULL)) AS [urbal_rural=Rural other]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Rural settlement', 1, NULL)) AS [urbal_rural=Rural settlement]
	,MAX(IIF(a.[IUR2020_V1_00_NAME] = 'Small urban area', 1, NULL)) AS [urbal_rural=Small urban area]
	,MAX(a.[ant_region_code]) AS region
	,MAX(a.[SA22020_V1_00]) AS SA2
	/* income */
	,SUM(i.[inc_cal_yr_tot_yr_amt]) AS total_taxable_income
INTO [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular]
FROM [IDI_UserCode].[DL-MAA20XX-YY].[defn_residents] AS r
LEFT JOIN [IDI_Clean_20201020].[data].[personal_detail] AS p
ON r.snz_uid = p.snz_uid
LEFT JOIN [IDI_Sandpit].[DL-MAA20XX-YY].[defn_address_descriptors] AS a
ON r.snz_uid = a.snz_uid
LEFT JOIN [IDI_UserCode].[DL-MAA20XX-YY].[defn_annual_taxable_income] AS i
ON r.snz_uid = i.snz_uid
AND i.year_start <= '2020-12-31'
AND '2020-01-01' <= i.year_end
GROUP BY r.snz_uid
GO

/* index */
CREATE NONCLUSTERED INDEX my_index_name ON [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular] (identity_column);
GO
/* compress */
ALTER TABLE [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
