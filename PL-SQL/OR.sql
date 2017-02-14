The OR condition allows you to create an SQL statement where records are returned when any one of the conditions are met. It can be used in any valid SQL statement - select, insert, update, or delete.

The syntax for the OR condition is:

    SELECT columns
    FROM tables
    WHERE column1 = 'value1'
    or column2 = 'value2';

The OR condition requires that any of the conditions be must be met for the record to be included in the result set. In this case, column1 has to equal 'value1' OR column2 has to equal 'value2'.

Example #1

--The first example that we'll take a look at involves a very simple example using the OR condition.

    SELECT *
    FROM suppliers
    WHERE city = 'New York'
    or city = 'Newark';

--This would return all suppliers that reside in either New York or Newark. Because the * is used in the select, all fields from the suppliers table would appear in the result set.

--Example #2

--The next example takes a look at three conditions. If any of these conditions is met, the record will be included in the result set.

    SELECT supplier_id
    FROM suppliers
    WHERE name = 'IBM'
    or name = 'Hewlett Packard'
    or name = 'Gateway';

--This SQL statement would return all supplier_id values where the supplier's name is either IBM, Hewlett Packard or Gateway.

--The AND and OR conditions can be combined in a single SQL statement. It can be used in any valid SQL statement - select, insert, update, or delete.

--When combining these conditions, it is important to use brackets so that the database knows what order to evaluate each condition.

--Example #1

--The first example that we'll take a look at an example that combines the AND and OR conditions.

    SELECT *
    FROM suppliers
    WHERE (city = 'New York' and name = 'IBM')
    or (city = 'Newark');

--This would return all suppliers that reside in New York whose name is IBM and all suppliers that reside in Newark. The brackets determine what order the AND and OR conditions are evaluated in.

--Example #2

--The next example takes a look at a more complex statement.

--For example:

    SELECT supplier_id
    FROM suppliers
    WHERE (name = 'IBM')
    or (name = 'Hewlett Packard' and city = 'Atlantic City')
    or (name = 'Gateway' and status = 'Active' and city = 'Burma');

--This SQL statement would return all supplier_id values where the supplier's name is IBM or the name is Hewlett Packard and the city is Atlantic City or the name is Gateway, the status is Active, and the city is Burma.