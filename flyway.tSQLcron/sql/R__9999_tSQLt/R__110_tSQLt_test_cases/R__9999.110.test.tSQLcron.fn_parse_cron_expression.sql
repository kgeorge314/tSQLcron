-- test (fn_parse_cron_expression) that cron statement * * * * * is parsed correctly
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression) that cron statement * * * * * is parsed correctly]
AS
BEGIN
    -------Assemble
    DECLARE @cron_expression NVARCHAR(100) = N'* * * * * *' ;

    -------Act

    SELECT
        cron_seconds
      , cron_minutes
      , cron_hours
      , cron_day_of_month
      , cron_month
      , cron_day_of_week
    INTO actual
    FROM tSQLcron.fn_parse_cron_expression( @cron_expression ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT N'*' AS cron_seconds, N'*' AS cron_minutes, N'*' AS cron_hours, N'*' AS cron_day_of_month, N'*' AS cron_month, N'*' AS cron_day_of_week INTO
        expected ;


    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO

-- test (fn_parse_cron_expression) that cron statement on the 4th of May at 13:10:30 is parsed correctly
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression) that cron statement on the 4th of May at 12:34:56 is parsed correctly]
AS
BEGIN
    -------Assemble
    DECLARE @cron_expression NVARCHAR(100) = N'56 34 12 4 5 *' ;

    -------Act

    SELECT
        cron_seconds
      , cron_minutes
      , cron_hours
      , cron_day_of_month
      , cron_month
      , cron_day_of_week
    INTO actual
    FROM tSQLcron.fn_parse_cron_expression( @cron_expression ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT N'56' AS cron_seconds, N'34' AS cron_minutes, N'12' AS cron_hours, N'4' AS cron_day_of_month, N'5' AS cron_month, N'*' AS cron_day_of_week INTO
        expected ;


    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO
