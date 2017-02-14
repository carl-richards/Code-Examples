--
-- To see the sum salary deptwise you can give the following query ...
--
SELECT SUM(sal) 
  FROM emp 
 GROUP
    BY deptno
/



-- Now to see the average total salary deptwise you can give a sub query in FROM clause ...
--
SELECT AVG(depttotal)
  FROM (SELECT SUM(sal) AS depttotal FROM emp GROUP BY deptno)
  /



-- The above average total salary department wise can also be achieved in 9i using WITH clause given below ...
--
WITH deptot 
AS 
  (SELECT SUM(sal) AS dsal FROM emp GROUP BY deptno)
SELECT AVG(dsal) 
  FROM deptot
/
  
  

