/*
Fetch view name
for all views user has access to.

Useful for checking total number of views.
To remove unneed views:
	USE [IDI_UserCode];
	GO
	DROP VIEW [DL-MAA20YY-XX].[view name goes here]
*/

USE [IDI_UserCode]
GO

SELECT s.Name AS schmeaname
	,t.NAME AS tablename
FROM sys.views t
LEFT OUTER JOIN sys.schemas s on t.schema_id = s.schema_id
--and s.name = 'DL-MAA20YY-XX' /* optional filter to single schema */
group by t.name, s.name
order by s.name, t.name
