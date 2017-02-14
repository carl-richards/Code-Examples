--The ORDER BY clause allows you to sort the records in your result set. The ORDER BY clause can only be used in SELECT statements.

----***PLEASE BEWARE THAT BY ADDING AN ORDER BY IT CAN INCREASE THE COST OF YOUR QUERY TEN FOLD***

--The syntax for the ORDER BY clause is:

    SELECT columns
    FROM tables
    WHERE predicates
    ORDER BY column ASC/DESC;

--The ORDER BY clause sorts the result set based on the columns specified. If the ASC or DESC value is omitted, it is sorted by ASC.

--ASC indicates ascending order. (default)
--DESC indicates descending order.

--Example #1

    SELECT supplier_city
    FROM suppliers
    WHERE supplier_name = 'IBM'
    ORDER BY supplier_city;

--This would return all records sorted by the supplier_city field in ascending order.

--Example #2

    SELECT supplier_city
    FROM suppliers
    WHERE supplier_name = 'IBM'
    ORDER BY supplier_city DESC;

--This would return all records sorted by the supplier_city field in descending order.

--Example #3

--You can also sort by relative position in the result set, where the first field in the result set is 1. The next field is 2, and so on.

    SELECT supplier_city
    FROM suppliers
    WHERE supplier_name = 'IBM'
    ORDER BY 1 DESC;

--This would return all records sorted by the supplier_city field in descending order, since the supplier_city field is in position #1 in the result set.

--Example #4

    SELECT supplier_city, supplier_state
    FROM suppliers
    WHERE supplier_name = 'IBM'
    ORDER BY supplier_city DESC, supplier_state ASC;

--This would return all records sorted by the supplier_city field in descending order, with a secondary sort by supplier_state in ascending order.