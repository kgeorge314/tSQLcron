# tSQLcron

| Branch         | Build Status                                                                                                                      |
|:---------------|:----------------------------------------------------------------------------------------------------------------------------------|
| master         | ![master-tsql-and-tSQLt](https://github.com/kgeorge314/tSQLcron/workflows/Build-Database-Run-tSQLt-Tests/badge.svg?branch=master) |
| latest-release | ![Create - Test - Release](https://github.com/kgeorge314/tSQLcron/workflows/Create%20-%20Test%20-%20Release/badge.svg)            |

A tSQL based cron utility.

## Quick Start

### Install

Install `tSQLcron` using [`Install_tsqlCron.sql`](https://github.com/kgeorge314/tSQLcron/releases/download/V1.0.0/Install_tsqlCron.sql), the latest version is available in the [release](https://github.com/kgeorge314/tSQLcron/releases) page.

**Example Usage:**

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

## CRON Expression

**Format:** `{second}  {minute} {hour} {day}  {month} {day-of-week*}`

> (*) day of week depends on SQL Server configuration, use the below code snippet to identify the value of Monday `SELECT DATEPART(WEEKDAY,'2020-04-13') AS Monday_The_13th_Of_April_2020`

**Example CRON Expressions:**

| Description                                       | CRON Expression        |
|:--------------------------------------------------|:-----------------------|
| always/any-time                                   | `N'* * * * * *'`       |
| every 15th minute                                 | `N'* */15 * * * *'`    |
| everyday at a 13:10                               | `N'* 10 13 * * *'`     |
| everyday at the 10th minute between 13H-23H range | `N'* 10 13-23 * * *'`  |
| on the 27th of June at any-time                   | `N'* * * 27 6 *'`      |
| on the 27th of June at 13:10                      | `N'* 10 13 27 6 *'`    |
| on the 27th of June at 13:10:30                   | `N'30 10 13 27 6 *'`   |
| every monday at 13:10                             | `N'* 10 13 * * 2'`     |
| every monday,wed,thu at 13:10                     | `N'* 10 13 * * 2,4,5'` |
| weekdays (mon-fri) at 13:10                       | `N'* 10 13 * * 2-6'`   |
| weekdays alternate (mon-fri) at 13:10             | `N'* 10 13 * * 2-6/2'` |
| midnight on weekends                              | `N'* 10 13 * * 2-6/2'` |
