--The HAVING clause is used in combination with the GROUP BY clause. It can be used in a SELECT statement to filter the records that a GROUP BY returns.

--The syntax for the HAVING clause is:

    SELECT column1, column2, ... column_n, aggregate_function (expression)
    FROM tables
    WHERE predicates
    GROUP BY column1, column2, ... column_n
    HAVING condition1 ... condition_n;

--aggregate_function can be a function such as SUM, COUNT, MIN, or MAX.

--Example using the SUM function

--For example, you could also use the SUM function to return the name of the department and the total sales (in the associated department). The HAVING clause will filter the results so that only departments with sales greater than $1000 will be returned.

    SELECT department, SUM(sales) as "Total sales"
    FROM order_details
    GROUP BY department
    HAVING SUM(sales) > 1000;


--Example using the COUNT function

--For example, you could use the COUNT function to return the name of the department and the number of employees (in the associated department) that make over $25,000 / year. The HAVING clause will filter the results so that only departments with more than 10 employees will be returned.

    SELECT department, COUNT(*) as "Number of employees"
    FROM employees
    WHERE salary > 25000
    GROUP BY department
    HAVING COUNT(*) > 10;


--Example using the MIN function

--For example, you could also use the MIN function to return the name of each department and the minimum salary in the department. The HAVING clause will return only those departments where the starting salary is $35,000.

    SELECT department, MIN(salary) as "Lowest salary"
    FROM employees
    GROUP BY department
    HAVING MIN(salary) = 35000;


--Example using the MAX function

--For example, you could also use the MAX function to return the name of each department and the maximum salary in the department. The HAVING clause will return only those departments whose maximum salary is less than $50,000.

    SELECT department, MAX(salary) as "Highest salary"
    FROM employees
    GROUP BY department
    HAVING MAX(salary) < 50000;
