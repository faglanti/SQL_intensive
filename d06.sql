--ex00
--Discounts, discounts , everyone loves discounts
--Let’s expand our data model to involve a new business feature.
-- Every person wants to see a personal discount and every business wants to 
-- be closer for clients.
-- Please think about personal discounts for people from one side 
-- and pizzeria restaurants from other. Need to create 
-- a new relational table (please set a name `person_discounts`) with the 
-- next rules:
-- - set id attribute like a Primary Key (please take a look on id 
-- column in existing tables and choose the same data type)
-- - set for attributes person_id and pizzeria_id foreign keys for 
-- corresponding tables (data types should be the same like for id 
-- columns in corresponding parent tables)
-- - please set explicit names for foreign keys constraints by 
-- pattern fk_{table_name}_{column_name},  for example 
-- `fk_person_discounts_person_id`
-- - add a discount attribute to store a value of discount in percent. 
-- Remember, discount value can be a number with floats 
-- (please just use `numeric` data type). So, please choose the 
-- corresponding data type to cover this possibility.
CREATE TABLE person_discounts
(id bigint primary key,
person_id bigint not null,
pizzeria_id bigint not null,
discount numeric not null default 1,
CONSTRAINT fk_person_discounts_pizzeria_id FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
CONSTRAINT fk_person_discounts_person_id FOREIGN KEY (person_id) REFERENCES person(id))

--ex01
-- Let’s set personal discounts
-- ALLOWED: SQL, DML, DDL
-- Actually, we created a structure to store our discounts and we are ready 
-- to go further and fill our `person_discounts` table with new records.
-- So, there is a table `person_order` that stores the history of a person's orders. 
-- Please write a DML statement (`INSERT INTO ... SELECT ...`) 
-- that makes  inserts new records into `person_discounts` table based on the next rules.
-- - take aggregated state by person_id and pizzeria_id columns 
-- - calculate personal discount value by the next pseudo code:
--     `if “amount of orders” = 1 then
--         “discount” = 10.5 
--     else if “amount of orders” = 2 then 
--         “discount” = 22
--     else 
--         “discount” = 30`
-- - to generate a primary key for the person_discounts table please use 
-- 	SQL construction below (this construction is from the WINDOW FUNCTION  SQL area).
--     `... ROW_NUMBER( ) OVER ( ) AS id ...`
INSERT INTO person_discounts(id, person_id, pizzeria_id, discount) SELECT
ROW_NUMBER() OVER () AS id,
person.id AS person_id,
pizzeria.id AS pizzeria_id,
CASE
	WHEN count(person.id) = 1 THEN 10.5
	WHEN count(person.id) = 2 THEN 22
	ELSE 30
END AS discount
FROM person
INNER JOIN person_order ON person.id=person_order.person_id
INNER JOIN menu ON person_order.menu_id=menu.id
GROUP BY person_id, menu.pizzeria_id

--ex02
-- Let’s recalculate a history of orders
-- Please write a SQL statement that returns orders with actual price and price with applied 
-- discount for each person in the corresponding pizzeria restaurant and sort
--  by person name, and pizza name. 
--  Please take a look at the sample of data below.
-- | name | pizza_name | price | discount_price | pizzeria_name | 
-- | ------ | ------ | ------ | ------ | ------ |
-- | Andrey | cheese pizza | 800 | 624 | Dominos |
-- | Andrey | mushroom pizza | 1100 | 858 | Dominos |
-- | ... | ... | ... | ... | ... |
SELECT person.name, menu.pizza_name, menu.price, 
	menu.price - (menu.price * person_discounts.discount/100) AS discount_price,
	pizzeria.name AS pizzeria_name
FROM person
INNER JOIN person_order ON person_order.person_id=person.id
INNER JOIN menu ON person_order.menu_id=menu.id
INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id
INNER JOIN person_discounts
ON menu.person_id=person_discounts.person.id AND menu.pizzeria_id=person_discounts.pizzeria_id
ORDER BY 1, 2

--ex03
-- Actually, we have to make improvements to data consistency from one side 
-- and performance tuning from the other side. Please create a multicolumn 
-- unique index (with name `idx_person_discounts_unique`) that prevents 
-- duplicates of pair values person and pizzeria identifiers.
-- After creation of a new index, please provide any simple SQL 
-- statement that shows proof of index usage (by using `EXPLAIN ANALYZE`).
-- The example of “proof” is below
--     ...
--     Index Scan using idx_person_discounts_unique on person_discounts
--     ...
CREATE UNIQUE INDEX idx_person_discounts_unique ON person_discounts(person_id, pizzeria_id);
SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT * FROM person_discounts
WHERE person_id = 6 AND pizzeria_id=4

--ex04
--  We need more Data Consistency
--  Please add the following constraint rules for existing columns 
--  	of the `person_discounts` table.
-- - person_id column should not be NULL (use constraint name `ch_nn_person_id`)
-- - pizzeria_id column should not be NULL (use constraint name `ch_nn_pizzeria_id`)
-- - discount column should not be NULL (use constraint name `ch_nn_discount`)
-- - discount column should be 0 percent by default
-- - discount column should be in a range values from 0 to 100 
-- 	(use constraint name `ch_range_discount`)

-- CREATE TABLE person_discounts
-- (id bigint primary key,
-- person_id bigint not null,
-- pizzeria_id bigint not null,
-- discount numeric not null default 1,
-- CONSTRAINT fk_person_discounts_pizzeria_id FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
-- CONSTRAINT fk_person_discounts_person_id FOREIGN KEY (person_id) REFERENCES person(id))

ALTER TABLE person_discounts ADD CONSTRAINT ch_nn_person_id CHECK(person_id IS NOT NULL);
ALTER TABLE person_discounts ADD CONSTRAINT ch_nn_pizzeria_id CHECK(pizzeria_id IS NOT NULL);
ALTER TABLE person_discounts ADD CONSTRAINT ch_nn_discount CHECK(discount IS NOT NULL);
ALTER TABLE person_discounts ALTER column discount SET DEFAULT 0;
ALTER TABLE person_discounts ADD CONSTRAINT ch_range_discount CHECK(discount BETWEEN 0 AND 100);

--ex05
-- Data Governance Rules
-- To satisfy Data Governance Policies need to add comments for the table and table's columns. 
-- Let’s apply this policy for the `person_discounts` table. 
-- Please add English or Russian comments (it's up to you) 
-- that explain what is a business goal of a table and all included attributes. 
COMMENT ON TABLE person_discounts IS 'Table with personal discounts for people in pizzerias';
COMMENT ON COLUMN person_discounts.id IS 'Column with the identifier of the discount';
COMMENT ON COLUMN person_discounts.person_id IS 'Column with the identifier of the person, who take the discount';
COMMENT ON COLUMN person_discounts.pizzeria_id IS 'Column with the identifier of the pizzeria in which person has a discount';
COMMENT ON COLUMN person_discounts.discount IS 'Column with the amount of discount';

--ex06
--  Let’s automate Primary Key generation
-- DENIED: Don’t use hard-coded value for amount of rows to set a right value for sequence
-- Let’s create a Database Sequence with the name `seq_person_discounts` 
-- (starting from 1 value) and set a default value for id attribute of `person_discounts` 
-- table to take a value from `seq_person_discounts` each time automatically. 
-- Please be aware that your next sequence number is 1, in this case please set 
-- an actual value for database sequence based on formula “amount of rows 
-- in person_discounts table” + 1. Otherwise you will get errors about Primary Key 
-- violation constraint.
CREATE SEQUENCE seq_person_discounts START 1;
SELECT setval('seq_person_discounts', (SELECT COUNT(*)+1 FROM person_discounts));
ALTER TABLE person_discounts ALTER id SET DEFAULT nextval('seq_person_discounts');

