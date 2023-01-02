-- This started as a thought about date and time, and using stones.
-- A CTE-solution creating three number series för days of the year, leap year, and leap year exclusion for century.
DECLARE @after_year int = 2000;
WITH
	a3(col) AS (SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL),
	a27(col) AS (SELECT NULL FROM a3 x CROSS JOIN a3 y CROSS JOIN a3 z),
	nums(num) AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1 FROM a27 x CROSS JOIN a27 y),
	day_stones(stone) AS (SELECT * FROM nums WHERE num < 366),
	leap_stones(stone) AS (SELECT * FROM nums WHERE num < 4),
	skip_stones(stone) AS (SELECT * FROM nums WHERE num < 25),
	calendar_factory AS (
		SELECT 
			s.stone as skip_stone, 
			l.stone as leap_stone, 
			d.stone as day_stone 
		FROM skip_stones s CROSS JOIN leap_stones l CROSS JOIN day_stones d
		WHERE 
			NOT (l.stone + 1 != 4 AND d.stone = 365)						-- leap year
		AND NOT ((l.stone + 1) * (s.stone + 1) % 100 = 0 AND d.stone = 365)	-- skip leap year for century
	),
	calendar(skip_stone, leap_stone, day_stone, date) AS (
		SELECT 
			skip_stone + 1, leap_stone + 1, day_stone + 1, 
			dateadd(day, day_stone, DATEFROMPARTS(@after_year + ((skip_stone * 4 + leap_stone) + 1), 1, 1)) 
		FROM calendar_factory
	)
SELECT * FROM calendar
ORDER BY 4
