--ex00
--Let’s find appropriate prices for Kate
--Please write a SQL statement which returns a list of pizza names, 
--pizza prices, pizzerias names and dates of visit for Kate and 
--for prices in range from 800 to 1000 rubles. 
--Please sort by pizza, price and pizzeria names. 
--Take a look at the sample of data below.
--| pizza_name | price | pizzeria_name | visit_date |
--| ------ | ------ | ------ | ------ |
--| cheese pizza | 950 | DinoPizza | 2022-01-04 |
--| pepperoni pizza | 800 | Best Pizza | 2022-01-03 |
--| pepperoni pizza | 800 | DinoPizza | 2022-01-04 |
--| ... | ... | ... | ... |
SELECT menu.pizza_name, menu.price, pizzeria.name, person_visits.visit_date
FROM menu
INNER JOIN pizzeria
ON menu.pizzeria_id=pizzeria.id
INNER JOIN person_visits
ON pizzeria.id=person_visits.pizzeria_id
INNER JOIN person
ON person.id=person_visits.person_id
WHERE person.name='Kate' AND menu.price BETWEEN 800 AND 1000
ORDER BY 1, 2, 3;

--ex01
--Let’s find forgotten menus
--Denied: any type of `JOINs`
--Please find all menu identifiers which are not ordered by anyone. 
--The result should be sorted by identifiers. 
--The sample of output data is presented below.
--| menu_id |
--| ------ |
--| 5 |
--| 10 |
--| ... |
SELECT id AS menu_id FROM menu
EXCEPT
SELECT menu_id FROM person_order
ORDER BY 1

--ex02
-- Let’s find forgotten pizza and pizzerias
--Please use SQL statement from Exercise #01 and show pizza names from pizzeria 
--which are not ordered by anyone, including corresponding prices also. 
--The result should be sorted by pizza name and price. 
--The sample of output data is presented below.
--| pizza_name | price | pizzeria_name |
--| ------ | ------ | ------ |
--| cheese pizza | 700 | Papa Johns |
--| cheese pizza | 780 | DoDo Pizza |
--| ... | ... | ... |
SELECT menu.pizza_name, menu.price, pizzeria.name
FROM (SELECT id AS menu_id FROM menu
	EXCEPT SELECT menu_id FROM person_order) as qq
INNER JOIN menu
ON qq.menu_id=menu.id
INNER JOIN pizzeria
ON menu.pizzeria_id=pizzeria.id
ORDER BY 1, 2;

--ex03
-- Let’s compare visits
--Please find a union of pizzerias that have been visited either women or men. 
--Other words, you should find a set of pizzerias names have been visited by females only 
--and make "UNION" operation with set of pizzerias names have been visited by males only. 
--Please be aware with word “only” for both genders. 
--For any SQL operators with sets save duplicates 
--(`UNION ALL`, `EXCEPT ALL`, `INTERSECT ALL` constructions). 
--Please sort a result by the pizzeria name. The data sample is provided below.
--| pizzeria_name | 
--| ------ | 
--| Best Pizza | 
--| Dominos |
--| ... |
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_visits ON person.id=person_visits.person_id
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
WHERE person.gender='female'
EXCEPT ALL
SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_visits ON person.id=person_visits.person_id
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
WHERE person.gender='male')
UNION ALL
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_visits ON person.id=person_visits.person_id
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
WHERE person.gender='male'
EXCEPT ALL
SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_visits ON person.id=person_visits.person_id
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
WHERE person.gender='female')
ORDER BY 1;

--ex04
--Let’s compare orders
--Please find a union of pizzerias that have orders either from women or from men.
--Other words, you should find a set of pizzerias names have been ordered by 
--females only and make "UNION" operation with set of pizzerias names have been ordered 
--by males only. Please be aware with word “only” for both genders. 
--For any SQL operators with sets don’t save duplicates (`UNION`, `EXCEPT`, `INTERSECT`).  
--Please sort a result by the pizzeria name. The data sample is provided below.
--| pizzeria_name | 
--| ------ | 
--| Papa Johns |
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
WHERE person.gender='female'
EXCEPT
SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
WHERE person.gender='male')
UNION
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
WHERE person.gender='male'
EXCEPT
SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
WHERE person.gender='female')
ORDER BY 1;


--ex05
--Visited but did not make any order
--Please write a SQL statement which returns a list of pizzerias 
--which Andrey visited but did not make any orders. 
--Please order by the pizzeria name. 
--The sample of data is provided below.
--| pizzeria_name | 
--| ------ | 
--| Pizza Hut | 
--| ... |
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_visits ON person.id=person_visits.person_id
INNER JOIN pizzeria ON person_visits.pizzeria_id=pizzeria.id
WHERE person.name='Andrey')
EXCEPT
(SELECT pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id = menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
WHERE person.name='Andrey')
ORDER BY 1

--ex06
--Find price-similarity pizzas
--Please find the same pizza names who have the same price, but from different pizzerias. 
--Make sure that the result is ordered by pizza name. The sample of data is presented below. 
--Please make sure your column names are corresponding column names below.
--| pizza_name | pizzeria_name_1 | pizzeria_name_2 | price |
--| ------ | ------ | ------ | ------ |
--| cheese pizza | Best Pizza | Papa Johns | 700 |
--| ... | ... | ... | ... |
SELECT menu.pizza_name AS pizza_name, pizzeria1.name AS pizzeria_name_1, pizzeria2.name AS pizzeria_name_2, menu.price
FROM menu
INNER JOIN pizzeria AS pizzeria1 ON menu.pizzeria_id=pizzeria.id
INNER JOIN pizzeria AS pizzeria2 ON pizzeria1.
ON 

SELECT m1.id, m1.pizza_name, m1.price, pizzeria1.name, m2.id, m2.pizza_name, m2.price, pizzeria2.name FROM menu AS m1
INNER JOIN menu AS m2 ON m1.price=m2.price AND m1.pizza_name=m2.pizza_name AND m1.pizzeria_id>m2.pizzeria_id
INNER JOIN pizzeria AS pizzeria1 ON m1.pizzeria_id=pizzeria1.id
INNER JOIN pizzeria AS pizzeria2 ON m2.pizzeria_id=pizzeria2.id
ORDER BY 2

!!!!!!!!!FINAL
SELECT m1.pizza_name, pizzeria1.name, pizzeria2.name, m2.price FROM menu AS m1
INNER JOIN menu AS m2 ON m1.price=m2.price AND m1.pizza_name=m2.pizza_name AND m1.pizzeria_id>m2.pizzeria_id
INNER JOIN pizzeria AS pizzeria1 ON m1.pizzeria_id=pizzeria1.id
INNER JOIN pizzeria AS pizzeria2 ON m2.pizzeria_id=pizzeria2.id
ORDER BY 1;

--ex07
--Let’s cook a new type of pizza
--Please register a new pizza with name “greek pizza” (use id = 19) with price 800 rubles 
--in “Domino's” restaurant (pizzeria_id = 2).
--**Warning**: this exercise will probably be the cause  of changing data in the wrong way. 
--Actually, you can restore the initial database model with data from the link in the 
--“Rules of the day” section.
--MY SCRIPT TO DELETE: (Example: DELETE FROM `USERS` WHERE `ID` = 2 LIMIT 1;)
--DELETE FROM menu WHERE id = 19;
INSERT INTO menu(id, pizzeria_id, pizza_name, price) VALUES (19, 2, 'greek pizza', 800)


--ex08
--Let’s cook a new type of pizza with more dynamics
--Denied: Don’t use direct numbers for identifiers of Primary Key and pizzeria
--Please register a new pizza with name “sicilian pizza” (whose id should be calculated 
--by formula is “maximum id value + 1”) with a price of 900 rubles in “Domino's” restaurant 
--(please use internal query to get identifier of pizzeria).
--**Warning**: this exercise will probably be the cause  of changing data in the wrong way. 
--Actually, you can restore the initial database model with data from the link 
--in the “Rules of the day” section and replay script from Exercise 07.
--MY SCRIPT TO DELETE: DELETE FROM menu WHERE id = 20;
INSERT INTO menu(id, pizzeria_id, pizza_name, price) VALUES ((SELECT MAX(id) + 1 FROM menu), (SELECT id FROM pizzeria WHERE name = 'Dominos'), 'sicilian pizza', 900)

--ex09
--New pizza means new visits
--DENIED: SQL Syntax Pattern | Don’t use direct numbers for identifiers of Primary Key and pizzeria
--Please register new visits into Domino's restaurant from Denis and Irina on 24th of February 2022.
--**Warning**: this exercise will probably be the cause  of changing data in the wrong way. 
--Actually, you can restore the initial database model with data from the link 
--in the “Rules of the day” section and replay script from Exercises 07 and 08..
INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
(SELECT id FROM person WHERE name='Denis'),
(SELECT id FROM pizzeria WHERE name='Dominos'), '2022-02-24');

INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
(SELECT id FROM person WHERE name='Irina'),
(SELECT id FROM pizzeria WHERE name='Dominos'), '2022-02-24');

--ex10
--New visits means new orders
--DENIED: Don’t use direct numbers for identifiers of Primary Key and pizzeria
--Please register new orders from Denis and Irina on 24th of February 2022 
--for the new menu with “sicilian pizza”.
--**Warning**: this exercise will probably be the cause  of changing data 
--in the wrong way. Actually, you can restore the initial database model
-- with data from the link in the “Rules of the day” section and replay 
--script from Exercises 07 , 08 and 09.
INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) + 1 FROM person_order),
(SELECT id FROM person WHERE name='Denis'),
(SELECT id FROM menu WHERE pizza_name='sicilian pizza'), '2022-02-24');

INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) + 1 FROM person_order),
(SELECT id FROM person WHERE name='Irina'),
(SELECT id FROM menu WHERE pizza_name='sicilian pizza'), '2022-02-24');

--ex11
--“Improve” a price for clients
--Please change the price for “greek pizza” on -10% from the current value.
--**Warning**: this exercise will probably be the cause  of 
--changing data in the wrong way. 
--Actually, you can restore the initial database model with data 
--from the link in the “Rules of the day” section and 
--replay script from Exercises 07 , 08 ,09 and 10.
UPDATE menu SET price = price * 0.9 WHERE pizza_name='greek pizza';

--ex12
--New orders are coming!
--ALLOWED: `generate_series(...)`; Please use “insert-select” 
---pattern `INSERT INTO ... SELECT ...`|
--DENIED: Don’t use direct numbers for identifiers of Primary Key, and menu 
--- Don’t use window functions like `ROW_NUMBER( )`
--- Don’t use atomic `INSERT` statements |
--Please register new orders from all persons for “greek pizza” by 25th of February 2022.
--**Warning**: this exercise will probably be the cause  of changing data 
--in the wrong way. Actually, you can restore the initial database model 
--with data from the link in the “Rules of the day” section and replay 
--script from Exercises 07 , 08 ,09 , 10 and 11.
INSERT INTO person_order(id, person_id, menu_id, order_date)
SELECT
generator+(SELECT MAX(id) FROM person_order) as id, id AS person_id,
	(SELECT id FROM menu WHERE pizza_name='greek pizza') AS menu_id,
	'2022-02-25' AS order_date FROM person
	INNER JOIN generate_series(1, (SELECT count(*) FROM person)) as generator
	ON generator=person_id;

--ex13
--Money back to our customers
--Please write 2 SQL (DML) statements that delete all new orders from 
--exercise #12 based on order date. Then delete “greek pizza” from the menu. 
--**Warning**: this exercise will probably be the cause  of changing data 
--in the wrong way. Actually, you can restore the initial database model 
--with data from the link in the “Rules of the day” section and replay 
--script from Exercises 07 , 08 ,09 , 10 , 11, 12 and 13.
DELETE FROM person_order WHERE order_date = '2022-02-25';
DELETE FROM menu WHERE pizza_name = 'greek pizza';
