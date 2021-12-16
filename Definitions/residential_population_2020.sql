/**************************************************************************************************
Title: 2020 Residential population

Inputs & Dependencies:
- [IDI_Clean].[data].[snz_res_pop]
Outputs:
- [IDI_UserCode].[DL-MAA2020-01].[defn_residents]

Description:
List of snz_uid values for those identities that are part of the
Estimated Residential Population (ERP) of New Zealand in 2020.

Intended purpose:
Producing summary statistics for the entire population.

Notes:

Parameters & Present values:
  Current refresh = 20201020
  Prefix = defn_
  Project schema = [DL-MAA2020-01]
   
Issues:
 
History (reverse order):
2021-10-26 SA v1 for exemplar project
**************************************************************************************************/

/* Establish database for writing views */
USE IDI_UserCode
GO

/* Remove view before recreating */
DROP VIEW IF EXISTS [DL-MAA2020-01].[defn_residents];
GO

/* Create definition of 2020 residential population */
CREATE VIEW [DL-MAA2020-01].[defn_residents] AS
SELECT [snz_uid]
	  ,srp_ref_date
FROM [IDI_Clean_20201020].[data].[snz_res_pop]
WHERE YEAR(srp_ref_date) = 2020;
GO
