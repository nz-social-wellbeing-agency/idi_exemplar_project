/*
Assessing core income tables
2021-10-26

Four possible tables:
- [IDI_Clean_20201020].[data].[income_cal_yr_summary]
- [IDI_Clean_20201020].[data].[income_cal_yr]
- [IDI_Clean_20201020].[data].[income_tax_yr_summary]
- [IDI_Clean_20201020].[data].[income_tax_yr]

Checked:
- consistency between tax and calendar year
- consistency between income and income_summary tables
- uniqueness of records in calendar year table

Conclusion:
- income calendar year table is suitable for our purposes
*/

/*******************************************************************
income source and withholding type
*/
SELECT [inc_cal_yr_income_source_code]
      ,[inc_cal_yr_withholding_type_code]
      ,COUNT(*) AS num
FROM [IDI_Clean_20201020].[data].[income_cal_yr]
GROUP BY [inc_cal_yr_income_source_code], [inc_cal_yr_withholding_type_code];
/*
income source = W&S, WHP, BEN, etc. for type of income
withholding type = P and W. P = primary most likely.
*/

/*******************************************************************
one record per person
*/
SELECT num_records, COUNT(*) AS num_people
FROM (

SELECT [inc_cal_yr_year_nbr]
      ,[snz_uid]
      ,[snz_employer_ird_uid]
      ,[inc_cal_yr_income_source_code]
      ,[inc_cal_yr_withholding_type_code]
	  ,COUNT(*) AS num_records
FROM [IDI_Clean_20201020].[data].[income_cal_yr]
GROUP BY [inc_cal_yr_year_nbr]
      ,[snz_uid]
      ,[snz_employer_ird_uid]
      ,[inc_cal_yr_income_source_code]
      ,[inc_cal_yr_withholding_type_code]

) k
GROUP BY num_records;
/*
year, person, employer, income source, and withholding type uniquely define each record
*/

/*******************************************************************
multiple employers types
*/
SELECT num_employers, COUNT(*) AS num_people
FROM (

SELECT [inc_cal_yr_year_nbr]
      ,[snz_uid]
      ,COUNT(DISTINCT [snz_employer_ird_uid]) AS num_employers
FROM [IDI_Clean_20201020].[data].[income_cal_yr]
WHERE [inc_cal_yr_income_source_code] = 'W&S'
GROUP BY [inc_cal_yr_year_nbr]
      ,[snz_uid]
      
) k
GROUP BY num_employers
ORDER BY num_employers;
/*
Vast majority of people have fewer than 6 employers per year.
But we do observe numbers of employers up to 100.
A handful of rare cases report 10000+ employers in a single year.
This may merit further investigation.
*/

/*******************************************************************
Check consistency of calendar_year and calendar_year_summary tables
*/
WITH
total_income AS (
	SELECT [inc_cal_yr_year_nbr], [snz_uid], SUM([inc_cal_yr_tot_yr_amt]) AS total_income
	FROM [IDI_Clean_20201020].[data].[income_cal_yr]
	GROUP BY [inc_cal_yr_year_nbr], [snz_uid]
),
total_income_summary AS (
	SELECT [inc_cal_yr_sum_year_nbr], [snz_uid], SUM([inc_cal_yr_sum_all_srces_tot_amt]) AS total_income_summary
	FROM [IDI_Clean_20201020].[data].[income_cal_yr_summary]
	GROUP BY [inc_cal_yr_sum_year_nbr], [snz_uid]
)
SELECT IIF(ABS(total_income - total_income_summary) < 1, 'Y', 'N') AS matches, COUNT(*) AS num
FROM total_income AS t1
FULL OUTER JOIN total_income_summary AS t2
ON t1.[inc_cal_yr_year_nbr] = t2.[inc_cal_yr_sum_year_nbr]
AND t1.snz_uid = t2.snz_uid
GROUP BY IIF(ABS(total_income - total_income_summary) < 1, 'Y', 'N');
/*
Results report perfect consistency.
(We only check to ABS < 1 as differences of a few cents are irrelevant)
*/

/*******************************************************************
Check consistency of calendar_year and tax_year tables
*/
WITH
part_year_cal AS (
	SELECT [inc_cal_yr_year_nbr]
		  ,[snz_uid]
		  ,[snz_employer_ird_uid]
		  ,SUM([inc_cal_yr_mth_01_amt]) AS mnth01
		  ,SUM([inc_cal_yr_mth_02_amt]) AS mnth02
		  ,SUM([inc_cal_yr_mth_03_amt]) AS mnth03
	FROM [IDI_Clean_20201020].[data].[income_cal_yr]
	WHERE [inc_cal_yr_income_source_code] = 'W&S'
	GROUP BY [inc_cal_yr_year_nbr], [snz_uid], [snz_employer_ird_uid]
),
part_year_tax AS (
	SELECT [inc_tax_yr_year_nbr]
		  ,[snz_uid]
		  ,[snz_employer_ird_uid]
		  ,SUM([inc_tax_yr_mth_10_amt]) AS mnth10
		  ,SUM([inc_tax_yr_mth_11_amt]) AS mnth11
		  ,SUM([inc_tax_yr_mth_12_amt]) AS mnth12
	FROM [IDI_Clean_20201020].[data].[income_tax_yr]
	WHERE [inc_tax_yr_income_source_code] = 'W&S'
	GROUP BY [inc_tax_yr_year_nbr], [snz_uid], [snz_employer_ird_uid]
)
SELECT IIF(ABS(ISNULL(t.mnth10, 0) - ISNULL(c.mnth01, 0)) < 10, 'Y', 'N') AS match01
	,IIF(ABS(ISNULL(t.mnth11, 0) - ISNULL(c.mnth02, 0)) < 10, 'Y', 'N') AS match02
	,IIF(ABS(ISNULL(t.mnth12, 0) - ISNULL(c.mnth03, 0)) < 10, 'Y', 'N') AS match03
	,COUNT(*) AS num
FROM part_year_cal AS c
FULL OUTER JOIN part_year_tax AS t
ON c.snz_uid = t.snz_uid
AND c.[inc_cal_yr_year_nbr] = t.[inc_tax_yr_year_nbr]
AND c.[snz_employer_ird_uid] = t.[snz_employer_ird_uid]
GROUP BY IIF(ABS(ISNULL(t.mnth10, 0) - ISNULL(c.mnth01, 0)) < 10, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth11, 0) - ISNULL(c.mnth02, 0)) < 10, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth12, 0) - ISNULL(c.mnth03, 0)) < 10, 'Y', 'N');

/*
The following code checks the second half/three-quarters of the year
*/
WITH
part_year_cal AS (
	SELECT [inc_cal_yr_year_nbr]
		  ,[snz_uid]
		  ,[snz_employer_ird_uid]
		  ,SUM([inc_cal_yr_mth_04_amt]) AS mnth04
		  ,SUM([inc_cal_yr_mth_05_amt]) AS mnth05
		  ,SUM([inc_cal_yr_mth_06_amt]) AS mnth06
		  ,SUM([inc_cal_yr_mth_07_amt]) AS mnth07
		  ,SUM([inc_cal_yr_mth_08_amt]) AS mnth08
		  ,SUM([inc_cal_yr_mth_09_amt]) AS mnth09
		  ,SUM([inc_cal_yr_mth_10_amt]) AS mnth10
		  ,SUM([inc_cal_yr_mth_11_amt]) AS mnth11
		  ,SUM([inc_cal_yr_mth_12_amt]) AS mnth12
	FROM [IDI_Clean_20201020].[data].[income_cal_yr]
	GROUP BY [inc_cal_yr_year_nbr], [snz_uid], [snz_employer_ird_uid]
),
part_year_tax AS (
	SELECT [inc_tax_yr_year_nbr]
		  ,[snz_uid]
		  ,[snz_employer_ird_uid]
		  ,SUM([inc_tax_yr_mth_01_amt]) AS mnth01
		  ,SUM([inc_tax_yr_mth_02_amt]) AS mnth02
		  ,SUM([inc_tax_yr_mth_03_amt]) AS mnth03
		  ,SUM([inc_tax_yr_mth_04_amt]) AS mnth04
		  ,SUM([inc_tax_yr_mth_05_amt]) AS mnth05
		  ,SUM([inc_tax_yr_mth_06_amt]) AS mnth06
		  ,SUM([inc_tax_yr_mth_07_amt]) AS mnth07
		  ,SUM([inc_tax_yr_mth_08_amt]) AS mnth08
		  ,SUM([inc_tax_yr_mth_09_amt]) AS mnth09
	FROM [IDI_Clean_20201020].[data].[income_tax_yr]
	GROUP BY [inc_tax_yr_year_nbr], [snz_uid], [snz_employer_ird_uid]
)
SELECT IIF(ABS(ISNULL(t.mnth01, 0) - ISNULL(c.mnth04, 0)) < 1, 'Y', 'N') AS match04
	,IIF(ABS(ISNULL(t.mnth02, 0) - ISNULL(c.mnth05, 0)) < 1, 'Y', 'N') AS match05
	,IIF(ABS(ISNULL(t.mnth03, 0) - ISNULL(c.mnth06, 0)) < 1, 'Y', 'N') AS match06
	,IIF(ABS(ISNULL(t.mnth04, 0) - ISNULL(c.mnth07, 0)) < 1, 'Y', 'N') AS match07
	,IIF(ABS(ISNULL(t.mnth05, 0) - ISNULL(c.mnth08, 0)) < 1, 'Y', 'N') AS match08
	,IIF(ABS(ISNULL(t.mnth06, 0) - ISNULL(c.mnth09, 0)) < 1, 'Y', 'N') AS match09
	,IIF(ABS(ISNULL(t.mnth07, 0) - ISNULL(c.mnth10, 0)) < 1, 'Y', 'N') AS match10
	,IIF(ABS(ISNULL(t.mnth08, 0) - ISNULL(c.mnth11, 0)) < 1, 'Y', 'N') AS match11
	,IIF(ABS(ISNULL(t.mnth09, 0) - ISNULL(c.mnth12, 0)) < 1, 'Y', 'N') AS match12
	,COUNT(*) AS num
FROM part_year_cal AS c
FULL OUTER JOIN part_year_tax AS t
ON c.snz_uid = t.snz_uid
AND c.[inc_cal_yr_year_nbr] = t.[inc_tax_yr_year_nbr] + 1
AND c.[snz_employer_ird_uid] = t.[snz_employer_ird_uid]
GROUP BY IIF(ABS(ISNULL(t.mnth01, 0) - ISNULL(c.mnth04, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth02, 0) - ISNULL(c.mnth05, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth03, 0) - ISNULL(c.mnth06, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth04, 0) - ISNULL(c.mnth07, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth05, 0) - ISNULL(c.mnth08, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth06, 0) - ISNULL(c.mnth09, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth07, 0) - ISNULL(c.mnth10, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth08, 0) - ISNULL(c.mnth11, 0)) < 1, 'Y', 'N')
	,IIF(ABS(ISNULL(t.mnth09, 0) - ISNULL(c.mnth12, 0)) < 1, 'Y', 'N')
/*
Perfect consistency
But note that people with no income vary between tax
and calendar year. Some people with zero income are included in
each table while others are excluded. Presumably this is due to
income in the non-overlapping/non-compared part of the table.
*/
