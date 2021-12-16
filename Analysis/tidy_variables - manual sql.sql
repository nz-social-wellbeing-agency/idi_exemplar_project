/**************************************************************************************************
Title: Assemble research dataset for exemplar project

Inputs & Dependencies:
- [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular]

Outputs:
- [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy]

Notes:
- This tidy script has been desgined to be equivalent to the R tidy_variables script.
 
History (reverse order):
2021-11-01 SA v1 for exemplar project
**************************************************************************************************/

/* remove table before recreating */
DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy];
GO

/* assemble data together */
SELECT identity_column
	/* combine multi-column variables */
	,CASE
		WHEN [sex_code=1] = 1 THEN 1
		WHEN [sex_code=2] = 1 THEN 2
		ELSE NULL END AS sex_code
	,CASE
		WHEN [urbal_rural=Inland water] = 1 THEN 'Inland water'
		WHEN [urbal_rural=Inlet] = 1 THEN 'Inlet'
		WHEN [urbal_rural=Large urban area] = 1 THEN 'Large urban area'
		WHEN [urbal_rural=Major urban area] = 1 THEN 'Major urban area'
		WHEN [urbal_rural=Medium urban area] = 1 THEN 'Medium urban area'
		WHEN [urbal_rural=Oceanic] = 1 THEN 'Oceanic'
		WHEN [urbal_rural=Rural other] = 1 THEN 'Rural other'
		WHEN [urbal_rural=Rural settlement] = 1 THEN 'Rural settlement'
		WHEN [urbal_rural=Small urban area] = 1 THEN 'Small urban area'
		ELSE NULL END AS urban_rural

	/* clean income */
	,total_taxable_income
	,ISNULL(total_taxable_income, 0) AS income_w_zeros
	,IIF(total_taxable_income > 1, total_taxable_income, NULL) AS income_positive
	,IIF(total_taxable_income > 1, 1, 0) AS income_any

	/* age */
	,birth_year
	,2020 - birth_year AS age
	,CASE
		WHEN 2020 - birth_year BETWEEN  0 AND  9 THEN '00_to_09'
		WHEN 2020 - birth_year BETWEEN 10 AND 19 THEN '10_to_19'
		WHEN 2020 - birth_year BETWEEN 20 AND 29 THEN '20_to_29'
		WHEN 2020 - birth_year BETWEEN 30 AND 39 THEN '30_to_39'
		WHEN 2020 - birth_year BETWEEN 40 AND 49 THEN '40_to_49'
		WHEN 2020 - birth_year BETWEEN 50 AND 59 THEN '50_to_59'
		WHEN 2020 - birth_year BETWEEN 60 AND 69 THEN '60_to_69'
		WHEN 2020 - birth_year BETWEEN 70 AND 79 THEN '70_to_79'
		WHEN 2020 - birth_year >= 80 THEN '80_up'
		ELSE NULL END AS age_cat

	/* remaining columns */
	,eth_asian
	,eth_euorpean
	,eth_maori
	,eth_MELAA
	,eth_other
	,eth_pacific
	,region
	,SA2
INTO [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy]
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_rectangular]
WHERE region IS NOT NULL
GO

/* index */
CREATE NONCLUSTERED INDEX my_index_name ON [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy] (identity_column);
GO
/* compress */
ALTER TABLE [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
