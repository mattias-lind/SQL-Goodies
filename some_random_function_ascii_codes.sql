CREATE OR ALTER FUNCTION dbo.codes(
@d tinyint = NULL, 
@b char(9) = NULL, 
@h CHAR(2) = NULL, 
@a CHAR(1) = NULL
)
RETURNS TABLE
AS
RETURN (
WITH 
b (bin) AS (SELECT 0 UNION ALL SELECT 1),
o (b128, b64, b32, b16, b8, b4, b2, b1) AS (
SELECT * FROM b o1 
CROSS JOIN b o2 
CROSS JOIN b o3 
CROSS JOIN b o4 
CROSS JOIN b o5 
CROSS JOIN b o6 
CROSS JOIN b o7 
CROSS JOIN b o8
),
h AS (
SELECT 
 ROW_NUMBER() 
 OVER(ORDER BY b128, b64, b32, b16, b8, b4, b2, b1) - 1 AS d, 
 b128 * 8 + b64 * 4 + b32 * 2 + b16 AS h1, 
 b8 * 8 + b4 * 4 + b2 * 2 + b1 AS h0, 
 * 
FROM o
),
r AS (
SELECT d, CONCAT(b128, b64, b32, b16, ' ',b8, b4, b2, b1) as b,
 CASE h1 
 WHEN 10 THEN 'A' 
 WHEN 11 THEN 'B' 
 WHEN 12 THEN 'C' 
 WHEN 13 THEN 'D' 
 WHEN 14 THEN 'E'
 WHEN 15 THEN 'F'
 ELSE CAST(h1 as CHAR(1))
 END + 
 CASE h0 
 WHEN 10 THEN 'A' 
 WHEN 11 THEN 'B' 
 WHEN 12 THEN 'C' 
 WHEN 13 THEN 'D' 
 WHEN 14 THEN 'E'
 WHEN 15 THEN 'F'
 ELSE CAST(h0 as CHAR(1))
 END AS h,
 CHAR(d) AS ASCII
FROM h)
SELECT * FROM r
WHERE (
 @d = d OR 
 @b = b OR 
 @h = h OR 
 @a = ASCII
 ) OR
 (
 @d IS NULL AND 
 @b IS NULL AND 
 @h IS NULL AND 
 @a IS NULL
 )
)
