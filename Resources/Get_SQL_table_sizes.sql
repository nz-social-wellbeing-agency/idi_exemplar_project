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

SELECT s.Name AS schema_name
	,t.NAME AS table_name
	,t.create_date
	,t.modify_date
	,p.rows AS row_count
	,8 * SUM(a.total_pages) AS total_space_KB
	,8.0 * SUM(a.total_pages) / 1024.0 / 1024 AS total_space_GB
FROM sys.tables AS t
INNER JOIN sys.indexes AS i
ON t.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.partitions AS p
ON i.OBJECT_ID = p.OBJECT_ID
AND i.index_id = p.index_id
INNER JOIN sys.allocation_units AS a
ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas AS s
ON t.schema_id = s.schema_id
WHERE t.name NOT LIKE 'dt%'
AND t.is_ms_shipped = 0
AND i.object_id > 255
-- AND s.NAME = 'DL-MAA20XX-YY' /* optional filter to just schema of interest */
GROUP BY s.name, t.name, p.rows, t.create_date, t.modify_date
ORDER BY s.name, t.name
