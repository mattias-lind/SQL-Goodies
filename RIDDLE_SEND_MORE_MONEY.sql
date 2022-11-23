/*

Have you ever seen this riddle?

One day a father got this text from his son, immediatly he new what to do and wired his son the exact amout.

From Son:
-Hi dad, SEND+MORE=MONEY

From Father:
-Hi son, I'll wire you the MONEY ASAP. Mom says hi.

So how did the father know how much to send? No number is used twice for different letters.

Let us use SQL Server as a Statefull Machine, and have that solve it for us. 

We know for sure that M must be 1 as it cannot be 0 
and the largest two digit combo can be 8 and 9 resulting in 17, 
and if we add a carry-over it can maximun become 18.
We also know that S must be 8 or 9 as S + M must be 10 or larger.
We also know that MONEY must be larger than 10000.

*/

-- First, we need a number array, let us utilize Common Table Expression and the ROW_NUMBER() function, and a bunch of NULL of course.
WITH
-- This gives us a resultset with three rows
	a0(col) AS (SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL) 
-- This gives us a resultset with the numbers 0 to 26
,	nums(num) AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1 FROM a0 x CROSS JOIN a0 y CROSS JOIN a0 z) 
-- This is a resultset of the numbers 0 to 9, we use this to create the numbers
,	digits(digit) AS (SELECT * FROM nums WHERE num < 10) 
,	riddle(S, E, N, D, M, O, R, Y, SEND, MORE, MONEY) AS (
SELECT 
	*, 
	s.digit * 1000 + e.digit * 100 + n.digit * 10 + d.digit, -- This is the formula for SEND.
	m.digit * 1000 + o.digit * 100 + r.digit * 10 + e.digit, -- This is the formula for MORE.
	m.digit * 10000 + o.digit * 1000 + n.digit * 100 + e.digit * 10 + y.digit -- This is the formula for MONEY.
FROM	   digits s 
CROSS JOIN digits e 
CROSS JOIN digits n 
CROSS JOIN digits d 
CROSS JOIN digits m 
CROSS JOIN digits o 
CROSS JOIN digits r 
CROSS JOIN digits y
WHERE -- First we make sure numbers are not repeated, then we also add the known facts for S and M.
	s.digit NOT IN (e.digit, n.digit, d.digit, m.digit, o.digit, r.digit, y.digit)
AND e.digit NOT IN (s.digit, n.digit, d.digit, m.digit, o.digit, r.digit, y.digit)
AND n.digit NOT IN (s.digit, e.digit, d.digit, m.digit, o.digit, r.digit, y.digit)
AND d.digit NOT IN (s.digit, e.digit, n.digit, m.digit, o.digit, r.digit, y.digit)
AND m.digit NOT IN (s.digit, e.digit, n.digit, d.digit, o.digit, r.digit, y.digit)
AND o.digit NOT IN (s.digit, e.digit, n.digit, d.digit, m.digit, r.digit, y.digit)
AND r.digit NOT IN (s.digit, e.digit, n.digit, d.digit, m.digit, o.digit, y.digit)
AND y.digit NOT IN (s.digit, e.digit, n.digit, d.digit, m.digit, o.digit, r.digit)
-- And finally we also add the required calculation.
AND s.digit * 1000 + e.digit * 100 + n.digit * 10 + d.digit +					--    SEND
	m.digit * 1000 + o.digit * 100 + r.digit * 10 + e.digit =					-- +  MORE
	m.digit * 10000 + o.digit * 1000 + n.digit * 100 + e.digit * 10 + y.digit	-- = MONEY
AND m.digit * 10000 + o.digit * 1000 + n.digit * 100 + e.digit * 10 + y.digit > 10000
)
SELECT * FROM riddle
