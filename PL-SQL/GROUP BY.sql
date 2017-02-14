--The GROUP BY clause can be used in a SELECT statement to collect data across multiple records and group the results by one or more columns.

--The syntax for the GROUP BY clause is:

    SELECT column1, column2, ... column_n, aggregate_function (expression)
    FROM tables
    WHERE predicates
    GROUP BY column1, column2, ... column_n;

--aggregate_function can be a function such as SUM, COUNT, MIN, or MAX.

--Example using the SUM function

--For example, you could also use the SUM function to return the name of the department and the total sales (in the associated department).

    SELECT department, SUM(sales) as "Total sales"
    FROM order_details
    GROUP BY department;

--Because you have listed one column in your SELECT statement that is not encapsulated in the SUM function, you must use a GROUP BY clause. The department field must, therefore, be listed in the GROUP BY section.

--Example using the COUNT function

--For example, you could use the COUNT function to return the name of the department and the number of employees (in the associated department) that make over $25,000 / year.

    SELECT department, COUNT(*) as "Number of employees"
    FROM employees
    WHERE salary > 25000
    GROUP BY department;


--Example using the MIN function

--For example, you could also use the MIN function to return the name of each department and the minimum salary in the department.

    SELECT department, MIN(salary) as "Lowest salary"
    FROM employees
    GROUP BY department;


--Example using the MAX function

--For example, you could also use the MAX function to return the name of each department and the maximum salary in the department.

    SELECT department, MAX(salary) as "Highest salary"
    FROM employees
    GROUP BY department;
