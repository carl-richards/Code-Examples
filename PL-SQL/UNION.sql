--The UNION query allows you to combine the result sets of 2 or more "select" queries. It removes duplicate rows between the various "select" statements.

--Each SQL statement within the UNION query must have the same number of fields in the result sets with similar data types.

--The syntax for a UNION query is:

    select field1, field2, . field_n
    from tables
    UNION
    select field1, field2, . field_n
    from tables;


--Example #1

--The following is an example of a UNION query:

    select supplier_id
    from suppliers
    UNION
    select supplier_id
    from orders;

--In this example, if a supplier_id appeared in both the suppliers and orders table, it would appear once in your result set. The UNION removes duplicates.

--Example #2 - With ORDER BY Clause

--The following is a UNION query that uses an ORDER BY clause:

    select supplier_id, supplier_name
    from suppliers
    where supplier_id > 2000
    UNION
    select company_id, company_name
    from companies
    where company_id > 1000
    ORDER BY 2;

--Since the column names are different between the two "select" statements, it is more advantageous to reference the columns in the ORDER BY clause by their position in the result set. In this example, we've sorted the results by supplier_name / company_name in ascending order, as denoted by the "ORDER BY 2".

--The supplier_name / company_name fields are in position #2 in the result set.