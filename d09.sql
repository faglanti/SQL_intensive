--ex00
-- We want to be stronger with data and don’t want to lose any event of changes. 
-- Let’s implement an audit feature for INSERT’s incoming changes. 
-- Please create a table `person_audit` with the same structure like a person 
-- table but please add a few additional changes. Take a look at the table 
-- below with descriptions for each column.

-- | Column | Type | Description |
-- | ------ | ------ | ------ |
-- | created | timestamp with time zone | timestamp when a new event has been created.  Default value is a current timestamp and NOT NULL |
-- | type_event | char(1) | possible values I (insert), D (delete), U (update). Default value is ‘I’. NOT NULL. Add check constraint `ch_type_event` with possible values ‘I’, ‘U’ and ‘D’ |
-- | row_id |bigint | copy of person.id. NOT NULL |
-- | name |varchar | copy of person.name (no any constraints) |
-- | age |integer | copy of person.age (no any constraints) |
-- | gender |varchar | copy of person.gender (no any constraints) |
-- | address |varchar | copy of person.address (no any constraints) |

-- Actually, let’s create a Database Trigger Function with the name 
-- `fnc_trg_person_insert_audit` that should process `INSERT` DML traffic 
-- and make a copy of a new row to the person_audit table.
-- Just a hint, if you want to implement a PostgreSQL trigger
--  (please read it in PostgreSQL documentation), you need to make 2 objects: 
--  Database Trigger Function and Database Trigger. 
-- So, please define a Database Trigger with the name `trg_person_insert_audit` 
-- with the next options
-- - trigger with “FOR EACH ROW” option
-- - trigger with “AFTER INSERT”
-- - trigger calls fnc_trg_person_insert_audit trigger function
-- When you are ready with trigger objects then please make an `INSERT` 
-- statement into the person table. 
-- `INSERT INTO person(id, name, age, gender, address) 
-- VALUES (10,'Damir', 22, 'male', 'Irkutsk');`
CREATE TABLE person_audit
( created timestamp with time zone not null default current_timestamp,
  type_event char(1) not null default 'I',
  row_id bigint not null,
  name varchar not null,
  age integer not null default 10,
  gender varchar not nul ,
  address varchar
  constraint ch_type_event check(type_event IN ('I', 'U', 'D'))
);

СREATE FUNCTION fnc_trg_person_insert_audit() RETURNS TRIGGER AS $trg_person_insert_audit$
	BEGIN
		INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
		VALUES(current_timestamp, 'I', NEW.id, NEW.name, NEW.age, NEW.gender. NEW.address);
		RETURN NULL;
	END;
$trg_person_insert_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_insert_audit
AFTER INSERT ON person FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address) VALUES (10,'Damir', 22, 'male', 'Irkutsk');

--ex01
-- Audit of incoming updates
-- Let’s continue to implement our audit pattern for the person table. 
-- Just define a trigger `trg_person_update_audit` and corresponding 
-- trigger function `fnc_trg_person_update_audit` to handle all `UPDATE` traffic 
-- on the person table. We should save OLD states of all attribute’s values.
-- When you are ready please apply UPDATE’s statements below.
-- `UPDATE person SET name = 'Bulat' WHERE id = 10;`
-- `UPDATE person SET name = 'Damir' WHERE id = 10;`
CREATE OR REPLACE FUNCTION fnc_trg_person_update_audit() RETURN TRIGGER AS $trg_person_update_audit$
	BEGIN
		INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
		VALUES(current_timestamp, 'U', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
		RETURN NULL;
	END;
$trg_person_update_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_update_audit
AFTER UPDATE ON person FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;

--ex02
-- Audit of incoming deletes
-- Finally, we need to handle `DELETE` statements and make a copy of OLD states 
-- for all attribute’s values. Please create a trigger `trg_person_delete_audit` 
-- and corresponding trigger function `fnc_trg_person_delete_audit`. 
-- When you are ready please apply the SQL statement below.
-- `DELETE FROM person WHERE id = 10;`

CREATE OR REPLACE fnc_trg_person_delete_audit() RETURN TRIGGER AS $trg_person_delete_audit$
	BEGIN
		INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
		VALUES(current_timestamp, 'D', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
		RETURN NULL;
	END;
$trg_person_delete_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit
AFTER DELETE FROM person FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;

--ex03
-- Actually, there are 3 triggers for one `person` table. 
-- Let’s merge all our logic to the one main trigger with 
-- the name `trg_person_audit` and a new corresponding 
-- trigger function `fnc_trg_person_audit`.
-- Other words, all DML traffic (`INSERT`, `UPDATE`, `DELETE`) should be 
-- handled from the one functional block. 
-- Please explicitly define a separated IF-ELSE block for every event (I, U, D)!
-- Additionally, please take the steps below .
-- - to drop 3 old triggers from the person table.
-- - to drop 3 old trigger functions
-- - to make a `TRUNCATE` (or `DELETE`) of all rows in our `person_audit` table
-- When you are ready, please re-apply the set of DML statements.
-- `INSERT INTO person(id, name, age, gender, address)  VALUES (10,'Damir', 22, 'male', 'Irkutsk');`
-- `UPDATE person SET name = 'Bulat' WHERE id = 10;`
-- `UPDATE person SET name = 'Damir' WHERE id = 10;`
-- `DELETE FROM person WHERE id = 10;`
DROP TRIGGER trg_person_insert_audit;
DROP TRIGGER trg_person_update_audit;
DROP TRIGGER trg_person_delete_audit;
DROP FUNCTION fnc_trg_person_insert_audit;
DROP FUNCTION fnc_trg_person_update_audit;
DROP FUNCTION fnc_trg_person_delete_audit;
TRUNCATE person_audit;

CREATE OR REPLACE fnc_trg_person_audit() RETURN TRIGGER AS $trg_person_audit$
	BEGIN
		IF (TG_OP = 'INSERT') THEN
			INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
			VALUES(current_timestamp, 'I', NEW.id, NEW.name, NEW.age, NEW.gender. NEW.address);
			RETURN NEW;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
			VALUES(current_timestamp, 'U', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
			RETURN OLD;
		ELSIF (TG_OP = 'DELETE') THEN
			INSERT INTO person_audit(created, type_event, row_id, name, age, gender, address)
			VALUES(current_timestamp, 'D', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
			RETURN OLD;
		END IF;
		RETURN NULL;
	END;
$trg_person_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit
AFTER INSERT OR UPDATE OR DELETE ON person
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_audit();

INSERT INTO person(id, name, age, gender, address)  VALUES (10,'Damir', 22, 'male', 'Irkutsk');
UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;
DELETE FROM person WHERE id = 10;

--ex04
-- Database View VS Database Function
-- As you remember, we created 2 database views to separate 
-- data from the person tables by gender attribute. 
-- Please define 2 SQL-functions 
-- (please be aware, not pl/pgsql-functions) with names
-- - `fnc_persons_female` (should return female persons)
-- - `fnc_persons_male` (should return male persons)
-- To check yourself and call a function, you can make a statement like 
-- below (amazing! you can work with a function like with a virtual table!). 
--     SELECT *
--     FROM fnc_persons_male();
--     SELECT *
--     FROM fnc_persons_female();
CREATE FUNCTION fnc_persons_female()
RETURN TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
	SELECT id, name, age, gender, address FROM person
	WHERE gender='female';
$$ LABGUAGE SQL;

CREATE FUNCTION fnc_persons_female()
RETURN TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
	SELECT id, name, age, gender, address FROM person
	WHERE gender='male';
$$ LANGUAGE SQL;


--ex05
-- Parameterized Database Function
-- Looks like 2 functions from exercise 04 need a more generic approach. 
-- Please before our further steps drop these functions from the database. 
-- Write a common SQL-function (please be aware, not pl/pgsql-function) with 
-- the name `fnc_persons`. This function should have an `IN` parameter pgender with default 
-- value = ‘female’. 
-- To check yourself and call a function, you can make a statement like 
-- below (wow! you can work with a function like with a virtual table 
-- but with more flexibilities!). 
--     select *
--     from fnc_persons(pgender := 'male');

--     select *
--     from fnc_persons();
CREATE FUNCTION fnc_persons(person_gender varchar default 'female')
RETURN TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
	SELECT id, name, age, gender, address FROM person
	WHERE gender=person_gender;
$$ LANGUAGE SQL;

--ex06
-- Let’s look at pl/pgsql functions right now. 
-- Please create a pl/pgsql function  `fnc_person_visits_and_eats_on_date` based
-- on SQL statement that finds the names of pizzerias which person (`IN` pperson parameter 
-- with default value is ‘Dmitriy’) visited and bought pizza for less than the given sum 
-- in rubles (`IN` pprice parameter with default value is 500) on the specific date 
-- (`IN` pdate parameter with default value is 8th of January 2022). 
-- To check yourself and call a function, you can make a statement like below.
--     select *
--     from fnc_person_visits_and_eats_on_date(pprice := 800);

--     select *
--     from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');
CREATE FUNCTION fnc_person_visits_and_eats_on_date(pperson VARCHAR DEFAULT 'Dmitriy',
	pprice NUMERIC DEFAULT 500, pdate DATE DEFAULT '2022-01-08')
RETURN TABLE(pizzeria_names VARCHAR) AS $$
BEGIN
RETURN QUERY
	SELECT pizzeria.name FROM pizzeria
		INNER JOIN menu ON pizzeria.id=menu.pizzeria_id
		INNER JOIN person_visits ON pizzeria.id=person_visits.pizzeria_id
		INNER JOIN person ON person_visits.person_id=person.id
	WHERE person.name=pperson, menu.price<pprice, person_visits.visit_date=pdate;
END;
$$ LANGUAGE PLPGSQL;

--ex07
-- Please write a SQL or pl/pgsql function `func_minimum` (it’s up to you) that has an input 
-- parameter is an array of numbers and the function should return a minimum value. 
-- To check yourself and call a function, you can make a statement like below.
--     SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);
CREATE OR REPLACE FUNCTION func_minimum(VARIADIC arr NUMERIC[ ])
RETURNS NUMERIC AS
$$
SELECT MIN(i) FROM unnest(arr) i;
$$ LANGUAGE SQL;


--ex08
-- Please write a SQL or pl/pgsql function `fnc_fibonacci` (it’s up to you) that 
-- has an input parameter pstop with type integer (by default is 10) and the function 
-- output is a table with all Fibonacci numbers less than pstop.
-- To check yourself and call a function, you can make a statements like below.
--     select * from fnc_fibonacci(100);
--     select * from fnc_fibonacci();
CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop INT DEFAULT 10)
RETURNS TABLE(num BIGINT) AS $$
WITH RECURSIVE func(num, num1) AS
(SELECT 0 AS num, 1 AS num1
UNION ALL
SELECT num1, num+num1 FROM func WHERE num1<pstop)
SELECT num FROM func;
$$ LANGUAGE SQL;

