--ex00
--Let’s create indexes for every foreign key
--Please create a simple BTree index for every foreign key in our database. 
--The name pattern should satisfy the next rule “idx_{table_name}_{column_name}”. 
--For example, the name BTree index for the pizzeria_id column 
--in the `menu` table is `idx_menu_pizzeria_id`.
--Создание индекса-B-дерева по столбцу title в таблице films:
---CREATE UNIQUE INDEX title_idx ON films (title);
-- CREATE INDEX idx_pizzeria_id ON pizzeria(id); ЛИШНЕЕ
-- CREATE INDEX idx_person_id ON person(id); ЛИШНЕЕ
-- CREATE INDEX idx_menu_id ON menu(id); ЛИШНЕЕ
-- CREATE INDEX idx_person_visits_id ON person_visits(id);
CREATE INDEX idx_menu_pizzeria_id ON menu(pizzeria_id);
CREATE INDEX idx_person_visits_person_id ON person_visits(person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits(pizzeria_id);
CREATE INDEX idx_person_order_person_id ON person_order(person_id);
CREATE INDEX idx_person_order_menu_id ON person_order(menu_id);

--ex01
--How to see that index works?
-- Before further steps please write a SQL statement that returns pizzas’ and 
-- corresponding pizzeria names. Please take a look at the sample result below (no sort needed).
-- | pizza_name | pizzeria_name | 
-- | ------ | ------ |
-- | cheese pizza | Pizza Hut |
-- | ... | ... |
-- Let’s provide proof that your indexes are working for your SQL.
-- The sample of proof is the output of the `EXPLAIN ANALYZE` command. 
-- Please take a look at the sample output command.
--     ...
--     ->  Index Scan using idx_menu_pizzeria_id on menu m  (...)
--     ...
-- **Hint**: please think why your indexes are not working in 
-- a direct way and what should we do to enable it?
SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT menu.name AS pizza_name, pizzeria.name AS pizzeria_name
FROM menu INNER JOIN pizzeria ON menu.pizzeria_id=pizzeria.id

--ex02
--Formula is in the index. Is it Ok?
--Please create a functional B-Tree index with name `idx_person_name` 
--for the column name of the `person` table. Index should contain person names in upper case. 
--Please write and provide any SQL with proof (`EXPLAIN ANALYZE`) that index 
--idx_person_name is working. 
CREATE INDEX idx_person_name ON person(upper(name));

SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT * FROM person WHERE upper(name)='Irina';

--ex03
-- Multicolumn index for our goals
-- Please create a better multicolumn B-Tree index with the name `idx_person_order_multi` 
--for the SQL statement below.
--     SELECT person_id, menu_id,order_date
--     FROM person_order
--     WHERE person_id = 8 AND menu_id = 19;
-- The `EXPLAIN ANALYZE` command should return  the next pattern. 
-- Please be attention on "Index Only Scan" scanning!
--     Index Only Scan using idx_person_order_multi on person_order ...
-- Please provide any SQL with proof (`EXPLAIN ANALYZE`) that 
-- index `idx_person_order_multi` is working. 
CREATE INDEX idx_person_order_multi ON person_order(person_id, menu_id, order_date);

SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;

--ex04
--Uniqueness for data
--Please create a unique BTree index with the name `idx_menu_unique` on the `menu` table for
-- `pizzeria_id` and `pizza_name` columns. 
--Please write and provide any SQL with proof (`EXPLAIN ANALYZE`) that index `idx_menu_unique` 
--is working. 
CREATE INDEX idx_menu_unique ON menu(pizzeria_id, pizza_name);
SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT pizzeria_id, pizza_name
FROM menu
WHERE pizzeria_id = 4 AND pizza_name='mushroom pizza';

--ex05
-- Partial uniqueness for data
-- Please create a partial unique BTree index with the name `idx_person_order_order_date` 
-- on the `person_order` table for `person_id` and `menu_id` attributes with partial 
-- uniqueness for `order_date` column for date ‘2022-01-01’.
-- The `EXPLAIN ANALYZE` command should return  the next pattern
--     Index Only Scan using idx_person_order_order_date on person_order …
CREATE UNIQUE INDEX idx_person_order_order_date ON person_order(person_id, menu_id)
WHERE order_date='2022-01-01';

SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT * FROM person_order
WHERE order_date='2022-01-01' AND person_id = 6;

--ex06
-- Let’s make performance improvement
-- Please take a look at SQL below from a technical perspective (ignore a logical case 
-- of that SQL statement) .
--     SELECT
--         m.pizza_name AS pizza_name,
--         max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
--     FROM  menu m
--     INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
--     ORDER BY 1,2;
-- Create a new BTree index with name `idx_1` which should improve the “Execution Time” 
-- metric of this SQL. Please provide proof (`EXPLAIN ANALYZE`) that SQL was improved.
-- **Hint**: this exercise looks like a “brute force” task to find a good 
-- covering index therefore before your new test remove `idx_1` index.
-- Sample of my improvement:
-- **Before**:
--     Sort  (cost=26.08..26.13 rows=19 width=53) (actual time=0.247..0.254 rows=19 loops=1)
--     "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
--     Sort Method: quicksort  Memory: 26kB
--     ->  WindowAgg  (cost=25.30..25.68 rows=19 width=53) (actual time=0.110..0.182 rows=19 loops=1)
--             ->  Sort  (cost=25.30..25.35 rows=19 width=21) (actual time=0.088..0.096 rows=19 loops=1)
--                 Sort Key: pz.rating
--                 Sort Method: quicksort  Memory: 26kB
--                 ->  Merge Join  (cost=0.27..24.90 rows=19 width=21) (actual time=0.026..0.060 rows=19 loops=1)
--                         Merge Cond: (m.pizzeria_id = pz.id)
--                         ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=22) (actual time=0.013..0.029 rows=19 loops=1)
--                             Heap Fetches: 19
--                         ->  Index Scan using pizzeria_pkey on pizzeria pz  (cost=0.13..12.22 rows=6 width=15) (actual time=0.005..0.008 rows=6 loops=1)
--     Planning Time: 0.711 ms
--     Execution Time: 0.338 ms
-- **After**:
--     Sort  (cost=26.28..26.33 rows=19 width=53) (actual time=0.144..0.148 rows=19 loops=1)
--     "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
--     Sort Method: quicksort  Memory: 26kB
--     ->  WindowAgg  (cost=0.27..25.88 rows=19 width=53) (actual time=0.049..0.107 rows=19 loops=1)
--             ->  Nested Loop  (cost=0.27..25.54 rows=19 width=21) (actual time=0.022..0.058 rows=19 loops=1)
--                 ->  Index Scan using idx_1 on …
--                 ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..2.19 rows=3 width=22) (actual time=0.004..0.005 rows=3 loops=6)
--     …
--     Planning Time: 0.338 ms
--     Execution Time: 0.203 ms

CREATE INDEX idx_1 ON pizzeria(rating);

SET enable_seqscan =OFF;
EXPLAIN ANALYZE
SELECT m.pizza_name AS pizza_name,
max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;