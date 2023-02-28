--ex00
-- Let’s create separated views for persons
--Please create 2 Database Views (with similar attributes like the original table) 
--based on simple filtering of gender of persons. Set the corresponding names for 
--the database views: `v_persons_female` and `v_persons_male`.
--EXAMPLE
--CREATE VIEW [Brazil Customers] AS
--SELECT CustomerName, ContactName
--FROM Customers
--WHERE Country = "Brazil";
CREATE VIEW v_persons_female AS
SELECT * FROM person
WHERE gender='female';

CREATE VIEW v_persons_male AS
SELECT * FROM person
WHERE gender='male';

--ex01
--From parts to common view
--Please use 2 Database Views from Exercise #00 and write SQL to get 
--female and male person names in one list. 
--Please set the order by person name. The sample of data is presented below.
--| name |
--| ------ |
--| Andrey |
--| Anna |
--| ... |
SELECT name FROM v_persons_female
UNION
SELECT name FROM v_persons_male
ORDER BY 1;

--ex02
--“Store” generated dates in one place
--ALLOWED: `generate_series(...)`
--Please create a Database View (with name `v_generated_dates`) which should 
--be “store” generated dates from 1st to 31th of January 2022 in DATE type. 
--Don’t forget about order for the generated_date column.  
--| generated_date |
--| ------ |
--| 2022-01-01 |
--| 2022-01-02 |
--| ... |
CREATE VIEW v_generated_dates AS
SELECT generator::DATE AS generated_date
FROM generate_series('2022-01-01', '2022-01-31', interval '1 day') AS generator
ORDER BY 1

--ex03
--Find missing visit days with Database
--Please write a SQL statement which returns missing days for persons’ visits 
--in January of 2022. Use `v_generated_dates` view for that task and 
--sort the result by missing_date column. 
--The sample of data is presented below.
--| missing_date |
--| ------ |
--| 2022-01-11 |
--| 2022-01-12 |
--| ... |
SELECT generated_date AS missing_date FROM v_generated_dates
EXCEPT
SELECT visit_date FROM person_visits
ORDER BY 1;

--ex04
-- Let’s find something from Set Theory
--Please write a SQL statement which satisfies a formula `(R - S)∪(S - R)` .
--Where R is the `person_visits` table with filter by 2nd of January 2022, 
--S is also `person_visits` table but with a different filter by 6th of January 2022. 
--Please make your calculations with sets under the `person_id` column 
--and this column will be alone in a result. 
--The result please sort by `person_id` column and your final SQL 
--please present in `v_symmetric_union` (*) database view.
--(*) to be honest, the definition “symmetric union” doesn’t exist in 
--Set Theory. This is the author's interpretation, the main idea is based 
--on the existing rule of symmetric difference.
CREATE VIEW v_symmetric_union AS
(SELECT person_id FROM person_visits WHERE visit_date='2022-01-02'
EXCEPT SELECT person_id FROM person_visits WHERE visit_date='2022-01-06')
UNION
(SELECT person_id FROM person_visits WHERE visit_date='2022-01-06'
EXCEPT SELECT person_id FROM person_visits WHERE visit_date='2022-01-02')
ORDER BY 1;

--ex05
--Let’s calculate a discount price for each person
--Please create a Database View `v_price_with_discount` that returns a person's 
--orders with person names, pizza names, real price and calculated column 
--`discount_price` (with applied 10% discount and satisfies formula `price - price*0.1`). 
--The result please sort by person name and pizza name and make a round 
--for `discount_price` column to integer type. 
--Please take a look at a sample result below.
--| name |  pizza_name | price | discount_price |
--| ------ | ------ | ------ | ------ | 
--| Andrey | cheese pizza | 800 | 720 | 
--| Andrey | mushroom pizza | 1100 | 990 |
--| ... | ... | ... | ... |
CREATE VIEW v_price_with_discount AS
SELECT person.name, menu.pizza_name, menu.price, ROUND(menu.price-menu.price*0.1) AS discount_price
FROM person_order
INNER JOIN person ON person_order.person_id=person.id
INNER JOIN menu ON person_order.menu_id=menu.id
ORDER BY 1, 2

--ex06
--Materialization from virtualization
--Please create a Materialized View `mv_dmitriy_visits_and_eats` (with data included) 
--based on SQL statement that finds the name of pizzeria Dmitriy visited on January 8, 2022 
--and could eat pizzas for less than 800 rubles (this SQL you can 
--find out at Day #02 Exercise #07). 
--To check yourself you can write SQL to Materialized View `mv_dmitriy_visits_and_eats` 
--and compare results with your previous query.
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
SELECT pizzeria.name
FROM menu
INNER JOIN pizzeria ON pizzeria.id=menu.pizzeria_id
INNER JOIN person_visits ON menu.pizzeria_id = person_visits.pizzeria_id
INNER JOIN person ON person.id = person_visits.person_id
WHERE person.name='Dmitriy' AND person_visits.visit_date='2022-01-08' AND price<800;


--ex07
--Refresh our state
--DENIED: Don’t use direct numbers for identifiers of Primary Key, person and pizzeria
--Let's refresh data in our Materialized View `mv_dmitriy_visits_and_eats` 
--from exercise #06. Before this action, please generate one more Dmitriy visit 
--that satisfies the SQL clause of Materialized View except pizzeria that we can see 
--in a result from exercise #06.
--After adding a new visit please refresh a state of data for `mv_dmitriy_visits_and_eats`.
INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
	(SELECT id FROM person WHERE name='Dmitriy'),
	(SELECT id FROM pizzeria
	INNER JOIN menu ON pizzeria.id=menu.id
	WHERE price < 800 AND pizzeria.name!='Papa Johns' ORDER BY 1 LIMIT 1),
	'2022-01-08');
	
REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;

--ex08
-- Just clear our database
--After all our exercises were born a few Virtual Tables and one Materialized View. Let’s drop them!
DROP VIEW v_generated_dates;
DROP VIEW v_persons_female;
DROP VIEW v_persons_male;
DROP VIEW v_price_with_discount;
DROP VIEW v_symmetric_union;
DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;

