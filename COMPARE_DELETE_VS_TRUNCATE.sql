USE master
IF db_id('trudel') IS NOT NULL DROP DATABASE trudel
CREATE DATABASE trudel
GO
USE trudel
GO
CREATE TABLE junk(id int identity(1,1), payload_nvarchar nvarchar(max), payload_timestamp datetime2(7) DEFAULT(sysutcdatetime()))
GO
INSERT INTO junk(payload_nvarchar)
SELECT TOP 20 QUOTENAME(o.name) + '.' + QUOTENAME(c.name, '(') FROM master.sys.sysobjects o INNER JOIN master.sys.syscolumns c ON o.id = c.id
GO
CHECKPOINT
BACKUP DATABASE trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
GO
SELECT cast('DELETE' as varchar(max)) AS op, cast('BEFORE' as varchar(max)) AS phase, COUNT(*) AS cnt, sysutcdatetime() AS optime INTO #checkboard FROM sys.fn_dblog(NULL, NULL)
GO
DELETE FROM junk
GO
INSERT INTO #checkboard
SELECT 'DELETE', 'AFTER', COUNT(*), sysutcdatetime() FROM sys.fn_dblog(NULL, NULL)
GO
INSERT INTO junk(payload_nvarchar)
SELECT TOP 20 QUOTENAME(o.name) + '.' + QUOTENAME(c.name, '(') FROM master.sys.sysobjects o INNER JOIN master.sys.syscolumns c ON o.id = c.id
GO
CHECKPOINT
BACKUP DATABASE trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
CHECKPOINT
BACKUP LOG trudel TO DISK = 'NUL'
GO
INSERT INTO #checkboard
SELECT 'TRUNCATE', 'BEFORE', COUNT(*), sysutcdatetime() FROM sys.fn_dblog(NULL, NULL)
GO
TRUNCATE TABLE junk
GO
INSERT INTO #checkboard
SELECT 'TRUNCATE', 'AFTER', COUNT(*), sysutcdatetime() FROM sys.fn_dblog(NULL, NULL)
GO
SELECT * FROM #checkboard
DROP TABLE #checkboard
