DECLARE
	@schema_name sysname	= 'dbo',
	@table_name sysname		= 'sample_table',
	@key_column sysname		= 'id';
DECLARE
	@columns varchar(max),
	@stmt varchar(max) = 'SELECT * FROM {@schema_name}.{@table_name} UNPIVOT(val FOR grp IN ({@columns})) AS u';
SELECT @columns = STRING_AGG(QUOTENAME(COLUMN_NAME), ',') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = @table_name AND COLUMN_NAME != @key_column;
SET @stmt = REPLACE(REPLACE(REPLACE(@stmt, '{@columns}', @columns), '{@schema_name}', @schema_name), '{@table_name}', @table_name);
EXEC (@stmt)
