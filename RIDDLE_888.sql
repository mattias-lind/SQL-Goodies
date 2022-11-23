/*
Have you seen this riddle?

   ABC
   ABC
+  ABC
======
=  888

What is A+B+C?

This is a fairly simple one as ABC represents unique digits.
ABC + ABC + ABC = 888
3 * ABC = 888
ABC = 888 / 3
ABC = 296
A = 2, B = 9, C = 6
2 + 9 + 6 = 17

But how do we solve this in TSQL, it involves some variables, algebra, and some string manipulation. Let's do it!
*/
DECLARE 
	@sum int = 888,
	@count_of_abc int = 3;
DECLARE 
	@abc int = @sum / @count_of_abc;
DECLARE
	@abc_string char(3) = CAST(@abc as CHAR(3))
DECLARE
	@a int = CAST(LEFT(@abc_string, 1) AS int),
	@b int = CAST(SUBSTRING(@abc_string, 2, 1) AS int),
	@c int = CAST(RIGHT(@abc_string, 1) AS int);
DECLARE
	@answer int = @a + @b + @c;
PRINT @answer;
