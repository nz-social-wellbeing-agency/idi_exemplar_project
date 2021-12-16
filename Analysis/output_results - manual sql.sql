/**************************************************************************************************
Title: Output results for exemplar project

Inputs & Dependencies:
- [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy]

Outputs:
- Two summary tables to be copied to Excel

Notes:
- This tidy script has been desgined to be equivalent to the R output_results script.
 
History (reverse order):
2021-11-01 SA v1 for exemplar project
**************************************************************************************************/

/* age summary */
SELECT region, urban_rural, age_cat, COUNT(*) AS num
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy]
GROUP BY region, urban_rural, age_cat;
GO

/* income summary */
SELECT region, urban_rural, COUNT(income_positive) AS num_w_income, SUM(income_positive) AS total_income
FROM [IDI_Sandpit].[DL-MAA20XX-YY].[exemplar_tidy]
GROUP BY region, urban_rural;
GO
