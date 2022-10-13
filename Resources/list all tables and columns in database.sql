/*
List all contents of a database

For the given database,
- list every schema
  - within every schema, list every table
    - within every table, list every column
      - also give column attributes
*/

USE IDI_Clean_202206
GO

SELECT s.name AS schema_name
	,t.name AS table_name
	,c.name AS column_name
	,c.column_id
	,ty.name AS data_type
	,c.max_length
	,c.is_nullable
FROM sys.tables AS t
LEFT JOIN sys.schemas AS s
ON t.schema_id = s.schema_id
LEFT JOIN sys.columns AS c
ON t.object_id = c.object_id
LEFT JOIN sys.types AS ty
ON c.user_type_id = ty.user_type_id
