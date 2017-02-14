--A view is, in essence, a virtual table. It does not physically exist. Rather, it is created by a query joining one or more tables.
--Creating a VIEW

--The syntax for creating a VIEW is:

    CREATE VIEW view_name AS
    SELECT columns
    FROM table
    WHERE predicates;


--For example:

    CREATE VIEW sup_orders AS
    SELECT suppliers.supplier_id, orders.quantity, orders.price
    FROM suppliers, orders
    WHERE suppliers.supplier_id = orders.supplier_id
    and suppliers.supplier_name = 'IBM';

--This would create a virtual table based on the result set of the select statement. You can now query the view as follows:

    SELECT *
    FROM sup_orders;


--Updating a VIEW

--You can update a VIEW without dropping it by using the following syntax:

    CREATE OR REPLACE VIEW view_name AS
    SELECT columns
    FROM table
    WHERE predicates;


--For example:

    CREATE or REPLACE VIEW sup_orders AS
    SELECT suppliers.supplier_id, orders.quantity, orders.price
    FROM suppliers, orders
    WHERE suppliers.supplier_id = orders.supplier_id
    and suppliers.supplier_name = 'Microsoft';


--Dropping a VIEW

--The syntax for dropping a VIEW is:

    DROP VIEW view_name;

--For example:

    DROP VIEW sup_orders;
