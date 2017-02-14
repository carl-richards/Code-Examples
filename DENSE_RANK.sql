--Oracle/PLSQL: Dense_Rank Function

--------------------------------------------------------------------------------

--In Oracle/PLSQL, the dense_rank function returns the rank of a row in a group of rows. It is very similar to the rank function. However, the rank function can cause non-consecutive rankings if the tested values are the same. Whereas, the dense_rank function will always result in consecutive rankings.

--The dense_rank function can be used two ways - as an Aggregate function or as an Analytic function.

--Syntax #1 - Used as an Aggregate Function
--As an Aggregate function, the dense_rank returns the dense rank of a row within a group of rows.

--The syntax for the dense_rank function when used as an Aggregate function is:

dense_rank( expression1, ... expression_n ) WITHIN GROUP ( ORDER BY expression1, ... expression_n )

--expression1 .. expression_n can be one or more expressions which identify a unique row in the group.

--Note:
--There must be the same number of expressions in the first expression list as there is in the ORDER BY clause.

--The expression lists match by position so the data types must be compatible between the expressions in the first expression list as in the ORDER BY clause.

--Applies To:
--•Oracle 9i, Oracle 10g, Oracle 11g
--For Example:
select dense_rank(1000, 500) WITHIN GROUP (ORDER BY salary, bonus)
from employees;

--The SQL statement above would return the dense rank of an employee with a salary of $1,000 and a bonus of $500 from within the employees table.

--Syntax #2 - Used as an Analytic Function
--As an Analytic function, the dense_rank returns the rank of each row of a query with respective to the other rows.

--The syntax for the dense_rank function when used as an Analytic function is:

dense_rank() OVER ( [ query_partition_clause] ORDER BY clause )

--Applies To:
--•Oracle 8i, Oracle 9i, Oracle 10g, Oracle 11g
--For Example:
select employee_name, salary, 
dense_rank() OVER (PARTITION BY department ORDER BY salary)
from employees
where department = 'Marketing';

--The SQL statement above would return all employees who work in the Marketing department and then calculate a rank for each unique salary in the Marketing department. If two employees had the same salary, the dense_rank function would return the same rank for both employees.

