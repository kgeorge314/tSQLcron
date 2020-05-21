# tSQLcron

|     Branch     |                                                           Build Status                                                            |
|:--------------:|:---------------------------------------------------------------------------------------------------------------------------------:|
|     master     | ![master-tsql-and-tSQLt](https://github.com/kgeorge314/tSQLcron/workflows/Build-Database-Run-tSQLt-Tests/badge.svg?branch=master) |
| latest-release |      ![Create - Test - Release](https://github.com/kgeorge314/tSQLcron/workflows/Create%20-%20Test%20-%20Release/badge.svg)       |

A tSQL based cron utility.

## Quick Start

Example Usage

```sql
    DECLARE @out_is_cron_true BIT ;

    EXEC tSQLcron.usp_is_date_in_cron_period
      @cron_expression =  N'* 0/15 * * * *' -- nvarchar(100)
    , @validate_date = '2020-01-01 13:15:00' -- datetime
    , @out_is_cron_true = @out_is_cron_true OUTPUT -- bit

    IF (@out_is_cron_true = 1 )
    BEGIN
      PRINT 'DO SOMETHING';
    END
```
