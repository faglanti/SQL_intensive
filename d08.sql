--ex00
-- Simple transaction
-- with comments for Session #1, Session #2 statements; 
-- screenshot of psql output for Session #1; 
-- screenshot of psql output for Session #2 |
-- Please for this task use the command line for PostgreSQL database (psql). 
-- You need to check how your changes will be published in the database 
-- for other database users. 
-- Actually, we need two active sessions (meaning 2 parallel sessions in the command lines). 
-- Please provide a proof that your parallel session can’t see your changes until 
-- you will make a `COMMIT`;
-- Take a look at the steps below.
-- **Session #1**
-- - update of rating for “Pizza Hut” to 5 points in a transaction mode .
-- - check that you can see a changes in session #1
-- **Session #2**
-- - check that you can’t see a changes in session #2
-- **Session #1**
-- - publish your changes for all parallel sessions.
-- **Session #2**
-- - check that you can see a changes in session #2
-- So, take a look on example of my output for Session #2.

--     pizza_db=> select * from pizzeria where name  = 'Pizza Hut';
--     id |   name    | rating
--     ----+-----------+--------
--     1 | Pizza Hut |    4.6
--     (1 row)

--     pizza_db=> select * from pizzeria where name  = 'Pizza Hut';
--     id |   name    | rating
--     ----+-----------+--------
--     1 | Pizza Hut |      5
--     (1 row)
-- You can see the same query returns different results, 
-- because the first one was run before publishing in Session#1
--  and the second one was queried after finished Session#1. 



--ex01
--ex02
--ex03
--ex04
--ex05
--ex06
--ex07
