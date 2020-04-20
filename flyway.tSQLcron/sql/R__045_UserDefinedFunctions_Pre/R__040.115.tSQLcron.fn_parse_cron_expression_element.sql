CREATE OR ALTER FUNCTION tSQLcron.fn_parse_cron_expression_element (@cron_element NVARCHAR(100))
RETURNS TABLE
AS
RETURN (
/*
Returns: {start_period} {end_period} {interval_period} {this_period} {is_any}
  For Patterns of `1-24`
  - start_period: 1 (_the start period of a range_)
  - end_period: 24 (_the end period of a range_)

  For Patterns of `1` , `1/15`
  - this_period: 1 (_the specific period_)
  - interval_period: 15 (_the interval period when a `/` is involved_)

  For Patterns of `*` , `0/` 
  - is_any: 1 (_for patterns that ignore or mean any_)
*/
    SELECT
        CAST(IIF(CHARINDEX( N'-', value ) > 0, SUBSTRING( value, 0, CHARINDEX( N'-', value )), NULL) AS INT) AS start_period
      , CAST(IIF(CHARINDEX( N'-', value ) > 0
               , SUBSTRING(
                     value
                   , CHARINDEX( N'-', value ) + 1
                   , ISNULL((NULLIF(CHARINDEX( N'/', value ), 0) - 1 - CHARINDEX( N'-', value )), LEN( value ))
                 )
               , NULL) AS INT) AS end_period
      , CAST(IIF(CHARINDEX( N'/', value ) > 0, SUBSTRING( value, CHARINDEX( N'/', value ) + 1, LEN( value )), NULL) AS INT) AS interval_period
      , TRY_CAST(IIF(CHARINDEX( N'/', value ) > 0 , SUBSTRING( value, 0, CHARINDEX( N'/', value )) , value) AS INT) AS this_period
      , CAST(IIF(value = N'*' OR LEFT(value,2) IN (N'0/' , N'*/'), 1, 0) AS BIT) AS is_any
    FROM STRING_SPLIT(@cron_element, N',')
) ;
