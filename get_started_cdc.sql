USE master;
GO
IF db_id('Demo') IS NOT NULL 
BEGIN
USE demo;
EXEC sys.sp_cdc_disable_db;
END
GO
USE master;
IF db_id('Demo') IS NOT NULL DROP DATABASE demo;
CREATE DATABASE demo;
GO
USE demo;
GO
EXEC sys.sp_cdc_enable_db
GO
CREATE TABLE parent_table(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT pk_parent_table PRIMARY KEY CLUSTERED,
	parent_name nvarchar(50) NOT NULL CONSTRAINT uq_parent_table_parent_name UNIQUE NONCLUSTERED,
	parent_value int NOT NULL,
	added_timestamp datetime2(7) NOT NULL CONSTRAINT df_parent_table_added_tamestamp DEFAULT(sysutcdatetime()),
	last_modify_timestamp datetime2(7) NOT NULL CONSTRAINT df_parent_table_last_modify_tamestamp DEFAULT(sysutcdatetime())
)
GO
CREATE TABLE child_table(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT pk_child_table PRIMARY KEY NONCLUSTERED,
	parent_id int NOT NULL CONSTRAINT fk_child_table_parent_table FOREIGN KEY REFERENCES parent_table(id),
	current_parent_value int NOT NULL,
	added_timestamp datetime2(7) NOT NULL CONSTRAINT df_child_table_added_tamestamp DEFAULT(sysutcdatetime()),
	last_modify_timestamp datetime2(7) NOT NULL CONSTRAINT df_child_table_last_modify_tamestamp DEFAULT(sysutcdatetime())
)
GO
CREATE TRIGGER parent_table_update_trigger
ON parent_table AFTER UPDATE AS
BEGIN
SET NOCOUNT ON;
IF (UPDATE(parent_name) OR UPDATE(parent_value)) AND NOT UPDATE(last_modify_timestamp)
UPDATE target
SET last_modify_timestamp = sysutcdatetime()
FROM parent_table target INNER JOIN inserted ON target.id = inserted.id;
END
GO
CREATE TRIGGER child_table_update_trigger
ON child_table AFTER UPDATE AS
BEGIN
SET NOCOUNT ON;
IF (UPDATE(parent_id) OR UPDATE(current_parent_value)) AND NOT UPDATE(last_modify_timestamp)
UPDATE target
SET last_modify_timestamp = sysutcdatetime()
FROM child_table target INNER JOIN inserted ON target.id = inserted.id;
END
GO
EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'parent_table',  
@role_name     = N'cdc_role',  
@supports_net_changes = 1;
GO
EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'child_table',  
@role_name     = N'cdc_role',  
@supports_net_changes = 1;
GO
CHECKPOINT
GO
BACKUP DATABASE demo  TO DISK = 'NUL'
GO
BACKUP LOG demo  TO DISK = 'NUL'
GO
INSERT INTO parent_table(parent_name, parent_value) VALUES ('alpha', 10), ('bravo', 20), ('charlie', 30), ('delta', 40);
GO
SELECT * FROM parent_table
GO
SELECT * FROM parent_table WHERE parent_name = 'bravo'
WAITFOR DELAY '00:00:15.000'
UPDATE parent_table SET parent_value += 1 WHERE parent_name = 'bravo'
SELECT * FROM parent_table WHERE parent_name = 'bravo'
GO
SELECT * FROM parent_table WHERE parent_name = 'charlie';
--DISABLE TRIGGER parent_table_update_trigger ON parent_table;
UPDATE parent_table SET parent_value += 1, last_modify_timestamp = sysutcdatetime() WHERE parent_name = 'charlie';
--ENABLE TRIGGER parent_table_update_trigger ON parent_table;
SELECT * FROM parent_table WHERE parent_name = 'charlie'
GO
WAITFOR DELAY '00:00:15.000'
SELECT * FROM cdc.dbo_parent_table_CT
GO
