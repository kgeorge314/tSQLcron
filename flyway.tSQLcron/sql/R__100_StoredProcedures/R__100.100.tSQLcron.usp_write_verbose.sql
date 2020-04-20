CREATE OR ALTER PROCEDURE [tSQLcron].[usp_write_verbose] 
	@Key     NVARCHAR(256),
	@Value   SQL_VARIANT  ,
    @Verbose BIT = 0
AS
/*******************************************************************************
---
Name: "[tSQLcron].[usp_write_verbose]"
Desciption: |
    A utility stored procedure that can be used to display debug/verbose messages
    to the message stream with timestamp information.
    
    The procedure tries to mock powershell's `-verbose` and `$VerbosePreference`.
    
    `-verbose` would be equivalent to `@Verbose = 1` and `$VerbosePreference` uses
    the context info from the session.

Parameters: |
	- @Key       : a 256 char limit that can be anything, commonly used values would be 
                  `INFO` , `DEBUG` etc 
	- @Value     : The value to display
	- @Verbose   : To force display
Notes: |
    To show messages from `[tSQLcron].[usp_write_verbose]` set the session
    contenxt info to `VERBOSE` 

    ```sql
        DECLARE @CTX VARBINARY(128) = CAST(N'VERBOSE' as VARBINARY(128));
        SET CONTEXT_INFO @CTX;  
    ```

Examples: |
    DECLARE @id INT = 1234;

    EXEC [tSQLcron].[usp_write_verbose] 'INFO' , '@ID is'
    EXEC [tSQLcron].[usp_write_verbose] '@id' , @id

...
********************************************************************************/
BEGIN
    -- ONLY Write Output if @Verbose is supplied 
    -- OR CONTEXT_INFO is set to 'VERBOSE'
    
    IF(@Verbose = 0 OR @Verbose IS NULL)
        IF(ISNULL(CAST(CONTEXT_INFO() as NVARCHAR(128)),N'') <> N'VERBOSE')
            RETURN 0

	DECLARE @String     NVARCHAR(4000)
    DECLARE	@timestamp  NVARCHAR(70)

    SET     @timestamp  = FORMAT(GETUTCDATE(),'O'); 
    SELECT  @String     = CONCAT(   @timestamp
                                    ,SPACE(@@NESTLEVEL-1)
                                    ,N'|'
                                    ,@Key
                                    ,N':['
                                    ,CAST(@Value as NVARCHAR(4000))
                                    ,N']'
                                )
    
    -- RAISERROR will Auto Truncate messages over 2047 chars 
    RAISERROR(@String,0,1) WITH NOWAIT

    RETURN 0

    /*
        -- TO SET CONEXT_INFO RUN
        DECLARE @CTX VARBINARY(128) = CAST(N'VERBOSE' as VARBINARY(128));
        SET CONTEXT_INFO @CTX;  
    */
END 
GO
