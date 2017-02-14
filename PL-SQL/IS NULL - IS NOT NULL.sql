--In PLSQL to check if a value is null, you must use the "IS NULL" syntax.

--For example,

    IF Lvalue IS NULL then

        ...

    END IF;

--If Lvalue contains a null value, the "IF" expression will evaluate to TRUE.

--You can also use "IS NULL" in an SQL statement. For example:

    select * from suppliers
    where supplier_name IS NULL;

--This will return all records from the suppliers table where the supplier_name contains a null value.



--In PLSQL to check if a value is not null, you must use the "IS NOT NULL" syntax.

--For example,

    IF Lvalue IS NOT NULL then

        ...

    END IF;

--If Lvalue does not contain a null value, the "IF" expression will evaluate to TRUE.

--You can also use "IS NOT NULL" in an SQL statement. For example:

    select * from suppliers
    where supplier_name IS NOT NULL;

--This will return all records from the suppliers table where the supplier_name does not contain a null value.