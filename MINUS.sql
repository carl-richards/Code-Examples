--The MINUS query returns all rows in the first query that are not returned in the second query.

--Each SQL statement within the MINUS query must have the same number of fields in the result sets with similar data types.

--The syntax for an MINUS query is:

    select field1, field2, . field_n
    from tables
    MINUS
    select field1, field2, . field_n
    from tables;


--Example #1

--The following is an example of an MINUS query:

    select supplier_id
    from suppliers
    MINUS
    select supplier_id
    from orders;

--In this example, the SQL would return all supplier_id values that are in the suppliers table and not in the orders table. What this means is that if a supplier_id value existed in the suppliers table and also existed in the orders table, the supplier_id value would not appear in this result set.

--Example #2 - With ORDER BY Clause

--The following is an MINUS query that uses an ORDER BY clause:

    select supplier_id, supplier_name
    from suppliers
    where supplier_id > 2000
    MINUS
    select company_id, company_name
    from companies
    where company_id > 1000
    ORDER BY 2;

--Since the column names are different between the two "select" statements, it is more advantageous to reference the columns in the ORDER BY clause by their position in the result set. In this example, we've sorted the results by supplier_name / company_name in ascending order, as denoted by the "ORDER BY 2".

--The supplier_name / company_name fields are in position #2 in the result set.