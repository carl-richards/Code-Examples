--The EXISTS condition is considered "to be met" if the subquery returns at least one row.

--The syntax for the EXISTS condition is:

    SELECT columns
    FROM tables
    WHERE EXISTS ( subquery );

--The EXISTS condition can be used in any valid SQL statement - select, insert, update, or delete.

--Example #1

--Let's take a look at a simple example. The following is an SQL statement that uses the EXISTS condition:

    SELECT *
    FROM suppliers
    WHERE EXISTS
      (select *
        from orders
        where suppliers.supplier_id = orders.supplier_id);

--This select statement will return all records from the suppliers table where there is at least one record in the orders table with the same supplier_id.

--Example #2 - NOT EXISTS

--The EXISTS condition can also be combined with the NOT operator.

--For example,

    SELECT *
    FROM suppliers
    WHERE not exists (select * from orders Where suppliers.supplier_id = orders.supplier_id);

--This will return all records from the suppliers table where there are no records in the orders table for the given supplier_id.

--Example #3 - DELETE Statement

--The following is an example of a delete statement that utilizes the EXISTS condition:

    DELETE FROM suppliers
    WHERE EXISTS
      (select *
        from orders
        where suppliers.supplier_id = orders.supplier_id);


--Example #4 - UPDATE Statement

--The following is an example of an update statement that utilizes the EXISTS condition:

    UPDATE suppliers     
    SET supplier_name =     ( SELECT customers.name
    FROM customers
    WHERE customers.customer_id = suppliers.supplier_id)
    WHERE EXISTS
      ( SELECT customers.name
        FROM customers
        WHERE customers.customer_id = suppliers.supplier_id);


--Example #5 - INSERT Statement

--The following is an example of an insert statement that utilizes the EXISTS condition:

    INSERT INTO suppliers
    (supplier_id, supplier_name)
    SELECT account_no, name
    FROM suppliers
    WHERE exists (select * from orders Where suppliers.supplier_id = orders.supplier_id);
