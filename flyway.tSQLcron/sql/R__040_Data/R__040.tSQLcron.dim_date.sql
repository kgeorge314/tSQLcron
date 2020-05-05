/*
CREDIT TO ORIGINAL AUTHOR: 
----------------------------------------------------------------------
Original Blog: http://www.sqlservercentral.com/scripts/Date/68389/ *
----------------------------------------------------------------------
*/
-----------------------------------------------------------------------------------------------------------------------------
--	Script Details: Listing Of Standard Details Related To The Script
-----------------------------------------------------------------------------------------------------------------------------

--	Purpose: Date Calendar Cross-Reference Table
--	Create Date (MM/DD/YYYY): 10/29/2009
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


-----------------------------------------------------------------------------------------------------------------------------
--	Modification History: Listing Of All Modifications Since Original Implementation
-----------------------------------------------------------------------------------------------------------------------------

--	Description: Fixed Bug Affecting "month_weekdays_remaining" And "quarter_weekdays_remaining" Columns
--	Date (MM/DD/YYYY): 07/02/2014
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


-----------------------------------------------------------------------------------------------------------------------------
--	Declarations / Sets: Declare And Set Variables
-----------------------------------------------------------------------------------------------------------------------------

DECLARE
	 @Date_Start AS DATETIME
	,@Date_End AS DATETIME


SET @Date_Start = '20150101'
SET @Date_End = '20501231'


-----------------------------------------------------------------------------------------------------------------------------
--	Error Trapping: Check If Permanent Table(s) Already Exist(s) And Drop If Applicable
-----------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID (N'tSQLcron.dim_date', N'U') IS NOT NULL
BEGIN

	DROP TABLE tSQLcron.dim_date

END


-----------------------------------------------------------------------------------------------------------------------------
--	Permanent Table: Create Date Xref Table
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE tSQLcron.dim_date

	(
		 date_key DATE NOT NULL CONSTRAINT PK_dim_date_date_key PRIMARY KEY CLUSTERED
		,calendar_year SMALLINT
		,calendar_month TINYINT
		,calendar_day TINYINT
		,calendar_quarter TINYINT
		,first_day_in_week DATETIME
		,last_day_in_week DATETIME
		,is_week_in_same_month INT
		,first_day_in_month DATETIME
		,last_day_in_month DATETIME
		,is_last_day_in_month INT
		,first_day_in_quarter DATETIME
		,last_day_in_quarter DATETIME
		,is_last_day_in_quarter INT
		,day_of_week TINYINT
		,week_of_month TINYINT
		,week_of_quarter TINYINT
		,week_of_year TINYINT
		,days_in_month TINYINT
		,month_days_remaining TINYINT
		,weekdays_in_month TINYINT
		,month_weekdays_remaining TINYINT
		,month_weekdays_completed TINYINT
		,days_in_quarter TINYINT
		,quarter_days_remaining TINYINT
		,quarter_days_completed TINYINT
		,weekdays_in_quarter TINYINT
		,quarter_weekdays_remaining TINYINT
		,quarter_weekdays_completed TINYINT
		,day_of_year SMALLINT
		,year_days_remaining SMALLINT
		,is_weekday INT
		,is_leap_year INT
		,day_name VARCHAR (10)
		,month_day_name_instance TINYINT
		,quarter_day_name_instance TINYINT
		,year_day_name_instance TINYINT
		,month_name VARCHAR (10)
		,year_week CHAR (6)
		,year_month CHAR (6)
		,year_quarter CHAR (6)
		,year_month_day CHAR (8)
	)


-----------------------------------------------------------------------------------------------------------------------------
--	Table Insert: Populate Base Date Values Into Permanent Table Using Common Table Expression (CTE)
-----------------------------------------------------------------------------------------------------------------------------

;WITH CTE_Date_Base_Table AS

	(
		SELECT
			@Date_Start AS date_key

		UNION ALL

		SELECT
			DATEADD (DAY, 1, DBT.date_key)
		FROM
			CTE_Date_Base_Table DBT
		WHERE
			DATEADD (DAY, 1, DBT.date_key) <= @Date_End
	)

INSERT INTO tSQLcron.dim_date

	(
		date_key
	)

SELECT
	DBT.date_key
FROM
	CTE_Date_Base_Table DBT
OPTION
	(MAXRECURSION 0)


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update I: Populate Additional Date Xref Table Fields (Pass I)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	tSQLcron.dim_date
SET
	 calendar_year = DATEPART (YEAR, date_key)
	,calendar_month = DATEPART (MONTH, date_key)
	,calendar_day = DATEPART (DAY, date_key)
	,calendar_quarter = DATEPART (QUARTER, date_key)
	,first_day_in_week = DATEADD (DAY, -DATEPART (WEEKDAY, date_key) + 1, date_key)
	,first_day_in_month = CONVERT (VARCHAR (6), date_key, 112) + '01'
	,day_of_week = DATEPART (WEEKDAY, date_key)
	,week_of_year = DATEPART (WEEK, date_key)
	,day_of_year = DATEPART (DAYOFYEAR, date_key)
	,is_weekday = ISNULL ((CASE
								WHEN ((@@DATEFIRST - 1) + (DATEPART (WEEKDAY, date_key) - 1)) % 7 NOT IN (5, 6) THEN 1
								END), 0)
	,day_name = DATENAME (WEEKDAY, date_key)
	,month_name = DATENAME (MONTH, date_key)


ALTER TABLE tSQLcron.dim_date ALTER COLUMN calendar_year INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN calendar_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN calendar_day INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN calendar_quarter INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN first_day_in_week DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN first_day_in_month DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN day_of_week INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN week_of_year INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN day_of_year INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN is_weekday INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN day_name VARCHAR (10) NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN month_name VARCHAR (10) NOT NULL


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_calendar_year ON tSQLcron.dim_date (calendar_year)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_calendar_month ON tSQLcron.dim_date (calendar_month)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_calendar_quarter ON tSQLcron.dim_date (calendar_quarter)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_first_day_in_week ON tSQLcron.dim_date (first_day_in_week)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_day_of_week ON tSQLcron.dim_date (day_of_week)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_is_weekday ON tSQLcron.dim_date (is_weekday)


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update II: Populate Additional Date Xref Table Fields (Pass II)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	tSQLcron.dim_date
SET
	 last_day_in_week = first_day_in_week + 6
	,last_day_in_month = DATEADD (MONTH, 1, first_day_in_month) - 1
	,first_day_in_quarter = A.first_day_in_quarter
	,last_day_in_quarter = A.last_day_in_quarter
	,week_of_month = DATEDIFF (WEEK, first_day_in_month, date_key) + 1
	,week_of_quarter = (week_of_year - A.min_week_of_year_in_quarter) + 1
	,is_leap_year = ISNULL ((CASE
								WHEN calendar_year % 400 = 0 THEN 1
								WHEN calendar_year % 100 = 0 THEN 0
								WHEN calendar_year % 4 = 0 THEN 1
								END),0)
	,year_week = CONVERT (VARCHAR (4), calendar_year) + RIGHT ('0' + CONVERT (VARCHAR (2), week_of_year), 2)
	,year_month = CONVERT (VARCHAR (4), calendar_year) + RIGHT ('0' + CONVERT (VARCHAR (2), calendar_month), 2)
	,year_quarter = CONVERT (VARCHAR (4), calendar_year) + 'Q' + CONVERT (VARCHAR (1), calendar_quarter)
	,year_month_day = CONVERT (VARCHAR (4), calendar_year) + RIGHT('0'+CONVERT (VARCHAR (2), calendar_month),2) + RIGHT('0'+CONVERT (VARCHAR (2), calendar_day),2)
FROM

	(
		SELECT
			 X.calendar_year AS subquery_calendar_year
			,X.calendar_quarter AS subquery_calendar_quarter
			,MIN (X.date_key) AS first_day_in_quarter
			,MAX (X.date_key) AS last_day_in_quarter
			,MIN (X.week_of_year) AS min_week_of_year_in_quarter
		FROM
			tSQLcron.dim_date X
		GROUP BY
			 X.calendar_year
			,X.calendar_quarter
	) A

WHERE
	A.subquery_calendar_year = calendar_year
	AND A.subquery_calendar_quarter = calendar_quarter


ALTER TABLE tSQLcron.dim_date ALTER COLUMN last_day_in_week DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN last_day_in_month DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN first_day_in_quarter DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN last_day_in_quarter DATETIME NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN week_of_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN week_of_quarter INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN is_leap_year INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN year_week VARCHAR (6) NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN year_month VARCHAR (6) NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN year_quarter VARCHAR (6) NOT NULL


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_last_day_in_week ON tSQLcron.dim_date (last_day_in_week)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_year_month ON tSQLcron.dim_date (year_month)


CREATE NONCLUSTERED INDEX IX_tSQLcron_dim_date_year_quarter ON tSQLcron.dim_date (year_quarter)


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update III: Populate Additional Date Xref Table Fields (Pass III)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	tSQLcron.dim_date
SET
	 is_last_day_in_month = (CASE
								WHEN last_day_in_month = date_key THEN 1
								ELSE 0
								END)
	,is_last_day_in_quarter = (CASE
									WHEN last_day_in_quarter = date_key THEN 1
									ELSE 0
									END)
	,days_in_month = DATEPART (DAY, last_day_in_month)
	,weekdays_in_month = A.weekdays_in_month
	,days_in_quarter = DATEDIFF (DAY, first_day_in_quarter, last_day_in_quarter) + 1
	,quarter_days_remaining = DATEDIFF (DAY, date_key, last_day_in_quarter)
	,weekdays_in_quarter = B.weekdays_in_quarter
	,year_days_remaining = (365 + is_leap_year) - day_of_year
FROM

	(
		SELECT
			 X.year_month AS subquery_year_month
			,SUM (X.is_weekday) AS weekdays_in_month
		FROM
			tSQLcron.dim_date X
		GROUP BY
			X.year_month
	) A

	,(
		SELECT
			 X.year_quarter AS subquery_year_quarter
			,SUM (X.is_weekday) AS weekdays_in_quarter
		FROM
			tSQLcron.dim_date X
		GROUP BY
			X.year_quarter
	 ) B

WHERE
	A.subquery_year_month = year_month
	AND B.subquery_year_quarter = year_quarter


ALTER TABLE tSQLcron.dim_date ALTER COLUMN is_last_day_in_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN is_last_day_in_quarter INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN days_in_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN weekdays_in_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN days_in_quarter INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN quarter_days_remaining INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN weekdays_in_quarter INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN year_days_remaining INT NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update IV: Populate Additional Date Xref Table Fields (Pass IV)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	tSQLcron.dim_date
SET
	 month_weekdays_remaining = weekdays_in_month - A.month_weekdays_remaining_subtraction
	,quarter_weekdays_remaining = weekdays_in_quarter - A.quarter_weekdays_remaining_subtraction
FROM

	(
		SELECT
			 X.date_key AS subquery_date_key
			,ROW_NUMBER () OVER
								(
									PARTITION BY
										X.year_month
									ORDER BY
										X.date_key
								) AS month_weekdays_remaining_subtraction
			,ROW_NUMBER () OVER
								(
									PARTITION BY
										X.year_quarter
									ORDER BY
										X.date_key
								) AS quarter_weekdays_remaining_subtraction
		FROM
			tSQLcron.dim_date X
		WHERE
			X.is_weekday = 1
	) A

WHERE
	A.subquery_date_key = date_key


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update V: Populate Additional Date Xref Table Fields (Pass V)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	X
SET
	 X.month_weekdays_remaining = (CASE
										WHEN Y.calendar_month = X.calendar_month AND Y.month_weekdays_remaining IS NOT NULL THEN Y.month_weekdays_remaining
										WHEN Z.calendar_month = X.calendar_month AND Z.month_weekdays_remaining IS NOT NULL THEN Z.month_weekdays_remaining
										ELSE X.weekdays_in_month
										END)
	,X.quarter_weekdays_remaining = (CASE
										WHEN Y.calendar_quarter = X.calendar_quarter AND Y.quarter_weekdays_remaining IS NOT NULL THEN Y.quarter_weekdays_remaining
										WHEN Z.calendar_quarter = X.calendar_quarter AND Z.quarter_weekdays_remaining IS NOT NULL THEN Z.quarter_weekdays_remaining
										ELSE X.weekdays_in_quarter
										END)
FROM
	tSQLcron.dim_date X
	LEFT JOIN tSQLcron.dim_date Y ON DATEADD (DAY, 1, Y.date_key) = X.date_key
	LEFT JOIN tSQLcron.dim_date Z ON DATEADD (DAY, 2, Z.date_key) = X.date_key
WHERE
	X.month_weekdays_remaining IS NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN month_weekdays_remaining INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN quarter_weekdays_remaining INT NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--	Table Update VI: Populate Additional Date Xref Table Fields (Pass VI)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE
	tSQLcron.dim_date
SET
	 is_week_in_same_month = A.is_week_in_same_month
	,month_days_remaining = days_in_month - calendar_day
	,month_weekdays_completed = weekdays_in_month - month_weekdays_remaining
	,quarter_days_completed = days_in_quarter - quarter_days_remaining
	,quarter_weekdays_completed = weekdays_in_quarter - quarter_weekdays_remaining
	,month_day_name_instance = A.month_day_name_instance
	,quarter_day_name_instance = A.quarter_day_name_instance
	,year_day_name_instance = A.year_day_name_instance
FROM

	(
		SELECT
			 X.date_key AS subquery_date_key
			,ISNULL ((CASE
						WHEN DATEDIFF (MONTH, X.first_day_in_week, X.last_day_in_week) = 0 THEN 1
						END), 0) AS is_week_in_same_month
			,ROW_NUMBER () OVER
								(
									PARTITION BY
										 X.year_month
										,X.day_name
									ORDER BY
										X.date_key
								) AS month_day_name_instance
			,ROW_NUMBER () OVER
								(
									PARTITION BY
										 X.year_quarter
										,X.day_name
									ORDER BY
										X.date_key
								) AS quarter_day_name_instance
			,ROW_NUMBER () OVER
								(
									PARTITION BY
										 X.calendar_year
										,X.day_name
									ORDER BY
										X.date_key
								) AS year_day_name_instance
		FROM
			tSQLcron.dim_date X
	) A

WHERE
	A.subquery_date_key = date_key


ALTER TABLE tSQLcron.dim_date ALTER COLUMN is_week_in_same_month INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN month_days_remaining INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN month_weekdays_completed INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN quarter_days_completed INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN quarter_weekdays_completed INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN month_day_name_instance INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN quarter_day_name_instance INT NOT NULL


ALTER TABLE tSQLcron.dim_date ALTER COLUMN year_day_name_instance INT NOT NULL



