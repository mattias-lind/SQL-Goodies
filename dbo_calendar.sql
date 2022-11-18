CREATE OR ALTER FUNCTION dbo.calendar(
	@start_year int = 2022,
	@years int = 1
	)
RETURNS @calendar TABLE (
	datekey int, 
	date date, datetime datetime, datetime2 datetime2(7), 
	datetime_end_of_day datetime, datetime2_end_of_day datetime2(7), 
	year int, month int, day int, 
	semester int, quarter int, 
	week int, day_of_week int, 
	month_name sysname, day_name sysname, 
	date_end_of_week date, datetime_end_of_week datetime, datetime2_end_of_week datetime2(7), 
	date_end_of_month date, datetime_end_of_month datetime, datetime2_end_of_month datetime2(7)
	)
AS
BEGIN
DECLARE
	@start date = DATEFROMPARTS(@start_year, 1, 1)
DECLARE
	@days int = DATEDIFF(day, @start, DATEADD(year, @years, @start));
WITH a0(col) AS (SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL),
a1(col) AS (SELECT NULL FROM a0 x CROSS JOIN a0 y CROSS JOIN a0 z),
a2(col) AS (SELECT NULL FROM a1 x CROSS JOIN a0 y CROSS JOIN a0 z),
nums(num) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 FROM a2 x CROSS JOIN a2 y CROSS JOIN a2 z),
calendar(
	datekey, 
	date, datetime, datetime2, 
	datetime_end_of_day, datetime2_end_of_day, 
	year, month, day, 
	semester, quarter, 
	week, day_of_week, 
	month_name, day_name, 
	date_end_of_week, datetime_end_of_week, datetime2_end_of_week, 
	date_end_of_month, datetime_end_of_month, datetime2_end_of_month
	) AS (
SELECT 
	CAST(CONVERT(char(8), DATEADD(day, num, @start), 112) AS int),
	DATEADD(day, num, @start), CAST(DATEADD(day, num, @start) AS datetime), CAST(DATEADD(day, num, @start) AS datetime2(7)),
	DATEADD(ms, -3, DATEADD(day, 1, CAST(DATEADD(day, num, @start) AS datetime))), DATEADD(ns, -100, DATEADD(day, 1, CAST(DATEADD(day, num, @start) AS datetime2(7)))), 
	DATEPART(year, DATEADD(day, num, @start)), DATEPART(month, DATEADD(day, num, @start)), DATEPART(day, DATEADD(day, num, @start)), 
	CEILING(DATEPART(quarter, DATEADD(day, num, @start)) / 2.0), DATEPART(quarter, DATEADD(day, num, @start)), 
	DATEPART(iso_week, DATEADD(day, num, @start)), DATEPART(weekday, DATEADD(day, num, @start)),
	DATENAME(month, DATEADD(day, num, @start)), DATENAME(weekday, DATEADD(day, num, @start)),
	DATEADD(day, 7 - DATEPART(weekday, DATEADD(day, num, @start)), DATEADD(day, num, @start)), DATEADD(ms, -3, CAST(DATEADD(day, 8 - DATEPART(weekday, DATEADD(day, num, @start)), DATEADD(day, num, @start)) AS datetime)), DATEADD(ns, -100, CAST(DATEADD(day, 8 - DATEPART(weekday, DATEADD(day, num, @start)), DATEADD(day, num, @start)) AS datetime2(7))),
	EOMONTH(DATEADD(day, num, @start)), DATEADD(ms, -3, CAST(DATEADD(day, 1, EOMONTH(DATEADD(day, num, @start))) AS datetime)), DATEADD(ns, -100, CAST(DATEADD(day, 1, EOMONTH(DATEADD(day, num, @start))) AS datetime2(7)))
FROM nums WHERE num < @days)
INSERT INTO @calendar
SELECT * FROM calendar
RETURN
END
