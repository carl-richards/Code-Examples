--Oracle/PLSQL: Rank Function

--------------------------------------------------------------------------------

--In Oracle/PLSQL, the rank function returns the rank of a value in a group of values. It is very similar to the dense_rank function. However, the rank function can cause non-consecutive rankings if the tested values are the same. Whereas, the dense_rank function will always result in consecutive rankings.

--The rank function can be used two ways - as an Aggregate function or as an Analytic function.

--Syntax #1 - Used as an Aggregate Function
--As an Aggregate function, the rank returns the rank of a row within a group of rows.

--The syntax for the rank function when used as an Aggregate function is:

rank( expression1, ... expression_n ) WITHIN GROUP ( ORDER BY expression1, ... expression_n )

--expression1 .. expression_n can be one or more expressions which identify a unique row in the group.

--Note:
--There must be the same number of expressions in the first expression list as there is in the ORDER BY clause.

--The expression lists match by position so the data types must be compatible between the expressions in the first expression list as in the ORDER BY clause.

--Applies To:
--•Oracle 9i, Oracle 10g, Oracle 11g
--For Example:
select rank(1000, 500) WITHIN GROUP (ORDER BY salary, bonus)
from employees;

--The SQL statement above would return the rank of an employee with a salary of $1,000 and a bonus of $500 from within the employees table.

--Syntax #2 - Used as an Analytic Function
--As an Analytic function, the rank returns the rank of each row of a query with respective to the other rows.

--The syntax for the rank function when used as an Analytic function is:

rank() OVER ( [ query_partition_clause] ORDER BY clause )

--Applies To:
--•Oracle 8i, Oracle 9i, Oracle 10g, Oracle 11g
For Example:
select employee_name, salary, 
rank() OVER (PARTITION BY department ORDER BY salary)
from employees
where department = 'Marketing';

--The SQL statement above would return all employees who work in the Marketing department and then calculate a rank for each unique salary in the Marketing department. If two employees had the same salary, the rank function would return the same rank for both employees. However, this will cause a gap in the ranks (ie: non-consecutive ranks). This is quite different from the dense_rank function which generates consecutive rankings.

 --Here's an example from Pulse 
 
 --In this case I Want to Rank the order of the dependants on a policy by their ages desc 
 --Policy number is the group by item where as the Age function is the rank and ordering item. 
 
 RANK() OVER (PARTITION BY cpm.strpolnbr  ORDER BY com_util_pkg.calc_client_age_fnc(cppd.strclientcd) DESC) row_num
 
         SELECT age, row_num, strpolnbr
          FROM   (SELECT com_util_pkg.calc_client_age_fnc(cppd.strclientcd) age, RANK() OVER (PARTITION BY cpm.strpolnbr  ORDER BY com_util_pkg.calc_client_age_fnc(cppd.strclientcd) DESC) row_num, cpm.strpolnbr
                  FROM   com_pol_prod_dtl cppd, com_policy_m cpm
                  WHERE  cppd.strpolnbr = cpm.strpolnbr
                    AND cppd.nprodstatcd = 1
                    AND cpm.strpolnbr = '10752578'
                    AND nsaccd = 3
                  ORDER BY com_util_pkg.calc_client_age_fnc(cppd.strclientcd) DESC);