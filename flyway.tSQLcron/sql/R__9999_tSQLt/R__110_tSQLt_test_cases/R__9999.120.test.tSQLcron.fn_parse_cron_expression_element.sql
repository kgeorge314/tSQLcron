-- test (fn_parse_cron_expression_element) that a cron range 1-20 is extracted
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression_element) that a cron range 1-20 is extracted]
AS
BEGIN
    -------Assemble
    DECLARE @cron_element NVARCHAR(100) = N'1-20' ;

    -------Act

    SELECT 
		start_period
	  , end_period
	  , interval_period
	  , this_period
	  , is_any 
	INTO actual 
	FROM tSQLcron.fn_parse_cron_expression_element( @cron_element ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT 
	    CAST(1    AS INT) AS start_period
	  , CAST(20   AS INT) AS end_period
	  , CAST(NULL AS INT) AS interval_period
	  , CAST(NULL AS INT) AS this_period
	  , CAST(0 AS BIT)    AS is_any 
	INTO expected 

 
    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO

-- test (fn_parse_cron_expression_element) that a cron range with intreval 1-15/5
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression_element) that a cron range-interval 1-15/5 is extracted]
AS
BEGIN
    -------Assemble
    DECLARE @cron_element NVARCHAR(100) = N'1-15/5' ;

    -------Act

    SELECT 
		start_period
	  , end_period
	  , interval_period
	  , this_period
	  , is_any 
	INTO actual 
	FROM tSQLcron.fn_parse_cron_expression_element( @cron_element ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT 
	    CAST(1    AS INT) AS start_period
	  , CAST(15   AS INT) AS end_period
	  , CAST(5    AS INT) AS interval_period
	  , CAST(NULL AS INT) AS this_period
	  , CAST(0 AS BIT)    AS is_any 
	INTO expected 

 
    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO

-- test (fn_parse_cron_expression_element) that a cron specific
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression_element) that a cron specific 5 is extracted]
AS
BEGIN
    -------Assemble
    DECLARE @cron_element NVARCHAR(100) = N'5' ;

    -------Act

    SELECT 
		start_period
	  , end_period
	  , interval_period
	  , this_period
	  , is_any 
	INTO actual 
	FROM tSQLcron.fn_parse_cron_expression_element( @cron_element ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT 
	    CAST(NULL AS INT) AS start_period
	  , CAST(NULL AS INT) AS end_period
	  , CAST(NULL AS INT) AS interval_period
	  , CAST(5    AS INT) AS this_period
	  , CAST(0 AS BIT)    AS is_any 
	INTO expected 

 
    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO

-- test (fn_parse_cron_expression_element) that a cron specific-interval
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression_element) that a cron specific-interval 5/2 is extracted]
AS
BEGIN
    -------Assemble
    DECLARE @cron_element NVARCHAR(100) = N'5/2' ;

    -------Act

    SELECT 
		start_period
	  , end_period
	  , interval_period
	  , this_period
	  , is_any 
	INTO actual 
	FROM tSQLcron.fn_parse_cron_expression_element( @cron_element ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT 
	    CAST(NULL AS INT) AS start_period
	  , CAST(NULL AS INT) AS end_period
	  , CAST(2    AS INT) AS interval_period
	  , CAST(5    AS INT) AS this_period
	  , CAST(0 AS BIT)    AS is_any 
	INTO expected 

 
    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO

-- test (fn_parse_cron_expression_element) that a cron specific-interval is any when 0/ is used
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (fn_parse_cron_expression_element) that a cron is any when 0/5 is used]
AS
BEGIN
    -------Assemble
    DECLARE @cron_element NVARCHAR(100) = N'0/5' ;

    -------Act

    SELECT 
		start_period
	  , end_period
	  , interval_period
	  , this_period
	  , is_any 
	INTO actual 
	FROM tSQLcron.fn_parse_cron_expression_element( @cron_element ) ;

    -------Assert fn_parse_cron_expression parsed cron expression correctly
    SELECT 
	    CAST(NULL AS INT) AS start_period
	  , CAST(NULL AS INT) AS end_period
	  , CAST(5    AS INT) AS interval_period
	  , CAST(NULL AS INT) AS this_period
	  , CAST(1 AS BIT)    AS is_any 
	INTO expected 

 
    EXEC tSQLt.AssertEqualsTable 'actual', 'expected' ;

END ;
GO