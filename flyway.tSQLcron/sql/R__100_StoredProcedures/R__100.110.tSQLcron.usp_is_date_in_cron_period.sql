CREATE OR ALTER PROCEDURE tSQLcron.usp_is_date_in_cron_period 
     @cron_expression NVARCHAR(100) 
	 /*{second} {minute} {hour} {day}  {month} {day-of-week}*/
    ,@validate_date DATETIME = NULL
    ,@out_is_cron_true BIT OUTPUT

AS
/*******************************************************************************
---
Name: "[tSQLcron].[usp_is_date_in_cron_period]"

Description: |
  This stored procedure can be used to evaluate if a given date is true for 
  a given cron_expression. It will return true (1) if it is. 
  
  WARNING: This is a best effort implementation and has NO validation of 
           the inputs, not all cron expressions are supported so please 
           test your expressions.

Parameters: |
  - @cron_expression : a valid cron expression (see more in  'Cron Expression')
  - @validate_date   : optional parameter of the date to validate against the cron expression
                       defaults to current UTC datetime
  - out_is_cron_true : OUTPUT variable that returns true or false

  Format         : {second}  {minute} {hour} {day}  {month} {day-of-week*}
  Value-Options  : *         *        *      *      *       *
                 : {0-59}    {0-59}   {0-23} {1-31} {1-12}  {1-7}
                 : 1,2...    1,2...   1,2... 1,2... 1,2...  1,2...
  
  See more information below
                 
CRON element allowed values:
  - second : "{*|0|0,1,2..59|1-59|(1-59|0,1..)/1-59}"
  - minute : "{*|0|0,1,2..59|1-59|(1-59|0,1..)/1-59}"
  - hour   : "{*|0|0,1,2..23|1-23|(1-23|0,1..)/1-23}"
  - day    : "{*|0|1,2,3..31|1-31|(1-31|1,2..)/1-31}"
  - month  : "{*|0|1,2,3..12|1-12|(1-12|1,2..)/1-12}"
  - day-of-week : "{*|0|1,2,3..7|1-7|1-7/1-7}"
  - note*: |
        The value of `{day-of-week}` depends on settings of SQL Server.

        You can identify what `{day-of-week}` monday is using the below snippet
        `SELECT DATEPART(WEEKDAY,'2020-04-13') AS Monday_The_13th_Of_April_2020`
         
        Usually : 1:Sunday,2:Monday,3:Tuesday,4:Wednesday,5:Thursday,6:Friday,7:Saturday

Value-Options : |
    Any Or Ignore
    `*`   means that the section is ignored / is any 

    Exactly this (Second/Minute/...)
    `0`   means that the section is run exactly when the (Second/Minute/...) is 0. i.e. When the (Second/Minute/...) is exactly 0

    Exactly one of these comma separated (Second/Minute/...)
    `1,4,6`   means that the section is run exactly when the (Second/Minute/...) is 0. i.e. When the (Second/Minute/...) is exactly 1 or 4 or 6

    Is Between this range (Second/Minute/...)
    `0-5` means that the section is run within this interval, between 0 and 5

    Is Between Ranges and is divisible by (n) (Second/Minute/...)
    `0-30/5` means that the section is run within this interval, between 0 and 30 AND is exactly divisible by 5 i.e every 5th (Second/Minute/...) between 0-30
    `* /5` means every 5th (Second/Minute/...) [Note Remove the space between * and /]
    `0/5`  means every 5th (Second/Minute/...) [Same as above]

Sample CRON expressions: |
    - always/any-time                    - N'* * * * * *'
    - every 15th minute									 - N'* 0/15 * * * *' (remove space between * and / since it is close SQL Comment)
    - everyday at a 13:10			           - N'* 10 13 * * *'  
    - everyday at the 10th minute between 13H-23H range  - N'* 10 13-23 * * *'  

    - on the 27th of June at anytime          - N'* * * 27 6 *'
    - on the 27th of June at 13:10            - N'* 10 13 27 6 *'
    - on the 27th of June at 13:10:30         - N'30 10 13 27 6 *'

    - every monday at 13:10                  - N'* 10 13 * * 2'
    - every monday,wed,thu at 13:10          - N'* 10 13 * * 2,4,5'
    - weekdays (mon-fri) at 13:10            - N'* 10 13 * * 2-6'
    - weekdays alternate (mon-fri) at 13:10  - N'* 10 13 * * 2-6/2'
    - midnight on weekends                   - N'* 10 13 * * 2-6/2'
    
Example: |
    DECLARE @out_is_cron_true BIT ;
    EXEC tSQLcron.sp_is_date_in_cron_period
      @cron_expression =  N'* 0/15 * * * *' -- nvarchar(100)
    , @validate_date = '2020-01-01 13:15:00' -- datetime
    , @out_is_cron_true = @out_is_cron_true OUTPUT -- bit

    IF (@out_is_cron_true = 1 )
    BEGIN
      -- DO SOMETHING
    END

...
********************************************************************************/
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS
        #hours
      , #minute_second ;
    
    DECLARE
        @is_cron_true BIT = 0
      , @is_success   BIT = 0 ;
    
    DECLARE
        @Seconds    NVARCHAR(100)
      , @Minutes    NVARCHAR(100)
      , @Hours      NVARCHAR(100)
      , @DayOfMonth NVARCHAR(100)
      , @Month      NVARCHAR(100)
      , @DayOfWeek  NVARCHAR(100) ;

    SET @validate_date = ISNULL(@validate_date,GETUTCDATE());

    DECLARE
        @now_second      INT = DATEPART( SECOND, @validate_date)
      , @now_minute      INT = DATEPART( MINUTE, @validate_date)
      , @now_hour        INT = DATEPART( HOUR, @validate_date)
      , @now_day         INT = DATEPART( DAY, @validate_date)
      , @now_month       INT = DATEPART( MONTH, @validate_date)
      , @now_day_of_week INT = DATEPART( WEEKDAY, @validate_date)
      , @now_year        INT = DATEPART( YEAR, @validate_date) ;




    EXEC tSQLcron.usp_write_verbose '::START::'         , 'tSQLcron.sp_is_date_in_cron_period';
    EXEC tSQLcron.usp_write_verbose '@cron_expression'  , @cron_expression;
    EXEC tSQLcron.usp_write_verbose '@validate_date'    , @validate_date;
    

    BEGIN TRY
        SELECT
                @Seconds    = cron_seconds
              , @Minutes    = cron_minutes
              , @Hours      = cron_hours
              , @DayOfMonth = cron_day_of_month
              , @Month      = cron_month
              , @DayOfWeek  = cron_day_of_week
        FROM  tSQLcron.fn_parse_cron_expression(@cron_expression);

        EXEC tSQLcron.usp_write_verbose ' INFO'       , 'fn_parse_cron_expression';
        EXEC tSQLcron.usp_write_verbose '  @Seconds'   , @Seconds;   
        EXEC tSQLcron.usp_write_verbose '  @Minutes'   , @Minutes;   
        EXEC tSQLcron.usp_write_verbose '  @Hours'     , @Hours;     
        EXEC tSQLcron.usp_write_verbose '  @DayOfMonth', @DayOfMonth;
        EXEC tSQLcron.usp_write_verbose '  @Month'     , @Month;     
        EXEC tSQLcron.usp_write_verbose '  @DayOfWeek' , @DayOfWeek; 

        EXEC tSQLcron.usp_write_verbose ' INFO'              , 'NOW(@validate_date)';
        EXEC tSQLcron.usp_write_verbose '  @now_second'      , @now_second;      
        EXEC tSQLcron.usp_write_verbose '  @now_minute'      , @now_minute;      
        EXEC tSQLcron.usp_write_verbose '  @now_hour'        , @now_hour;        
        EXEC tSQLcron.usp_write_verbose '  @now_day'         , @now_day;         
        EXEC tSQLcron.usp_write_verbose '  @now_month'       , @now_month;       
        EXEC tSQLcron.usp_write_verbose '  @now_day_of_week' , @now_day_of_week; 
        EXEC tSQLcron.usp_write_verbose '  @now_year'        , @now_year;        




        EXEC tSQLcron.usp_write_verbose ' INFO'             , 'Check RETURN True if expressions is any time';
        IF (
            1 = 1
        AND @Seconds IN ( N'*', N'0/1', N'*/1' )
        AND @Minutes IN ( N'*', N'0/1', N'*/1' )
        AND @Hours IN ( N'*', N'0/1', N'*/1' )
        AND @DayOfMonth IN ( N'*', N'0/1', N'*/1' )
        AND @Month IN ( N'*', N'0/1', N'*/1' )
        AND @DayOfWeek IN ( N'*', N'0/1', N'*/1' )
        )
        BEGIN
            EXEC tSQLcron.usp_write_verbose ' INFO' , N'Returning, any time expressions passed'; 
            SELECT @is_cron_true = 1 , @is_success = 1 , @out_is_cron_true = 1;
            RETURN @is_success;
        END ;

        EXEC tSQLcron.usp_write_verbose ' INFO' , 'CREATE #Hours and #minute_second TABLE';
        SELECT CAST(value AS INT) AS hours INTO #hours FROM
        STRING_SPLIT(N'0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23', ',') ;

        SELECT
            CAST(value AS INT) AS minutes
          , CAST(value AS INT) AS seconds
        INTO #minute_second
        FROM
            STRING_SPLIT(N'0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59', ',') ;

        EXEC tSQLcron.usp_write_verbose ' INFO' , 'PROCESSING cron expression';

        WITH dates
          AS (SELECT DISTINCT
                     dd.date_key
                   , dd.calendar_year
                   , dd.calendar_month
                   , dd.calendar_day
                   , dd.day_of_week
              FROM
                  tSQLcron.dim_date dd
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @DayOfMonth ) cDm
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @DayOfWeek ) cDw
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @Month ) cM
              WHERE
                  1                                                   = 1
              -- Look at Todays Date
              AND date_key                                            = CAST(@validate_date AS DATE)

              --
              -- DayOfMonth
              AND (cDm.is_any                                         = 1
                   OR dd.calendar_day BETWEEN cDm.start_period AND cDm.end_period
                   OR dd.calendar_day                                 = cDm.this_period
              )
              AND dd.calendar_day % ISNULL( cDm.interval_period, 1 )  = 0
              --
              --
              -- DayOfweek
              AND (cDw.is_any                                         = 1
                   OR dd.day_of_week BETWEEN cDw.start_period AND cDw.end_period
                   OR dd.day_of_week                                  = cDw.this_period
              )
              AND dd.day_of_week % ISNULL( cDw.interval_period, 1 )   = 0

              -- Month
              AND (cM.is_any                                          = 1
                   OR dd.calendar_month BETWEEN cM.start_period AND cM.end_period
                   OR dd.calendar_month                               = cM.this_period
              )
              AND dd.calendar_month % ISNULL( cM.interval_period, 1 ) = 0)
           , Times
          AS (SELECT
                  H.hours AS time_hour
                , M.minutes AS time_minute
                , S.seconds AS time_second
                , TIMEFROMPARTS( H.hours, M.minutes, S.seconds, 0, 0 ) AS valid_times
              FROM
                  #hours H
             CROSS APPLY #minute_second M
             CROSS APPLY #minute_second S
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @Hours ) cH
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @Minutes ) cM
             CROSS APPLY tSQLcron.fn_parse_cron_expression_element( @Seconds ) cS
              WHERE
                  1                                           = 1
              -- Hours
              AND (cH.is_any                                  = 1 OR H.hours BETWEEN cH.start_period AND cH.end_period OR H.hours = cH.this_period)
              AND H.hours % ISNULL( cH.interval_period, 1 )   = 0

              -- Minutes
              AND (cM.is_any                                  = 1 OR M.minutes BETWEEN cM.start_period AND cM.end_period OR M.minutes = cM.this_period)
              AND M.minutes % ISNULL( cM.interval_period, 1 ) = 0

              -- Seconds
              AND (cS.is_any                                  = 1 OR S.seconds BETWEEN cS.start_period AND cS.end_period OR S.seconds = cS.this_period)
              AND S.seconds % ISNULL( cS.interval_period, 1 ) = 0)
           , time_object
          AS (SELECT
                  DATETIMEFROMPARTS(
                      d.calendar_year, d.calendar_month, d.calendar_day, t.time_hour, t.time_minute, t.time_second, 0
                  ) AS valid_time
              FROM
                  dates d
             CROSS APPLY Times t
              WHERE
                  1                                                          = 1
              AND (@Seconds IN ( N'*', N'0/1', N'*/1' ) OR t.time_second     = @now_second)
              AND (@Minutes IN ( N'*', N'0/1', N'*/1' ) OR t.time_minute     = @now_minute)
              AND (@Hours IN ( N'*', N'0/1', N'*/1' ) OR t.time_hour         = @now_hour)
              AND (@DayOfMonth IN ( N'*', N'0/1', N'*/1' ) OR d.calendar_day = @now_day)
              AND (@Month IN ( N'*', N'0/1', N'*/1' ) OR d.calendar_month    = @now_month)
              AND (@DayOfWeek IN ( N'*', N'0/1', N'*/1' ) OR d.day_of_week   = @now_day_of_week)
              AND (@now_year                                                 = d.calendar_year))
        SELECT TOP (1) @is_cron_true = 1 FROM time_object 
        WHERE time_object.valid_time >= @validate_date
        OPTION(RECOMPILE)        ;

        SELECT @is_success = 1 , @out_is_cron_true = @is_cron_true;
    END TRY
    BEGIN CATCH
        SET @is_success = 0;

        THROW;
        
    END CATCH;
    EXEC tSQLcron.usp_write_verbose '::END::'         , 'tSQLcron.sp_is_date_in_cron_period';
    RETURN @is_success
END;
