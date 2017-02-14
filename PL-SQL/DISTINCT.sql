--The DISTINCT clause allows you to remove duplicates from the result set. The DISTINCT clause can only be used with select statements.

--The syntax for the DISTINCT clause is:

    SELECT DISTINCT columns
    FROM tables
    WHERE predicates;


--Example #1

--Let's take a look at a very simple example.

    SELECT DISTINCT city
    FROM suppliers;

--This SQL statement would return all unique cities from the suppliers table.

--Example #2

--The DISTINCT clause can be used with more than one field.

--For example:

    SELECT DISTINCT city, state
    FROM suppliers;

--This select statement would return each unique city and state combination. In this case, the distinct applies to each field listed after the DISTINCT keyword.