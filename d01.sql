--ex00
--Please write a SQL statement which returns menu’s identifier and 
--pizza names from `menu` table and person’s identifier and person 
--name from `person` table in one global list (with column names as 
--presented on a sample below) ordered by object_id and then by 
--object_name columns.
--| object_id | object_name |
--| ------ | ------ |
--| 1 | Anna |
--| 1 | cheese pizza |
--| ... | ... |
SELECT id AS object_id, pizza_name AS object_name FROM menu
UNION
SELECT id AS object_id, name AS object_name FROM person
ORDER BY 1, 2

--ex01
--UNION dance with subquery
--Please modify a SQL statement from “exercise 00” by removing the object_id 
--column. Then change ordering by object_name for part of data from the 
--`person` table and then from `menu` table (like presented on a sample below). 
--Please save duplicates!
--| object_name |
--| ------ |
--| Andrey |
--| Anna |
--| ... |
--| cheese pizza |
--| cheese pizza |
--| ... |
SELECT name AS object_name FROM person ORDER BY 1
UNION ALL
SELECT pizza_name AS object_name FROM menu ORDER BY 1

--ex02
--Duplicates or not duplicates
--Please write a SQL statement which returns unique pizza names from 
--the `menu` table and orders by pizza_name column in descending mode. 
--Please pay attention to the Denied section.
SELECT DISTINCT pizza_name FROM menu ORDER BY 1 DESC
--other
SELECT pizza_name FROM menu
UNION
SELECT pizza_name FROM menu
order by pizza_name DESC;

--ex03
--“Hidden” Insights 
--Please write a SQL statement which returns common rows for attributes 
--order_date, person_id from `person_order` table from one side and visit_date, 
--person_id from `person_visits` table from the other side (please see a sample 
--below). In other words, let’s find identifiers of persons, 
--who visited and ordered some pizza on the same day. Actually, please add 
--ordering by action_date in ascending mode and then by person_id 
--in descending mode.
--| action_date | person_id |
--| ------ | ------ |
--| 2022-01-01 | 6 |
--| 2022-01-01 | 2 |
--| 2022-01-01 | 1 |
--| 2022-01-03 | 7 |
--| 2022-01-04 | 3 |
--| ... | ... |
SELECT order_date AS action_date, person_id
FROM person_order
INTERSECT
SELECT visit_date AS action_date, person_id
FROM person_visits
ORDER BY 1, 2 DESC

--ex04
-- Difference? Yep, let's find the difference between multisets
--Please write a SQL statement which returns a difference (minus) of person_id 
--column values with saving duplicates between `person_order` table and 
--`person_visits` table for order_date and visit_date are for 
--7th of January of 2022
SELECT person_id
FROM person_order
WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id
FROM person_visits
WHERE visit_date = '2022-01-07'

--ex05
-- Did you hear about Cartesian Product?
--Please write a SQL statement which returns all possible combinations between `person` and `pizzeria` 
--tables and please set ordering by person identifier and then by pizzeria identifier columns. 
--Please take a look at the result sample below. Please be aware column's names can be different for you.
--| person.id | person.name | age | gender | address | pizzeria.id | pizzeria.name | rating |
--| --------- | ----------- | --- | ------ | ------- | ----------- | ------------- | ------ |
--| 1         | Anna        | 16  | female | Moscow  | 1           | Pizza Hut     | 4.6    |
--| 1         | Anna        | 16  | female | Moscow  | 2           | Dominos       | 4.3    |
--| ......... | ........... | ... | ...... | ....... | ........... | ............. | ...... |
SELECT *
FROM person
CROSS JOIN pizzeria
ORDER BY person.id, pizzeria.id

--ex06
--Lets see on “Hidden” Insights
--Let's return our mind back to exercise #03 and change our SQL statement to return 
--person names instead of person identifiers and change ordering by action_date 
--in ascending mode and then by person_name in descending mode. 
--Please take a look at a data sample below.
--| action_date | person_name |
--| ----------- | ----------- |
--| 2022-01-01  | Irina       |
--| 2022-01-01  | Anna        |
--| 2022-01-01  | Andrey      |
--| ........... | ........... |
SELECT person_order.order_date AS action_date, person.name AS person_name
FROM person_order, person
WHERE person.id = person_order.person_id
INTERSECT
SELECT person_visits.visit_date AS action_date, person.name AS person_name
FROM person_visits, person
WHERE person.id = person_visits.person_id
ORDER BY 1, 2 DESC;

--ex07
--Just make a JOIN
--Please write a SQL statement which returns the date of order from the `person_order` 
--table and corresponding person name (name and age are formatted as in the data 
--sample below) which made an order from the `person` table. 
--Add a sort by both columns in ascending mode.
--| order_date | person_information |
--| ---------- | ------------------ |
--| 2022-01-01 | Andrey (age:21)    |
--| 2022-01-01 | Andrey (age:21)    |
--| 2022-01-01 | Anna (age:16)      |
--| .......... | .................. |
SELECT person_order.order_date, CONCAT(person.name, '(age:', person.age, ')') AS person_information
FROM person_order
INNER JOIN person
ON person_order.person_id = person.id
ORDER BY 1, 2


--ex08
--Migrate JOIN to NATURAL JOIN
--Please rewrite a SQL statement from exercise #07 by using NATURAL JOIN construction. 
--The result must be the same like for exercise #07.  
SELECT order_date, CONCAT(person.name, '(age:', person.age, ')') AS person_information
FROM person
NATURAL JOIN (SELECT order_date, person_id as id FROM person_order) AS i
ORDER BY 1, 2;

--ex09
--IN versus EXISTS
--Please write 2 SQL statements which return a list of pizzerias names which 
--have not been visited by persons by using IN for 1st one and EXISTS for the 2nd one.
SELECT name
FROM pizzeria
WHERE id NOT IN (SELECT pizzeria_id FROM person_visits);

SELECT name
FROM pizzeria
WHERE NOT EXISTS (SELECT pizzeria_id FROM person_visits WHERE pizzeria_id=pizzeria.id);

--ex10
--Global JOIN
--Please write a SQL statement which returns a list of the person names which made 
--an order for pizza in the corresponding pizzeria. The sample result 
--(with named columns) is provided below and yes ... 
--please make ordering by 3 columns in ascending mode.
--| person_name | pizza_name     | pizzeria_name | 
--| ----------- | -------------- | ------------- |
--| Andrey      | cheese pizza   | Dominos       |
--| Andrey      | mushroom pizza | Dominos       |
--| Anna        | cheese pizza   | Pizza Hut     |
--| ........... | .............. | ............. |
SELECT
	(SELECT name FROM person WHERE id = person_name) AS person_name,
	(SELECT pizza_name FROM menu WHERE id = pizza_n) AS pizza_name,
	(SELECT name FROM pizzeria WHERE id = pizzeria_name) AS pizzeria_name
FROM (SELECT po.person_id AS person_name, po.menu_id AS pizza_n, 
	pv.pizzeria_id AS pizzeria_name
FROM person_order AS po
JOIN person_visits AS pv
ON po.order_date= pv.visit_date AND po.person_id =  pv.person_id) AS foo
ORDER BY 1, 2, 3;
