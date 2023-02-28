--ex00
--Please make a select statement which returns all person's names and person's 
--ages from the city ‘Kazan’.
SELECT name, age FROM person WHERE address='Kazan'

--ex01
--Please make a select statement which returns names , ages for all womens 
--from the city ‘Kazan’. Yep, and please sort result by name.
SELECT name, age FROM person
WHERE address='Kazan' AND gender='female'
ORDER BY name

--ex02
--Please make 2 syntax different select statements which return a list of pizzerias 
--(pizzeria name and rating) with rating between 3.5 and 5 points 
--(including limit points) and ordered by pizzeria rating.
--- the 1st select statement must contain comparison signs  (<=, >=)
--- the 2nd select statement must contain `BETWEEN` keyword
SELECT name, rating FROM pizzeria
WHERE rating >= 3.5 AND rating <= 5
ORDER BY 2

SELECT name, rating FROM pizzeria
WHERE rating BETWEEN 3.5 AND 5
ORDER BY 2

--ex03
--Please make a select statement which returns the person's identifiers 
--(without duplication) which visited pizzerias in a period from 
--6th of January 2022 to 9th of January 2022 (including all days) 
--or visited pizzeria with identifier 2. 
--Also include ordering clause by person identifier in descending mode.
SELECT DISTINCT id
FROM person_visits
WHERE (visit_date BETWEEN '2022-01-06' AND '2022-01-09') OR pizzeria_id = 2
ORDER BY 1 DESC

--ex04
--Please make a select statement which returns one calculated field with 
--name ‘person_information’ in one string like described in the next sample:
--`Anna (age:16,gender:'female',address:'Moscow')`
--Finally , please add the ordering clause by calculated column in ascending mode.
--Please pay attention to quote symbols in your formula!
SELECT CONCAT(name, ' (age:', age, ',gender:''', gender, ''',address:''', address, ''')')
AS person_information
FROM person
ORDER BY 1

--ex05
--Please make a select statement which returns person's names 
--(based on internal query in `SELECT` clause) which made orders for the menu 
--with identifiers 13 , 14 and 18 and date of orders should equal 7th of January 2022. 
--Please be aware with "Denied Section" before your work.
--Please take a look at the pattern of internal query.
--    SELECT 
--	    (SELECT ... ) AS NAME  -- this is an internal query in a main SELECT clause
--    FROM ...
--    WHERE ...
SELECT
	(SELECT name FROM person
	WHERE id = person_order.person_id) AS NAME
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18) AND order_date = '2022-01-07'

--ex06
--Please use SQL construction from Exercise 05 and add a new calculated column 
--(use column's name ‘check_name’) with a check statement 
--(a pseudo code for this check is presented below) in the `SELECT` clause.
--    if (person_name == 'Denis') then return true
--        else return false

SELECT
	(SELECT name FROM person
	WHERE id = person_order.person_id) AS NAME,
	(SELECT CASE
			WHEN name = 'Denis' THEN TRUE
			ELSE FALSE
			END
		FROM person
		WHERE id = person_order.person_id) AS check_name
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18) AND order_date = '2022-01-07'

--ex07
--Let’s apply data intervals for the `person` table. 
--Please make a SQL statement which returns a person's identifiers, person's names 
--and interval of person’s ages (set a name of a new calculated column as ‘interval_info’) 
--based on pseudo code below. 
--    if (age >= 10 and age <= 20) then return 'interval #1'
--    else if (age > 20 and age < 24) then return 'interval #2'
--    else return 'interval #3'
--and yes...please sort a result by ‘interval_info’ column in ascending mode.

SELECT id, name,
	CASE
	WHEN age BETWEEN 10 and 20 THEN 'interval #1'
	WHEN age BETWEEN 21 and 23 THEN 'interval #2'
	ELSE 'interval #3'
	END AS interval_info
FROM person
ORDER BY 3

--ex08
--Please make a SQL statement which returns all columns from the `person_order` table 
--with rows whose identifier is an even number. The result have to order by returned 
--identifier.
SELECT *
FROM person_order
WHERE id % 2 = 0
ORDER BY id

--ex09
--Please make a select statement that returns person names and pizzeria names based on 
--the `person_visit` table with date of visit in a period from 07th of January to 09th 
--of January 2022 (including all days) (based on internal query in `FROM` clause) .
--Please take a look at the pattern of the final query.
--    SELECT (...) AS person_name ,  -- this is an internal query in a main SELECT clause
--            (...) AS pizzeria_name  -- this is an internal query in a main SELECT clause
--    FROM (SELECT … FROM person_visits WHERE …) AS pv -- this is an internal query in a main FROM clause
--    ORDER BY ...
--Please add a ordering clause by person name in ascending mode and by pizzeria name 
--in descending mode

SELECT (SELECT name FROM person WHERE id = person_id) AS person_name,
	(SELECT name FROM pizzeria WHERE id = pizzeria_id) AS pizzeria_name
FROM (SELECT person_id, pizzeria_id FROM person_visits
WHERE visit_date BETWEEN '2022-01-07' AND '2022-01-09') AS pv
ORDER BY 1, 2 DESC