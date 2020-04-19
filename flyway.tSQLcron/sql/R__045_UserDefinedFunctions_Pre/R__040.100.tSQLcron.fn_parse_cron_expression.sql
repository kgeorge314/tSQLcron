CREATE OR ALTER FUNCTION tSQLcron.fn_parse_cron_expression (@cron_expression NVARCHAR(100))
RETURNS TABLE
AS
RETURN (
/*
Format: {second} {minute} {hour} {day} {month} {day-of-week}
*/
    WITH cron_parts
      AS (
	  SELECT 
		  value AS item_value
		,   ROW_NUMBER() 
			OVER (ORDER BY (SELECT NULL)) AS position_key 
	  FROM
          STRING_SPLIT(@cron_expression, N' ')
	)
    SELECT
        [1] AS cron_seconds
      , [2] AS cron_minutes
      , [3] AS cron_hours
      , [4] AS cron_day_of_month
      , [5] AS cron_month
      , [6] AS cron_day_of_week
    FROM cron_parts cp
    PIVOT (MAX(cp.item_value) FOR cp.position_key IN ([1], [2], [3], [4], [5], [6])) pvt
) ;
