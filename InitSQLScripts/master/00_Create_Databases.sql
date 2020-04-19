USE MASTER 
GO

DECLARE @DySQL NVARCHAR(MAX) 
DECLARE @DatabaseName sysname ='tSQLcron'


IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        SET @DySQL = 'CREATE DATABASE '+QUOTENAME(@DatabaseName)
        EXEC (@DySQL)
    END

SET @DySQL = 'ALTER DATABASE '+QUOTENAME(@DatabaseName) + ' SET RECOVERY SIMPLE '

IF EXISTS (SELECT * FROM sys.databases WHERE name = @DatabaseName)
    EXEC (@DySQL)
