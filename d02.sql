--ex00
--Please write a SQL statement which returns a list of pizzerias names with 
--corresponding rating value which have not been visited by persons.
--DENIED: `NOT IN`, `IN`, `NOT EXISTS`, `EXISTS`, `UNION`, `EXCEPT`, `INTERSECT`
SELECT name, rating
FROM (SELECT pizzeria.id AS ids, pizzeria.name AS name, pizzeria.rating AS rating, qq.count_visits AS count_visits FROM pizzeria
LEFT JOIN (SELECT pizzeria_id, COUNT(pizzeria_id) AS count_visits FROM person_visits GROUP BY pizzeria_id)AS qq
ON pizzeria.id = qq.pizzeria_id) AS aa
WHERE count_visits IS NULL;

--!!!!!!!!!!PUSH THIS
SELECT pizzeria.name as pizzeria_name, pizzeria.rating AS pizzeria_rating
FROM pizzeria
LEFT JOIN person_visits
ON pizzeria.id = person_visits.pizzeria_id
WHERE person_visits.id IS NULL;

--ex01
--DENIED: `NOT IN`, `IN`, `NOT EXISTS`, `EXISTS`, `UNION`, `EXCEPT`, `INTERSECT`
--Please write a SQL statement which returns the missing days from 1st to 10th of 
--January 2022 (including all days) for visits  of persons with identifiers 1 or 2. 
--Please order by visiting days in ascending mode. 
--The sample of data with column name is presented below.
--| missing_date |
--| ------ |
--| 2022-01-03 |
--| 2022-01-04 |
--| 2022-01-05 |
--| ... |
SELECT generator::DATE AS missing_date
FROM (SELECT * FROM person_visits WHERE person_id=1 OR person_id=2) AS pv
RIGHT JOIN generate_series('2022-01-01', '2022-01-10', interval '1 day') AS generator
ON pv.visit_date = generator
WHERE pv.id IS NULL
ORDER BY 1
--черновик
--SELECT * FROM person_visits 
--RIGHT JOIN generate_series('2022-01-01', '2022-01-10', interval '1 day') AS generator
--ON person_visits.visit_date = generator
--WHERE person_visits.person_id=1 OR person_visits.person_id=2

--ex02
--DENIED: NOT IN`, `IN`, `NOT EXISTS`, `EXISTS`, `UNION`, `EXCEPT`, `INTERSECT`
--Please write a SQL statement that returns a whole list of person names visited 
--(or not visited) pizzerias during the period from 1st to 3rd of January 2022 
--from one side and the whole list of pizzeria names which have been visited 
--(or not visited) from the other side. 
--The data sample with needed column names is presented below. 
--Please pay attention to the substitution value ‘-’ for `NULL` values in `person_name` 
--and `pizzeria_name` columns. Please also add ordering for all 3 columns.
--| person_name | visit_date | pizzeria_name |
--| ----------- | ---------- | ------------- |
--| -           | null       | DinoPizza     |
--| -           | null       | DoDo Pizza    |
--| Andrey      | 2022-01-01 | Dominos       |
--| Andrey      | 2022-01-02 | Pizza Hut     |
--| Anna        | 2022-01-01 | Pizza Hut     |
--| Denis       | null       | -             |
--| Dmitriy     | null       | -             |
--| ........... | .......... | ............. |
SELECT COALESCE(person.name, '-') AS person_name, t1.visit_date,
COALESCE(pizzeria.name, '-') AS  pizzeria_name
FROM person
	FULL JOIN (SELECT * FROM person_visits WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') AS t1
	ON person.id= t1.person_id
	FULL JOIN pizzeria
	ON pizzeria.id=t1.pizzeria_id
ORDER BY 1, 2, 3;

--ex03
--DENIED: `NOT IN`, `IN`, `NOT EXISTS`, `EXISTS`, `UNION`, `EXCEPT`, `INTERSECT`
--Let’s return back to Exercise #01, please rewrite your SQL by using 
--the CTE (Common Table Expression) pattern. 
--Please move into the CTE part of your "day generator". 
--The result should be similar like in Exercise #01
--| missing_date | 
--| ------------ | 
--| 2022-01-03   | 
--| 2022-01-04   | 
--| 2022-01-05   | 
--| ............ |
WITH generator AS (
	SELECT gen::DATE
	FROM generate_series('2022-01-01', '2022-01-10', interval '1 day') AS gen
)

SELECT gen FROM generator AS missing_date
LEFT JOIN (SELECT visit_date FROM person_visits WHERE person_id=1 OR person_id=2) AS pv
ON pv.visit_date = gen
WHERE  pv.visit_date IS NULL
ORDER BY 1;

--ex04
--Find full information about all possible pizzeria names and prices to get 
--mushroom or pepperoni pizzas. Please sort the result by pizza name and 
--pizzeria name then. The result of sample data is below 
--(please use the same column names in your SQL statement).
--| pizza_name | pizzeria_name | price |
--| ---------- | ------------- | ----- |
--| mushroom pizza | Dominos | 1100 |
--| mushroom pizza | Papa Johns | 950 |
--| pepperoni pizza | Best Pizza | 800 |
--| ... | ... | ... |
SELECT pizza_name, pizzeria.name AS pizzeria_name, price
FROM menu
INNER JOIN pizzeria
ON menu.pizzeria_id = pizzeria.id
WHERE pizza_name IN('mushroom pizza', 'pepperoni pizza')
ORDER BY 1, 2;

--ex05
--Investigate Person Data
--Find names of all female persons older than 25 and order the result by name. 
--The sample of output is presented below.
--| name | 
--| ------ | 
--| Elvira | 
--| ... |
SELECT name FROM person
WHERE gender='female' AND age > 25
ORDER BY 1;

--ex06
--Favorite pizzas for Denis and Anna
--Please find all pizza names (and corresponding pizzeria names using `menu` table) 
--that Denis or Anna ordered. Sort a result by both columns. 
--The sample of output is presented below.
--| pizza_name | pizzeria_name |
--| ------ | ------ |
--| cheese pizza | Best Pizza |
--| cheese pizza | Pizza Hut |
--| ... | ... |
SELECT menu.pizza_name, pizzeria.name AS pizzeria_name
FROM person_order
INNER JOIN person ON person.id= person_order.person_id
INNER JOIN menu ON menu.id = person_order.menu_id
INNER JOIN pizzeria ON pizzeria.id = menu.pizzeria_id
WHERE person.name IN ('Denis', 'Anna')
ORDER BY 1, 2;

--ex07
--Cheapest pizzeria for Dmitriy
--Please find the name of pizzeria Dmitriy visited on January 8, 2022 
--and could eat pizza for less than 800 rubles.
SELECT pizzeria.name
FROM menu
INNER JOIN pizzeria ON pizzeria.id=menu.pizzeria_id
INNER JOIN person_visits ON menu.pizzeria_id = person_visits.pizzeria_id
INNER JOIN person ON person.id = person_visits.person_id
WHERE person.name='Dmitriy' AND person_visits.visit_date='2022-01-08' AND price<800;

--ex08
--Continuing to research data 
--Please find the names of all males from Moscow or Samara cities who 
--orders either pepperoni or mushroom pizzas (or both) . 
--Please order the result by person name in descending mode. 
--The sample of output is presented below.
--| name | 
--| ------ | 
--| Dmitriy | 
--| ... |
SELECT DISTINCT person.name
FROM person_order
INNER JOIN person ON person_order.person_id=person.id
INNER JOIN menu ON person_order.menu_id=menu.id
WHERE person.gender='male' AND person.address IN ('Moscow', 'Samara')
AND menu.pizza_name IN ('pepperoni pizza', 'mushroom pizza')
ORDER BY 1 DESC;

--ex09
-- Who loves cheese and pepperoni?
--Please find the names of all females who ordered both pepperoni and 
--cheese pizzas (at any time and in any pizzerias). 
--Make sure that the result is ordered by person name. 
--The sample of data is presented below.
--| name | 
--| ------ | 
--| Anna | 
--| ... |
SELECT person.name
FROM person
INNER JOIN person_order
ON person.id=person_order.person_id
INNER JOIN menu
ON person_order.menu_id=menu.id
WHERE person.gender='female' AND menu.pizza_name='pepperoni pizza'
INTERSECT
SELECT person.name
FROM person
INNER JOIN person_order
ON person.id=person_order.person_id
INNER JOIN menu
ON person_order.menu_id=menu.id
WHERE person.gender='female' AND menu.pizza_name='cheese pizza';
ORDER BY

--ex10
-- Find persons from one city
--Please find the names of persons who live on the same address. 
--Make sure that the result is ordered by 1st person, 2nd person's name and common address. 
--The  data sample is presented below. 
--Please make sure your column names are corresponding column names below.
--| person_name1 | person_name2 | common_address | 
--| ------ | ------ | ------ |
--| Andrey | Anna | Moscow |
--| Denis | Kate | Kazan |
--| Elvira | Denis | Kazan |
--| ... | ... | ... |
       "Andrey"	"Anna"	"Moscow"
       "Denis"	"Kate"	"Kazan"
       "Elvira"	"Denis"	"Kazan"
       "Elvira"	"Kate"	"Kazan"
       "Peter"	"Irina"	"Saint-Petersburg"
SELECT person1.name AS person_name1, person2.name AS person_name2, person1.address AS common_address
FROM person AS person1
INNER JOIN person AS person2
ON person1.address=person2.address AND person1.id > person2.id
ORDER BY 1, 2, 3
