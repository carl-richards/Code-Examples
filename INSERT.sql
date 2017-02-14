--The INSERT statement allows you to insert a single record or multiple records into a table.

--The syntax for the INSERT statement is:

    INSERT INTO table
    (column-1, column-2, ... column-n)
    VALUES
    (value-1, value-2, ... value-n);


--Example #1 - Simple example

--Let's take a look at a very simple example.

    INSERT INTO suppliers
    (supplier_id, supplier_name)
    VALUES
    (24553, 'IBM');

--This would result in one record being inserted into the suppliers table. This new record would have a supplier_id of 24553 and a supplier_name of IBM.

--Example #2 - More complex example

--You can also perform more complicated inserts using sub-selects.

--For example:

    INSERT INTO suppliers
    (supplier_id, supplier_name)
    SELECT account_no, name
    FROM customers
    WHERE city = 'Newark';

--By placing a "select" in the insert statement, you can perform multiples inserts quickly.

--With this type of insert, you may wish to check for the number of rows being inserted. You can determine the number of rows that will be inserted by running the following SQL statement before performing the insert.

    SELECT count(*)
    FROM customers
    WHERE city = 'Newark';
