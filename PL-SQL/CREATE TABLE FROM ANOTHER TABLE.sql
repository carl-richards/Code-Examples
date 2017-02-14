--You can also create a table from an existing table by copying the existing table's columns.

--It is important to note that when creating a table in this way, the new table will be populated with the records from the existing table (based on the SELECT Statement).

--Syntax #1 - Copying all columns from another table

--The basic syntax is:

    CREATE TABLE new_table
      AS (SELECT * FROM old_table);


--For example:

    CREATE TABLE suppliers
      AS (SELECT *
             FROM companies
             WHERE id > 1000);

--This would create a new table called suppliers that included all columns from the companies table.

--If there were records in the companies table, then the new suppliers table would also contain the records selected by the SELECT statement.

--Syntax #2 - Copying selected columns from another table

--The basic syntax is:

    CREATE TABLE new_table
      AS (SELECT column_1, column2, ... column_n FROM old_table);


--For example:

    CREATE TABLE suppliers
      AS (SELECT id, address, city, state, zip
              FROM companies
              WHERE id > 1000);

--This would create a new table called suppliers, but the new table would only include the specified columns from the companies table.

--Again, if there were records in the companies table, then the new suppliers table would also contain the records selected by the SELECT statement.

--Syntax #3 - Copying selected columns from multiple tables

--The basic syntax is:

    CREATE TABLE new_table
      AS (SELECT column_1, column2, ... column_n
              FROM old_table_1, old_table_2, ... old_table_n);


--For example:

    CREATE TABLE suppliers
      AS (SELECT companies.id, companies.address, categories.cat_type
              FROM companies, categories
              WHERE companies.id = categories.id
              AND companies.id > 1000);

--This would create a new table called suppliers based on columns from both the companies and categories tables.