/**************************************************************************************************
Title: 2020 Annual Taxable Income

Inputs & Dependencies:
- [IDI_Clean].[data].[income_cal_yr]
Outputs:
- [IDI_UserCode].[DL-MAA20XX-YY].[defn_annual_taxable_income]

Description:
Annual taxable income for calendar years.

Intended purpose:
Value of income, indicator of income, determining types of income.

Notes:
1) Not all income is taxable. Supplementary benefits, hardship grants, and tax credits (e.g.
	Working for Families and Donation tax credits) are forms of income that are not taxable.
	Hence these forms of income and the amounts received do not appear in this definition.

Parameters & Present values:
  Current refresh = 20201020
  Prefix = defn_
  Project schema = [DL-MAA20XX-YY]
   
Issues:
 
History (reverse order):
2021-10-26 SA v1 for exemplar project
**************************************************************************************************/

/* Establish database for writing views */
USE IDI_UserCode
GO

/* Remove view before recreating */
DROP VIEW IF EXISTS [DL-MAA20XX-YY].[defn_annual_taxable_income];
GO

/* Create definition of taxible income */
CREATE VIEW [DL-MAA20XX-YY].[defn_annual_taxable_income] AS
SELECT [inc_cal_yr_year_nbr]
      ,[snz_uid]
      ,[snz_ird_uid]
      ,[snz_employer_ird_uid]
      ,[inc_cal_yr_income_source_code]
      ,[inc_cal_yr_withholding_type_code]
      ,[inc_cal_yr_mth_01_amt]
      ,[inc_cal_yr_mth_02_amt]
      ,[inc_cal_yr_mth_03_amt]
      ,[inc_cal_yr_mth_04_amt]
      ,[inc_cal_yr_mth_05_amt]
      ,[inc_cal_yr_mth_06_amt]
      ,[inc_cal_yr_mth_07_amt]
      ,[inc_cal_yr_mth_08_amt]
      ,[inc_cal_yr_mth_09_amt]
      ,[inc_cal_yr_mth_10_amt]
      ,[inc_cal_yr_mth_11_amt]
      ,[inc_cal_yr_mth_12_amt]
      ,[inc_cal_yr_tot_yr_amt]
	  ,DATEFROMPARTS([inc_cal_yr_year_nbr], 1, 1) AS year_start
	  ,DATEFROMPARTS([inc_cal_yr_year_nbr], 12, 31) AS year_end
	  ,DATEFROMPARTS([inc_cal_yr_year_nbr], 6, 30) AS year_mid
FROM [IDI_Clean_20201020].[data].[income_cal_yr];
GO
