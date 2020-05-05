-- Any
-- [test (usp_is_date_in_cron_period) any date expression]
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (usp_is_date_in_cron_period) any date expression]
AS
BEGIN
    -------Assemble
    DECLARE
        @cron_expression  NVARCHAR(100)
      , @validate_date    DATETIME
      , @out_is_cron_true BIT ;

    DECLARE
        @true  BIT = 1
      , @false BIT = 0 ;

    -------Act
    SELECT @cron_expression = N'* * * * * *', @validate_date = GETUTCDATE() ;

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

    -------Act
    SELECT @cron_expression = N'0/1 0/1 0/1 0/1 0/1 0/1', @validate_date = GETUTCDATE() ;

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

    -------Act
    SELECT @cron_expression = N'*/1 */1 */1 */1 */1 */1', @validate_date = GETUTCDATE() ;

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

END ;
GO

-- Any Every
-- [test (usp_is_date_in_cron_period) any date expression]
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (usp_is_date_in_cron_period) every 15 minutes * 0/15 * * * *]
AS
BEGIN
    -------Assemble
    DECLARE
        @cron_expression  NVARCHAR(100)
      , @validate_date    DATETIME
      , @out_is_cron_true BIT ;

    DECLARE
        @true  BIT = 1
      , @false BIT = 0 ;


    -------Act [00 Minutes]:true 13:00
    SELECT   @cron_expression = N'* 0/15 * * * *'
		   , @validate_date= DATETIMEFROMPARTS(
								  YEAR ( GETUTCDATE())	-- Year
								, MONTH( GETUTCDATE())	-- Month
								, DAY  ( GETUTCDATE())	-- Day
								, DATEPART(HOUR, GETUTCDATE())	-- Hour
								, 0						-- Minute
								, 0 					-- Second
								, 0					    -- MilliSecond
								) ;

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;


	-------Act Add [10 Minutes]:false 13:10

	SELECT @validate_date = DATEADD(MINUTE,10,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Add [20 Minutes]:true 13:30

	SELECT @validate_date = DATEADD(MINUTE,20,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

END ;
GO

-- Any Day Specific Time
-- [test (usp_is_date_in_cron_period) everyday at a 13:10]
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (usp_is_date_in_cron_period) everyday at a 13:10]
AS
BEGIN
    -------Assemble
    DECLARE
        @cron_expression  NVARCHAR(100)
      , @validate_date    DATETIME
      , @out_is_cron_true BIT ;

    DECLARE
        @true  BIT = 1
      , @false BIT = 0 ;


    -------Act [13:10]:true 13:10
    SELECT   @cron_expression = N'* 10 13 * * *'
		   , @validate_date= DATETIMEFROMPARTS(
								  YEAR ( GETUTCDATE())	-- Year
								, MONTH( GETUTCDATE())	-- Month
								, DAY  ( GETUTCDATE())	-- Day
								, 13                	-- Hour
								, 10					-- Minute
								, DATEPART(SECOND, GETUTCDATE()) -- Second
								, 0					    -- MilliSecond
								) ;

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;


	-------Act Add 5 Days:true 13:10

	SELECT @validate_date = DATEADD(DAY,5,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Add [1 Minute]:false 13:11

	SELECT @validate_date = DATEADD(MINUTE,1,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

END ;
GO

-- CSV Days Specific Time
-- [test (usp_is_date_in_cron_period) every monday,wed,thu at 13:10]
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (usp_is_date_in_cron_period) every monday,wed,thu at 13:10]
AS
BEGIN
    -------Assemble
    DECLARE
        @cron_expression  NVARCHAR(100)
      , @validate_date    DATETIME
      , @out_is_cron_true BIT ;

    DECLARE
        @true  BIT = 1
      , @false BIT = 0 ;


    -------Act [13:10]:true 13:10
    SELECT   TOP (1)
			 -- * 10 13 * * 2,4,5
		     @cron_expression = CONCAT(N'* 10 13 * * ',day_of_week,',',day_of_week+2,',',day_of_week+3)
		   , @validate_date= DATETIMEFROMPARTS(
								  YEAR ( date_key)	-- Year
								, MONTH( date_key)	-- Month
								, DAY  ( date_key)	-- Day
								, 13                	-- Hour
								, 10					-- Minute
								, DATEPART(SECOND, GETUTCDATE()) -- Second
								, 0					    -- MilliSecond
								) 
	FROM tSQLcron.dim_date
	WHERE date_key >= GETUTCDATE()
		  AND day_name = 'Monday'

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;


	-------Act Wednesday
	SELECT @validate_date = DATEADD(DAY,2,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Thursday
	SELECT @validate_date = DATEADD(DAY,1,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Friday

	SELECT @validate_date = DATEADD(DAY,1,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Go Back to Thursday and Add [1 Minute] to fail
	SELECT @validate_date = DATEADD(DAY,-1,DATEADD(MINUTE,1,@validate_date))

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

END ;
GO

-- Range Days , Every nth Second in Range
-- [test (usp_is_date_in_cron_period) weekdays (mon-fri) at 13:10:00-13:10:30]
CREATE OR ALTER PROCEDURE tSQLt_tsqlcron.[test (usp_is_date_in_cron_period) weekdays (mon-fri) at 13:10:00-13:10:30 every 5th second]
AS
BEGIN
    -------Assemble
    DECLARE
        @cron_expression  NVARCHAR(100)
      , @validate_date    DATETIME
      , @out_is_cron_true BIT ;

    DECLARE
        @true  BIT = 1
      , @false BIT = 0 ;


    -------Act [13:10]:true 13:10
    SELECT   TOP (1)
			 -- 0-30/5 10 13 * * 2-6
		     @cron_expression = CONCAT(N'0-30/5 10 13 * * ',day_of_week,'-',day_of_week+4)
		   , @validate_date= DATETIMEFROMPARTS(
								  YEAR ( date_key)	-- Year
								, MONTH( date_key)	-- Month
								, DAY  ( date_key)	-- Day
								, 13    -- Hour
								, 10	-- Minute
								, 0     -- Second
								, 0		-- MilliSecond
								) 
	FROM tSQLcron.dim_date
	WHERE date_key >= GETUTCDATE()
		  AND day_name = 'Monday'

    EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;


	-------Act Tuesday @ 13:10:05
	SELECT @validate_date = DATEADD(SECOND,5,DATEADD(DAY,1,@validate_date))

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Tuesday @ 13:10:06
	SELECT @validate_date = DATEADD(SECOND,1,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Friday @ 13:10:15

	SELECT @validate_date = DATEADD(SECOND,9,DATEADD(DAY,3,@validate_date))

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @true -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

	-------Act Friday @ 13:10:31
	SELECT @validate_date =DATEADD(SECOND,16,@validate_date)

	EXEC tSQLcron.usp_is_date_in_cron_period
        @cron_expression = @cron_expression
      , @validate_date = @validate_date
      , @out_is_cron_true = @out_is_cron_true OUTPUT ; -- bit


    -------Assert usp_is_date_in_cron_period returns expected value	
    EXEC tSQLt.AssertEquals
        @Expected = @false -- sql_variant
      , @Actual = @out_is_cron_true -- sql_variant
    ;

END ;
GO