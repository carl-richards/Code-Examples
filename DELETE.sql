--The DELETE statement allows you to delete a single record or multiple records from a table.

--The syntax for the DELETE statement is:

    DELETE FROM table
    WHERE predicates;


--Example #1 - Simple example

--Let's take a look at a simple example:

    DELETE FROM suppliers
    WHERE supplier_name = 'IBM';

--This would delete all records from the suppliers table where the supplier_name is IBM.

--You may wish to check for the number of rows that will be deleted. You can determine the number of rows that will be deleted by running the following SQL statement before performing the delete.

    SELECT count(*)
    FROM suppliers
    WHERE supplier_name = 'IBM';


--Example #2 - More complex example

--You can also perform more complicated deletes.

--You may wish to delete records in one table based on values in another table. Since you can't list more than one table in the FROM clause when you are performing a delete, you can use the EXISTS clause.

--For example:

    DELETE FROM suppliers
    WHERE EXISTS
      ( select customers.name
         from customers
         where customers.customer_id = suppliers.supplier_id
         and customers.customer_name = 'IBM' );

--This would delete all records in the suppliers table where there is a record in the customers table whose name is IBM, and the customer_id is the same as the supplier_id.

--Learn more about the EXISTS condition.

--If you wish to determine the number of rows that will be deleted, you can run the following SQL statement before performing the delete.

    SELECT count(*) FROM suppliers
    WHERE EXISTS
      ( select customers.name
         from customers
         where customers.customer_id = suppliers.supplier_id
         and customers.customer_name = 'IBM' );
