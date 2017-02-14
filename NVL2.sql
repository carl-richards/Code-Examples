--The syntax for the NVL2 function is:

--    NVL2( string1, value_if_NOT_null, value_if_null )

--string1 is the string to test for a null value.

--value_if_NOT_null is the value returned if string1 is not null.

--value_if_null is the value returned if string1 is null.



--Example #1:

    select NVL2(supplier_city, 'Completed', 'n/a')
    from suppliers;

--The SQL statement above would return 'n/a' if the supplier_city field contained a null value. Otherwise, it would return the 'Completed'.

--Example #2:

    select supplier_id,
    NVL2(supplier_desc, supplier_name, supplier_name2)
    from suppliers;

--This SQL statement would return the supplier_name2 field if the supplier_desc contained a null value. Otherwise, it would return the supplier_name field.