--ex00
-- Simple aggregated information
-- Let’s make a simple aggregation, please write a SQL statement that returns 
-- person identifiers and corresponding number of visits in 
-- any pizzerias and sorting by count of visits in descending mode and 
-- sorting in `person_id` in ascending mode. Please take a look at the sample of data below.
-- | person_id | count_of_visits |
-- | ------ | ------ |
-- | 9 | 4 |
-- | 4 | 3 |
-- | ... | ... | 
SELECT person_id, COUNT(visit_date) AS count_of_visits FROM person_visits
GROUP BY 1
ORDER BY 2 DESC, 1


--ex01
-- Let’s see real names
-- Please change a SQL statement from Exercise 00 and return a person name (not identifier). 
-- Additional clause is  we need to see only top-4 persons with maximal visits 
-- in any pizzerias and sorted by a person name. Please take a look at the example 
-- of output data below.
-- | name | count_of_visits |
-- | ------ | ------ |
-- | Dmitriy | 4 |
-- | Denis | 3 |
-- | ... | ... |
SELECT person.name, COUNT(visit_date) AS count_of_visits FROM person_visits
INNER JOIN person ON person_visits.person_id=person.id
GROUP BY 1
ORDER BY 2 DESC, 1
LIMIT 4

--ex02
-- Restaurants statistics
-- Please write a SQL statement to see 3 favorite restaurants by visits and 
-- by orders in one list (please add an action_type column with values ‘order’ 
-- or ‘visit’, it depends on data from the corresponding table). 
-- Please take a look at the sample of data below. 
-- The result should be sorted by action_type column in ascending mode and 
-- by count column in descending mode.
-- | name | count | action_type |
-- | ------ | ------ | ------ |
-- | Dominos | 6 | order |
-- | ... | ... | ... |
-- | Dominos | 7 | visit |
-- | ... | ... | ... |

(SELECT pizzeria.name, COUNT(*) AS count, 'visit' AS action_type
FROM person_visits
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3)
UNION ALL
(SELECT pizzeria.name, COUNT(*) AS count, 'order' AS action_type
FROM person_order
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3)
ORDER BY 3, 2 DESC;

--ex03
-- Restaurants statistics
-- Please write a SQL statement to see restaurants are grouping by visits and 
-- by orders and joined with each other by using restraunt name.
-- You can use internal SQLs from Exercise 02 (restaurants by visits and by orders) 
-- without limitations of amount of rows.
-- Additioanlly, please add the next rules.
-- - calculate a sum of orders and visits for corresponding pizzeria 
-- 		(be aware, not all pizzeria keys are presented in both tables).
-- - sort results by `total_count` column in descending mode and by `name` in ascending mode.
-- Take a look at the data sample below.
-- | name | total_count |
-- | ------ | ------ |
-- | Dominos | 13 |
-- | DinoPizza | 9 |
-- | ... | ... | 
SELECT t1.name, SUM(t1.count) AS total_count
FROM
((SELECT pizzeria.name, COUNT(*) AS count, 'visit' AS action_type
FROM person_visits
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
GROUP BY 1)
UNION ALL
(SELECT pizzeria.name, COUNT(*) AS count, 'order' AS action_type
FROM person_order
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
GROUP BY 1)) AS t1
GROUP BY 1
ORDER BY 2 DESC, 1;


--ex04
-- Clause for groups
-- DENIED: Syntax construction | `WHERE`
-- Please write a SQL statement that returns the person name and 
-- corresponding number of visits in any pizzerias if the person 
-- has visited more than 3 times (> 3).
-- Please take a look at the sample of data below.
-- | name | count_of_visits |
-- | ------ | ------ |
-- | Dmitriy | 4 |
SELECT person.name, COUNT(person_visits.visit_date) AS count_of_visits
FROM person_visits
INNER JOIN person ON person_visits.person_id=person.id
GROUP BY 1
HAVING COUNT(person_visits.visit_date)>3;


--ex05
-- Person's uniqueness
-- DENIED: `GROUP BY`, any type (`UNION`,...) working with sets
-- Please write a simple SQL query that returns a list of unique person names who 
-- made orders in any pizzerias. The result should be sorted by person name. 
-- Please take a look at the sample below.
-- | name | 
-- | ------ |
-- | Andrey |
-- | Anna | 
-- | ... | 
WITH t1 AS(
	SELECT DISTINCT person_id FROM person_order
)

SELECT name FROM person
INNER JOIN t1 ON person.id=t1.person_id
ORDER BY 1

--ex06
-- Restaurant metrics
-- Please write a SQL statement that returns the amount of orders, average 
-- of price, maximum and minimum prices for sold pizza by corresponding 
-- pizzeria restaurant. The result should be sorted by pizzeria name. 
-- Please take a look at the data sample below. 
-- Round your average price to 2 floating numbers.
-- | name | count_of_orders | average_price | max_price | min_price |
-- | ------ | ------ | ------ | ------ | ------ |
-- | Best Pizza | 5 | 780 | 850 | 700 |
-- | DinoPizza | 5 | 880 | 1000 | 800 |
-- | ... | ... | ... | ... | ... |
SELECT pizzeria.name, COUNT(*) AS count_of_orders,
ROUND(AVG(menu.price), 2) AS average_price,
MAX(menu.price) AS max_price, MIN(menu.price) AS min_price
FROM person_order
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
GROUP BY 1
ORDER BY 1;

--ex07
-- Average global rating
-- Please write a SQL statement that returns a common average rating 
-- (the output attribute name is global_rating) for all restaurants. 
-- Round your average rating to 4 floating numbers.
SELECT ROUND(AVG(rating), 4) AS global_rating
FROM pizzeria;



--ex08
-- Find pizzeria’s restaurant locations
-- We know about personal addresses from our data. Let’s imagine, that 
-- particular person visits pizzerias in his/her city only. 
-- Please write a SQL statement that returns address, pizzeria name and amount of 
-- persons’ orders. The result should be sorted by address and then by 
-- restaurant name. Please take a look at the sample of output data below.
-- | address | name |count_of_orders |
-- | ------ | ------ |------ |
-- | Kazan | Best Pizza |4 |
-- | Kazan | DinoPizza |4 |
-- | ... | ... | ... | 
SELECT address, pizzeria.name, COUNT(*) AS count_of_orders
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
GROUP BY 1, 2
ORDER BY 1, 2;

--ex09
-- Explicit type transformation
-- Please write a SQL statement that returns aggregated information by person’s 
-- address , the result of “Maximal Age - (Minimal Age  / Maximal Age)” 
-- that is presented as a formula column, next one is average age per 
-- address and the result of comparison between formula and average 
-- columns (other words, if formula is greater than  average then True, 
-- otherwise False value).
-- The result should be sorted by address column. 
-- Please take a look at the sample of output data below.
-- | address | formula |average | comparison |
-- | ------ | ------ |------ |------ |
-- | Kazan | 44.71 |30.33 | true |
-- | Moscow | 20.24 | 18.5 | true |
-- | ... | ... | ... | ... |
SELECT address, ROUND(MAX(age)-(MIN(age)::DECIMAL / MAX(age)), 2) AS formula,
ROUND(AVG(age), 2) AS average, (MAX(age)-(MIN(age) / MAX(age))) > AVG(age) AS comparison
FROM person
GROUP BY 1
ORDER BY 1;


