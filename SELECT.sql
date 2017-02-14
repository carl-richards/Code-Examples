--The SELECT statement allows you to retrieve records from one or more tables in your database.

--The syntax for the SELECT statement is:

    SELECT columns
    FROM tables
    WHERE predicates;


--Example #1

--Let's take a look at how to select all fields from a table.

    SELECT *
    FROM suppliers
    WHERE city = 'Newark';

--In our example, we've used * to signify that we wish to view all fields from the suppliers table where the supplier resides in Newark.

--Example #2

--You can also choose to select individual fields as opposed to all fields in the table.

--For example:

    SELECT name, city, state
    FROM suppliers
    WHERE supplier_id > 1000;

--This select statement would return all name, city, and state values from the suppliers table where the supplier_id value is greater than 1000.

--Example #3

--You can also use the select statement to retrieve fields from multiple tables.

    SELECT orders.order_id, suppliers.name
    FROM suppliers, orders
    WHERE suppliers.supplier_id = orders.supplier_id;

--The result set would display the order_id and suppier name fields where the supplier_id value existed in both the suppliers and orders table.