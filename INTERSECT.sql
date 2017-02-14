--The INTERSECT query allows you to return the results of 2 or more "select" queries. However, it only returns the rows selected by all queries. If a record exists in one query and not in the other, it will be omitted from the INTERSECT results.

--Each SQL statement within the INTERSECT query must have the same number of fields in the result sets with similar data types.

--The syntax for an INTERSECT query is:

    select field1, field2, . field_n
    from tables
    INTERSECT
    select field1, field2, . field_n
    from tables;


--Example #1

--The following is an example of an INTERSECT query:

    select supplier_id
    from suppliers
    INTERSECT
    select supplier_id
    from orders;

--In this example, if a supplier_id appeared in both the suppliers and orders table, it would appear in your result set.

--Example #2 - With ORDER BY Clause

--The following is an INTERSECT query that uses an ORDER BY clause:

    select supplier_id, supplier_name
    from suppliers
    where supplier_id > 2000
    INTERSECT
    select company_id, company_name
    from companies
    where company_id > 1000
    ORDER BY 2;

--Since the column names are different between the two "select" statements, it is more advantageous to reference the columns in the ORDER BY clause by their position in the result set. In this example, we've sorted the results by supplier_name / company_name in ascending order, as denoted by the "ORDER BY 2".

--The supplier_name / company_name fields are in position #2 in the result set.