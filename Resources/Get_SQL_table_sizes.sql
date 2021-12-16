/*
Fetch table name and size
for all Sandpit tables user has access to.

Useful for checking total number of tables and total space used.
To remove unneed tables and free up space:
	DROP TABLE [IDI_Sandpit].[DL-MAA20YY-XX].[table name goes here]
To compress large tables to reduce space:
	ALTER TABLE [IDI_Sandpit].[DL-MAA20YY-XX].[table name goes here] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
*/

USE IDI_Sandpit
GO

SELECT s.Name AS schmeaname
	,t.NAME AS tablename
	,p.rows AS rowcounts
	,SUM(a.total_pages) * 8 AS totalspaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas s on t.schema_id = s.schema_id
WHERE
t.name not like 'dt%'
and t.is_ms_shipped = 0
and i.object_id > 255
--and s.name = 'DL-MAA20YY-XX' /* optional filter to single schema */
group by t.name, s.name, p.rows, t.create_date, t.modify_date
order by s.name, t.name
