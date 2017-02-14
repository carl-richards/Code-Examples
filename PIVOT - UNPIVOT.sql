/*
pivot and unpivot queries in 11g

Pivot queries involve transposing rows into columns (pivot) or columns into rows (unpivot) to generate results in crosstab format. Pivoting is a common technique, especially for reporting, and it has been possible to generate pivoted resultsets with SQL for many years and Oracle versions. However, the release of 11g includes explicit pivot-query support for the first time with the introduction of the new PIVOT and UNPIVOT keywords. These are extensions to the SELECT statement and we will explore the syntax and application of these new features in this article.

pivot

We will begin with the new PIVOT operation. Most developers will be familiar with pivoting data: it is where multiple rows are aggregated and transposed into columns, with each column representing a different range of aggregate data. An overview of the new syntax is as follows:

SELECT ...
FROM   ...
PIVOT [XML]
   ( pivot_clause
     pivot_for_clause
     pivot_in_clause )
WHERE  ...
In addition to the new PIVOT keyword, we can see three new pivot clauses, described below.

pivot_clause: defines the columns to be aggregated (pivot is an aggregate operation);
pivot_for_clause: defines the columns to be grouped and pivoted;
pivot_in_clause: defines the filter for the column(s) in the pivot_for_clause (i.e. the range of values to limit the results to). The aggregations for each value in the pivot_in_clause will be transposed into a separate column (where appropriate).
The syntax and mechanics of pivot queries will become clearer with some examples.

a simple example

Our first example will be a simple demonstration of the PIVOT syntax. Using the EMP table, we will sum the salaries by department and job, but transpose the sum for each department onto its own column. Before we pivot the salaries, we will examine the base data, as follows.

SQL> SELECT job
  2  ,      deptno
  3  ,      SUM(sal) AS sum_sal
  4  FROM   emp
  5  GROUP  BY
  6         job
  7  ,      deptno
  8  ORDER  BY
  9         job
 10  ,      deptno;

JOB           DEPTNO    SUM_SAL
--------- ---------- ----------
ANALYST           20       6600
CLERK             10       1430
CLERK             20       2090
CLERK             30       1045
MANAGER           10       2695
MANAGER           20     3272.5
MANAGER           30       3135
PRESIDENT         10       5500
SALESMAN          30       6160

9 rows selected.
We will now pivot this data using the new 11g syntax. For each job, we will display the salary totals in a separate column for each department, as follows.

SQL> WITH pivot_data AS (
  2          SELECT deptno, job, sal
  3          FROM   emp
  4          )
  5  SELECT *
  6  FROM   pivot_data
  7  PIVOT (
  8             SUM(sal)        --<-- pivot_clause
  9         FOR deptno          --<-- pivot_for_clause
 10         IN  (10,20,30, )   --<-- pivot_in_clause
 11        );

JOB               10         20         30         40
--------- ---------- ---------- ---------- ----------
CLERK           1430       2090       1045
SALESMAN                              6160
PRESIDENT       5500
MANAGER         2695     3272.5       3135
ANALYST                    6600

5 rows selected.
We can see that the department salary totals for each job have been transposed into columns. There are a few points to note about this example, the syntax and the results:

Line 8: our pivot_clause sums the SAL column. We can specify multiple columns if required and optionally alias them (we will see examples of aliasing later in this article);
Lines 1-4: pivot operations perform an implicit GROUP BY using any columns not in the pivot_clause (in our example, JOB and DEPTNO). For this reason, most pivot queries will be performed on a subset of columns, using stored views, inline views or subqueries, as in our example;
Line 9: our pivot_for_clause states that we wish to pivot the DEPTNO aggregations only;
Line 10: our pivot_in_clause specifies the range of values for DEPTNO. In this example we have hard-coded a list of four values which is why we generated four pivoted columns (one for each value of DEPTNO). In the absence of aliases, Oracle uses the values in the pivot_in_clause to generate the pivot column names (in our output we can see columns named "10", "20", "30" and "40").
It was stated above that most pivot queries will be performed on a specific subset of columns. Like all aggregate queries, the presence of additional columns affects the groupings. We can see this quite simply with a pivot query over additional EMP columns as follows.

SQL> SELECT *
  2  FROM   emp
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10,20,30,40));
     EMPNO ENAME      JOB              MGR HIREDATE         COMM         10         20         30         40
---------- ---------- --------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      7654 MARTIN     SALESMAN        7698 28/09/1981       1400                             1375
      7698 BLAKE      MANAGER         7839 01/05/1981                                        3135
      7934 MILLER     CLERK           7782 23/01/1982                  1430
      7521 WARD       SALESMAN        7698 22/02/1981        500                             1375
      7566 JONES      MANAGER         7839 02/04/1981                           3272.5
      7844 TURNER     SALESMAN        7698 08/09/1981          0                             1650
      7900 JAMES      CLERK           7698 03/12/1981                                        1045
      7839 KING       PRESIDENT            17/11/1981                  5500
      7876 ADAMS      CLERK           7788 23/05/1987                             1210
      7902 FORD       ANALYST         7566 03/12/1981                             3300
      7788 SCOTT      ANALYST         7566 19/04/1987                             3300
      7782 CLARK      MANAGER         7839 09/06/1981                  2695
      7369 SMITH      CLERK           7902 17/12/1980                              880
      7499 ALLEN      SALESMAN        7698 20/02/1981        300                             1760

14 rows selected.
In this case, all the EMP columns apart from SAL have become the grouping set, with DEPTNO being the pivot column. The pivot is effectively useless in this case.

An interesting point about the pivot syntax is its placement in the query; namely, between the FROM and WHERE clauses. In the following example, we restrict our original pivot query to a selection of job titles by adding a predicate.

SQL> WITH pivot_data AS (
  2          SELECT deptno, job, sal
  3          FROM   emp
  4          )
  5  SELECT *
  6  FROM   pivot_data
  7  PIVOT (
  8             SUM(sal)        --<-- pivot_clause
  9         FOR deptno          --<-- pivot_for_clause
 10         IN  (10,20,30,40)   --<-- pivot_in_clause
 11        )
 12  WHERE  job IN ('ANALYST','CLERK','SALESMAN');

JOB                10         20         30         40
---------- ---------- ---------- ---------- ----------
CLERK            1430       2090       1045
SALESMAN                               6160
ANALYST                     6600

3 rows selected.
This appears to be counter-intuitive, but adding the predicates before the pivot clause raises a syntax error. As an aside, in our first example we used subquery factoring (the WITH clause) to define the base column set. We can alternatively use an inline-view (as follows) or a stored view (we will do this later).

SQL> SELECT *
  2  FROM  (
  3         SELECT deptno, job, sal
  4         FROM   emp
  5        )
  6  PIVOT (SUM(sal)
  7  FOR    deptno IN (10,20,30,40));

JOB               10         20         30         40
--------- ---------- ---------- ---------- ----------
CLERK           1430       2090       1045
SALESMAN                              6160
PRESIDENT       5500
MANAGER         2695     3272.5       3135
ANALYST                    6600

5 rows selected.
aliasing pivot columns

In our preceding examples, Oracle used the values of DEPTNO to generate pivot column names. Alternatively, we can alias one or more of the columns in the pivot_clause and one or more of the values in the pivot_in_clause. In general, Oracle will name the pivot columns according to the following conventions:

Pivot Column Aliased?    Pivot In-Value Aliased?    Pivot Column Name
N    N    pivot_in_clause value
Y    Y    pivot_in_clause alias || '_' || pivot_clause alias
N    Y    pivot_in_clause alias
Y    N    pivot_in_clause value || '_' || pivot_clause alias
We will see examples of each of these aliasing options below (we have already seen examples without any aliases). However, to simplify our examples, we will begin by defining the input dataset as a view, as follows.

SQL> CREATE VIEW pivot_data
  2  AS
  3     SELECT deptno, job, sal
  4     FROM   emp;

View created.
For our first example, we will alias all elements of our pivot query.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal) AS salaries
  4  FOR    deptno IN (10 AS d10_sal,
  5                    20 AS d20_sal,
  6                    30 AS d30_sal,
  7                    40 AS d40_sal));

JOB        D10_SAL_SALARIES D20_SAL_SALARIES D30_SAL_SALARIES D40_SAL_SALARIES
---------- ---------------- ---------------- ---------------- ----------------
CLERK                  1430             2090             1045
SALESMAN                                                 6160
PRESIDENT              5500
MANAGER                2695           3272.5             3135
ANALYST                                 6600

5 rows selected.
Oracle concatenates our aliases together to generate the column names. In the following example, we will alias the pivot_clause (aggregated column) but not the values in the pivot_in_clause.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal) AS salaries
  4  FOR    deptno IN (10, 20, 30, 40));

JOB       10_SALARIES 20_SALARIES 30_SALARIES 40_SALARIES
--------- ----------- ----------- ----------- -----------
CLERK            1430        2090        1045
SALESMAN                                 6160
PRESIDENT        5500
MANAGER          2695      3272.5        3135
ANALYST                      6600

5 rows selected.
Oracle generates the pivot column names by concatenating the pivot_in_clause values and the aggregate column alias. Finally, we will only alias the pivot_in_clause values, as follows.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10 AS d10_sal,
  5                    20 AS d20_sal,
  6                    30 AS d30_sal,
  7                    40 AS d40_sal));

JOB           D10_SAL    D20_SAL    D30_SAL    D40_SAL
---------- ---------- ---------- ---------- ----------
CLERK            1430       2090       1045
SALESMAN                               6160
PRESIDENT        5500
MANAGER          2695     3272.5       3135
ANALYST                     6600

5 rows selected.
This time, Oracle generated column names from the aliases only. In fact, we can see from all of our examples that the pivot_in_clause is used in all pivot-column naming, regardless of whether we supply an alias or value. We can therefore be selective about which values we alias, as the following example demonstrates.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10 AS d10_sal,
  5                    20,
  6                    30 AS d30_sal,
  7                    40));

JOB          D10_SAL         20    D30_SAL         40
--------- ---------- ---------- ---------- ----------
CLERK           1430       2090       1045
SALESMAN                              6160
PRESIDENT       5500
MANAGER         2695     3272.5       3135
ANALYST                    6600

5 rows selected.
pivoting multiple columns

Our examples so far have contained a single aggregate and a single pivot column, although we can define more if we wish. In the following example we will define two aggregations in our pivot_clause for the same range of DEPTNO values that we have used so far. The new aggregate is a count of the salaries that comprise the sum.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)   AS sum
  4  ,      COUNT(sal) AS cnt
  5  FOR    deptno IN (10 AS d10_sal,
  6                    20 AS d20_sal,
  7                    30 AS d30_sal,
  8                    40 AS d40_sal));
JOB        D10_SAL_SUM D10_SAL_CNT D20_SAL_SUM D20_SAL_CNT D30_SAL_SUM D30_SAL_CNT D40_SAL_SUM D40_SAL_CNT
---------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -----------
CLERK             1430           1        2090           2        1045           1                       0
SALESMAN                         0                       0        6160           4                       0
PRESIDENT         5500           1                       0                       0                       0
MANAGER           2695           1      3272.5           1        3135           1                       0
ANALYST                          0        6600           2                       0                       0

5 rows selected.
We have doubled the number of pivot columns (because we doubled the number of aggregates). The number of pivot columns is a product of the number of aggregates and the distinct number of values in the pivot_in_clause. In the following example, we will extend the pivot_for_clause and pivot_in_clause to include values for JOB in the filter.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)   AS sum
  4  ,      COUNT(sal) AS cnt
  5  FOR   (deptno,job) IN ((30, 'SALESMAN') AS d30_sls,
  6                         (30, 'MANAGER')  AS d30_mgr,
  7                         (30, 'CLERK')    AS d30_clk));

D30_SLS_SUM D30_SLS_CNT D30_MGR_SUM D30_MGR_CNT D30_CLK_SUM D30_CLK_CNT
----------- ----------- ----------- ----------- ----------- -----------
       6160           4        3135           1        1045           1

1 row selected.
We have limited the query to just 3 jobs within department 30. Note how the pivot_for_clause columns (DEPTNO and JOB) combine to make a single pivot dimension. The aliases we use apply to the combined value domain (for example, "D30_SLS" to represent SALES in department 30).

Finally, because we know the pivot column-naming rules, we can reference them directly, as follows.

SQL> SELECT d30_mgr_sum
  2  ,      d30_clk_cnt
  3  FROM   pivot_data
  4  PIVOT (SUM(sal)   AS sum
  5  ,      COUNT(sal) AS cnt
  6  FOR   (deptno,job) IN ((30, 'SALESMAN') AS d30_sls,
  7                         (30, 'MANAGER')  AS d30_mgr,
  8                         (30, 'CLERK')    AS d30_clk));

D30_MGR_SUM D30_CLK_CNT
----------- -----------
       3135           1

1 row selected.
general restrictions

There are a few simple "gotchas" to be aware of with pivot queries. For example, we cannot project the column(s) used in the pivot_for_clause (DEPTNO in most of our examples). This is to be expected. The column(s) in the pivot_for_clause are grouped according to the range of values we supply with the pivot_in_clause. In the following example, we will attempt to project the DEPTNO column.

SQL> SELECT deptno
  2  FROM   emp
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10,20,30,40));
SELECT deptno
       *
ERROR at line 1:
ORA-00904: "DEPTNO": invalid identifier
Oracle raises an ORA-00904 exception. In this case the DEPTNO column is completely removed from the projection and Oracle tells us that it doesn't exist in this scope. Similarly, we cannot include any column(s) used in the pivot_clause, as the following example demonstrates.

SQL> SELECT sal
  2  FROM   emp
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10,20,30,40));
SELECT sal
       *
ERROR at line 1:
ORA-00904: "SAL": invalid identifier
We attempted to project the SAL column but Oracle raised the same exception. This is also to be expected: the pivot_clause defines our aggregations. This also means, of course, that we must use aggregate functions in the pivot_clause. In the following example, we will attempt to define a pivot_clause with a single-group column.

SQL> SELECT *
  2  FROM   emp
  3  PIVOT (sal
  4  FOR    deptno IN (10,20,30,40));
PIVOT (sal AS salaries
       *
ERROR at line 3:
ORA-56902: expect aggregate function inside pivot operation
Oracle raises a new ORA-56902 exception: the error message numbers are getting much higher with every release!

execution plans for pivot operations

As we have stated, pivot operations imply a GROUP BY, but we don't need to specify it. We can investigate this by explaining one of our pivot query examples, as follows. We will use Autotrace for convenience (Autotrace uses EXPLAIN PLAN and DBMS_XPLAN to display theoretical execution plans).

SQL> set autotrace traceonly explain

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)
  4  FOR    deptno IN (10 AS d10_sal,
  5                    20 AS d20_sal,
  6                    30 AS d30_sal,
  7                    40 AS d40_sal));

Execution Plan
----------------------------------------------------------
Plan hash value: 1475541029

----------------------------------------------------------------------------
| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |     5 |    75 |     4  (25)| 00:00:01 |
|   1 |  HASH GROUP BY PIVOT|      |     5 |    75 |     4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL | EMP  |    14 |   210 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------
The plan output tells us that this query uses a HASH GROUP BY PIVOT operation. The HASH GROUP BY is a feature of 10g Release 2, but the PIVOT extension is new to 11g. Pivot queries do not automatically generate a PIVOT plan, however. In the following example, we will limit the domain of values in our pivot_in_clause and use Autotrace to explain the query again.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT (SUM(sal)   AS sum
  4  ,      COUNT(sal) AS cnt
  5  FOR   (deptno,job) IN ((30, 'SALESMAN') AS d30_sls,
  6                         (30, 'MANAGER')  AS d30_mgr,
  7                         (30, 'CLERK')    AS d30_clk));

Execution Plan
----------------------------------------------------------
Plan hash value: 1190005124

----------------------------------------------------------------------------
| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |     1 |    78 |     3   (0)| 00:00:01 |
|   1 |  VIEW               |      |     1 |    78 |     3   (0)| 00:00:01 |
|   2 |   SORT AGGREGATE    |      |     1 |    15 |            |          |
|   3 |    TABLE ACCESS FULL| EMP  |    14 |   210 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------
This time the CBO has costed a simple aggregation over a group by with pivot. It has correctly identified that only one record will be returned from this query, so the GROUP BY operation is unnecessary. Finally, we will explain our first pivot example but use the extended formatting options of DBMS_XPLAN to reveal more information about the work that Oracle is doing.

SQL> EXPLAIN PLAN SET STATEMENT_ID = 'PIVOT'
  2  FOR
  3     SELECT *
  4     FROM   pivot_data
  5     PIVOT (SUM(sal)
  6     FOR    deptno IN (10 AS d10_sal,
  7                       20 AS d20_sal,
  8                       30 AS d30_sal,
  9                       40 AS d40_sal));

Explained.

SQL> SELECT *
  2  FROM   TABLE(
  3            DBMS_XPLAN.DISPLAY(
  4               NULL, 'PIVOT', 'TYPICAL +PROJECTION'));

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------
Plan hash value: 1475541029

----------------------------------------------------------------------------
| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |     5 |    75 |     4  (25)| 00:00:01 |
|   1 |  HASH GROUP BY PIVOT|      |     5 |    75 |     4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL | EMP  |    14 |   210 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "JOB"[VARCHAR2,9], SUM(CASE  WHEN ("DEPTNO"=10) THEN
       "SAL" END )[22], SUM(CASE  WHEN ("DEPTNO"=20) THEN "SAL" END )[22],
       SUM(CASE  WHEN ("DEPTNO"=30) THEN "SAL" END )[22], SUM(CASE  WHEN
       ("DEPTNO"=40) THEN "SAL" END )[22]
   2 - "JOB"[VARCHAR2,9], "SAL"[NUMBER,22], "DEPTNO"[NUMBER,22]

18 rows selected.
DBMS_XPLAN optionally exposes the column projection information contained in PLAN_TABLE for each step of a query. The projection for ID=2 shows the base columns that we select in the PIVOT_DATA view over EMP. The interesting information, however, is for ID=1 (this step is our pivot operation). This clearly shows how Oracle is generating the pivot columns. Many developers will be familiar with this form of SQL: it is how we write pivot queries in versions prior to 11g. Oracle has chosen a CASE expression, but we commonly use DECODE for brevity, as follows.

SQL> SELECT job
  2  ,      SUM(DECODE(deptno,10,sal)) AS "D10_SAL"
  3  ,      SUM(DECODE(deptno,20,sal)) AS "D20_SAL"
  4  ,      SUM(DECODE(deptno,30,sal)) AS "D30_SAL"
  5  ,      SUM(DECODE(deptno,40,sal)) AS "D40_SAL"
  6  FROM   emp
  7  GROUP  BY
  8         job;

JOB          D10_SAL    D20_SAL    D30_SAL    D40_SAL
--------- ---------- ---------- ---------- ----------
CLERK           1430       2090       1045
SALESMAN                              6160
PRESIDENT       5500
MANAGER         2695     3272.5       3135
ANALYST                    6600

5 rows selected.
pivot performance

From the evidence we have seen, it appears as though Oracle implements the new PIVOT syntax using a recognised SQL format. It follows that we should expect the same performance for our pivot queries regardless of the technique we use (in other words the 11g PIVOT syntax will perform the same as the SUM(DECODE...) pivot technique. We will test this proposition with a larger dataset using Autotrace (for general I/O patterns) and the wall-clock (for elapsed time). First we will create a table with one million rows, as follows.

SQL> CREATE TABLE million_rows
  2  NOLOGGING
  3  AS
  4     SELECT MOD(TRUNC(DBMS_RANDOM.VALUE(1,10000)),4) AS pivoting_col
  5     ,      MOD(ROWNUM,4)+10                         AS grouping_col
  6     ,      DBMS_RANDOM.VALUE                        AS summing_col
  7     ,      RPAD('X',70,'X')                         AS padding_col
  8     FROM   dual
  9     CONNECT BY ROWNUM <= 1000000;

Table created.
We will now compare the two pivot query techniques (after full-scanning the MILLION_ROWS table a couple of times). We will begin with the new 11g syntax, as follows.

SQL> set timing on

SQL> set autotrace on

SQL> WITH pivot_data AS (
  2          SELECT pivoting_col
  3          ,      grouping_col
  4          ,      summing_col
  5          FROM   million_rows
  6          )
  7  SELECT *
  8  FROM   pivot_data
  9  PIVOT (SUM(summing_col) AS sum
 10  FOR    pivoting_col IN (0,1,2,3))
 11  ORDER  BY
 12         grouping_col;

GROUPING_COL      0_SUM      1_SUM      2_SUM      3_SUM
------------ ---------- ---------- ---------- ----------
          10 31427.0128 31039.5026 31082.0382 31459.7873
          11 31385.2582 31253.2246 31030.7518 31402.1794
          12 31353.1321  31220.078 31174.0103 31140.5322
          13 31171.1977  30979.714 31486.7785 31395.6907

4 rows selected.

Elapsed: 00:00:04.50

Execution Plan
----------------------------------------------------------
Plan hash value: 1201564532

------------------------------------------------------------------------------------
| Id  | Operation           | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |              |  1155K|    42M|  3978   (2)| 00:00:48 |
|   1 |  SORT GROUP BY PIVOT|              |  1155K|    42M|  3978   (2)| 00:00:48 |
|   2 |   TABLE ACCESS FULL | MILLION_ROWS |  1155K|    42M|  3930   (1)| 00:00:48 |
------------------------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement


Statistics
----------------------------------------------------------
        170  recursive calls
          0  db block gets
      14393  consistent gets
      14286  physical reads
          0  redo size
       1049  bytes sent via SQL*Net to client
        416  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          6  sorts (memory)
          0  sorts (disk)
          4  rows processed
The most important outputs are highlighted. We can see that the query completed in 4.5 seconds and generated approximately 14,000 PIOs and LIOs. Interestingly, the CBO chose a SORT GROUP BY over a HASH GROUP BY for this volume, having estimated almost 1.2 million records.

By way of comparison, we will run the pre-11g version of pivot, as follows.

SQL> SELECT grouping_col
  2  ,      SUM(DECODE(pivoting_col,0,summing_col)) AS "0_SUM"
  3  ,      SUM(DECODE(pivoting_col,1,summing_col)) AS "1_SUM"
  4  ,      SUM(DECODE(pivoting_col,2,summing_col)) AS "2_SUM"
  5  ,      SUM(DECODE(pivoting_col,3,summing_col)) AS "3_SUM"
  6  FROM   million_rows
  7  GROUP  BY
  8         grouping_col
  9  ORDER  BY
 10         grouping_col;

GROUPING_COL      0_SUM      1_SUM      2_SUM      3_SUM
------------ ---------- ---------- ---------- ----------
          10 31427.0128 31039.5026 31082.0382 31459.7873
          11 31385.2582 31253.2246 31030.7518 31402.1794
          12 31353.1321  31220.078 31174.0103 31140.5322
          13 31171.1977  30979.714 31486.7785 31395.6907

4 rows selected.

Elapsed: 00:00:04.37

Execution Plan
----------------------------------------------------------
Plan hash value: 2855194314

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |  1155K|    42M|  3978   (2)| 00:00:48 |
|   1 |  SORT GROUP BY     |              |  1155K|    42M|  3978   (2)| 00:00:48 |
|   2 |   TABLE ACCESS FULL| MILLION_ROWS |  1155K|    42M|  3930   (1)| 00:00:48 |
-----------------------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement


Statistics
----------------------------------------------------------
          4  recursive calls
          0  db block gets
      14374  consistent gets
      14286  physical reads
          0  redo size
       1049  bytes sent via SQL*Net to client
        416  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          4  rows processed
With a couple of minor exceptions, the time and resource results for this query are the same as for the new PIVOT syntax. This is as we expected given the internal query re-write we saw earlier. In fact, the new PIVOT version of this query generated more recursive SQL and more in-memory sorts, but we can conclude from this simple test that there is no performance penalty with the new technique. We will test this conclusion with a higher number of pivot columns, as follows.

SQL> set timing on

SQL> set autotrace traceonly statistics

SQL> WITH pivot_data AS (
  2          SELECT pivoting_col
  3          ,      grouping_col
  4          ,      summing_col
  5          FROM   million_rows
  6          )
  7  SELECT *
  8  FROM   pivot_data
  9  PIVOT (SUM(summing_col)   AS sum
 10  ,      COUNT(summing_col) AS cnt
 11  ,      AVG(summing_col)   AS av
 12  ,      MIN(summing_col)   AS mn
 13  ,      MAX(summing_col)   AS mx
 14  FOR    pivoting_col IN (0,1,2,3))
 15  ORDER  BY
 16         grouping_col;

4 rows selected.

Elapsed: 00:00:04.29

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
      14290  consistent gets
      14286  physical reads
          0  redo size
       2991  bytes sent via SQL*Net to client
        416  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          4  rows processed
We have generated 20 pivot columns with this example. Note that the above output is from a third or fourth run of the example to avoid skew in the results. Ultimately, the I/O patterns and elapsed time are the same as our original example, despite pivoting an additional 16 columns. We will compare this with the SUM(DECODE...) technique, as follows.

SQL> SELECT grouping_col
  2  ,      SUM(DECODE(pivoting_col,0,summing_col))   AS "0_SUM"
  3  ,      COUNT(DECODE(pivoting_col,0,summing_col)) AS "0_CNT"
  4  ,      AVG(DECODE(pivoting_col,0,summing_col))   AS "0_AV"
  5  ,      MIN(DECODE(pivoting_col,0,summing_col))   AS "0_MN"
  6  ,      MAX(DECODE(pivoting_col,0,summing_col))   AS "0_MX"
  7         --
  8  ,      SUM(DECODE(pivoting_col,1,summing_col))   AS "1_SUM"
  9  ,      COUNT(DECODE(pivoting_col,1,summing_col)) AS "1_CNT"
 10  ,      AVG(DECODE(pivoting_col,1,summing_col))   AS "1_AV"
 11  ,      MIN(DECODE(pivoting_col,1,summing_col))   AS "1_MN"
 12  ,      MAX(DECODE(pivoting_col,1,summing_col))   AS "1_MX"
 13         --
 14  ,      SUM(DECODE(pivoting_col,2,summing_col))   AS "2_SUM"
 15  ,      COUNT(DECODE(pivoting_col,2,summing_col)) AS "2_CNT"
 16  ,      AVG(DECODE(pivoting_col,2,summing_col))   AS "2_AV"
 17  ,      MIN(DECODE(pivoting_col,2,summing_col))   AS "2_MN"
 18  ,      MAX(DECODE(pivoting_col,2,summing_col))   AS "2_MX"
 19         --
 20  ,      SUM(DECODE(pivoting_col,3,summing_col))   AS "3_SUM"
 21  ,      COUNT(DECODE(pivoting_col,3,summing_col)) AS "3_CNT"
 22  ,      AVG(DECODE(pivoting_col,3,summing_col))   AS "3_AV"
 23  ,      MIN(DECODE(pivoting_col,3,summing_col))   AS "3_MN"
 24  ,      MAX(DECODE(pivoting_col,3,summing_col))   AS "3_MX"
 25  FROM   million_rows
 26  GROUP  BY
 27         grouping_col
 28  ORDER  BY
 29         grouping_col;

4 rows selected.

Elapsed: 00:00:05.12

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
      14290  consistent gets
      14286  physical reads
          0  redo size
       2991  bytes sent via SQL*Net to client
        416  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          4  rows processed
We can begin to see how much more convenient the new PIVOT syntax is. Furthermore, despite the workloads of the two methods being the same, the manual pivot technique is 25% slower (observable over several runs of the same examples and also a version using CASE instead of DECODE).

pivoting an unknown domain of values

All of our examples so far have pivoted a known domain of values (in other words, we have used a hard-coded pivot_in_clause). The pivot syntax we have been using doesn't, by default, support a dynamic list of values in the pivot_in_clause. If we use a subquery instead of a list in the pivot_in_clause, as in the following example, Oracle raises a syntax error.

SQL> SELECT *
  2  FROM   emp
  3  PIVOT (SUM(sal) AS salaries
  4  FOR    deptno IN (SELECT deptno FROM dept));
FOR    deptno IN (SELECT deptno FROM dept))
                  *
ERROR at line 4:
ORA-00936: missing expression
Many developers will consider this to be a major restriction (despite the fact that pre-11g pivot techniques also require us to code an explicit set of values). However, it is possible to generate an unknown set of pivot values. Remember from the earlier syntax overview that PIVOT allows an optional "XML" keyword. As the keyword suggests, this enables us to generate a pivot set but have the results provided in XML format. An extension of this is that we can have an XML resultset generated for any number of pivot columns, as defined by a dynamic pivot_in_clause.

When using the XML extension, we have three options for generating the pivot_in_clause:

we can use an explicit list of values (we've been doing this so far in this article);
we can use the ANY keyword in the pivot_in_clause. This specifies that we wish to pivot for all values for the columns in the pivot_for_clause; or
we can use a subquery in the pivot_in_clause to derive the list of values.
We will concentrate on the dynamic methods. In the following example, we will use the ANY keyword to generate a pivoted resultset for any values of DEPTNO that we encounter in our dataset.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT  XML
  4        (SUM(sal) FOR deptno IN (ANY));

JOB       DEPTNO_XML
--------- ---------------------------------------------------------------------------
ANALYST   <PivotSet><item><column name = "DEPTNO">20</column><column name = "SUM(SAL)
          ">6600</column></item></PivotSet>

CLERK     <PivotSet><item><column name = "DEPTNO">10</column><column name = "SUM(SAL)
          ">1430</column></item><item><column name = "DEPTNO">20</column><column name
           = "SUM(SAL)">2090</column></item><item><column name = "DEPTNO">30</column>
          <column name = "SUM(SAL)">1045</column></item></PivotSet>

MANAGER   <PivotSet><item><column name = "DEPTNO">10</column><column name = "SUM(SAL)
          ">2695</column></item><item><column name = "DEPTNO">20</column><column name
           = "SUM(SAL)">3272.5</column></item><item><column name = "DEPTNO">30</colum
          n><column name = "SUM(SAL)">3135</column></item></PivotSet>

PRESIDENT <PivotSet><item><column name = "DEPTNO">10</column><column name = "SUM(SAL)
          ">5500</column></item></PivotSet>

SALESMAN  <PivotSet><item><column name = "DEPTNO">30</column><column name = "SUM(SAL)
          ">6160</column></item></PivotSet>


5 rows selected.
The XML resultset is of type XMLTYPE, which means that we can easily manipulate it with XPath or XQuery expressions. We can see that the generated pivot columns are named according to the pivot_clause and not the pivot_in_clause (remember that in the non-XML queries the pivot_in_clause values or aliases featured in all permutations of pivot column-naming). We can also see that the XML column name itself is a product of the pivot_for_clause: Oracle has appended "_XML" to "DEPTNO".

We will repeat the previous query but add an alias to the pivot_clause, as follows. If we wish to change the column name from "DEPTNO_XML", we use standard SQL column aliasing.

SQL> SELECT job
  2  ,      deptno_xml AS alias_for_deptno_xml
  3  FROM   pivot_data
  4  PIVOT  XML
  5        (SUM(sal) AS salaries FOR deptno IN (ANY));

JOB        ALIAS_FOR_DEPTNO_XML
---------- ---------------------------------------------------------------------------
ANALYST    <PivotSet><item><column name = "DEPTNO">20</column><column name = "SALARIES
           ">6600</column></item></PivotSet>

CLERK      <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">1430</column></item><item><column name = "DEPTNO">20</column><column name
            = "SALARIES">2090</column></item><item><column name = "DEPTNO">30</column>
           <column name = "SALARIES">1045</column></item></PivotSet>

MANAGER    <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">2695</column></item><item><column name = "DEPTNO">20</column><column name
            = "SALARIES">3272.5</column></item><item><column name = "DEPTNO">30</colum
           n><column name = "SALARIES">3135</column></item></PivotSet>

PRESIDENT  <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">5500</column></item></PivotSet>

SALESMAN   <PivotSet><item><column name = "DEPTNO">30</column><column name = "SALARIES
           ">6160</column></item></PivotSet>


5 rows selected.
As suggested, the pivot_clause alias defines the pivoted XML element names and the XML column name itself is defined by the projected alias.

An alternative to the ANY keyword is a subquery. In the following example, we will replace ANY with a query against the DEPT table to derive our list of DEPTNO values.

SQL> SELECT *
  2  FROM   pivot_data
  3  PIVOT  XML
  4        (SUM(sal) AS salaries FOR deptno IN (SELECT deptno FROM dept));

JOB        DEPTNO_XML
---------- ---------------------------------------------------------------------------
ANALYST    <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           "></column></item><item><column name = "DEPTNO">20</column><column name = "
           SALARIES">6600</column></item><item><column name = "DEPTNO">30</column><col
           umn name = "SALARIES"></column></item><item><column name = "DEPTNO">40</col
           umn><column name = "SALARIES"></column></item></PivotSet>

CLERK      <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">1430</column></item><item><column name = "DEPTNO">20</column><column name
            = "SALARIES">2090</column></item><item><column name = "DEPTNO">30</column>
           <column name = "SALARIES">1045</column></item><item><column name = "DEPTNO"
           >40</column><column name = "SALARIES"></column></item></PivotSet>

MANAGER    <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">2695</column></item><item><column name = "DEPTNO">20</column><column name
            = "SALARIES">3272.5</column></item><item><column name = "DEPTNO">30</colum
           n><column name = "SALARIES">3135</column></item><item><column name = "DEPTN
           O">40</column><column name = "SALARIES"></column></item></PivotSet>

PRESIDENT  <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           ">5500</column></item><item><column name = "DEPTNO">20</column><column name
            = "SALARIES"></column></item><item><column name = "DEPTNO">30</column><col
           umn name = "SALARIES"></column></item><item><column name = "DEPTNO">40</col
           umn><column name = "SALARIES"></column></item></PivotSet>

SALESMAN   <PivotSet><item><column name = "DEPTNO">10</column><column name = "SALARIES
           "></column></item><item><column name = "DEPTNO">20</column><column name = "
           SALARIES"></column></item><item><column name = "DEPTNO">30</column><column
           name = "SALARIES">6160</column></item><item><column name = "DEPTNO">40</col
           umn><column name = "SALARIES"></column></item></PivotSet>


5 rows selected.
We can see a key difference between this XML output and the resultset from the ANY method. When using the subquery method, Oracle will generate a pivot XML element for every value the subquery returns (one for each grouping). For example, ANALYST employees only work in DEPTNO 20, so the ANY method returns one pivot XML element for that department. The subquery method, however, generates four pivot XML elements (for DEPTNO 10,20,30,40) but only DEPTNO 20 is non-null. We can see this more clearly if we extract the salaries element from both pivot_in_clause methods, as follows.

SQL> SELECT job
  2  ,      EXTRACT(deptno_xml, '/PivotSet/item/column') AS salary_elements
  3  FROM   pivot_data
  4  PIVOT  XML
  5        (SUM(sal) AS salaries FOR deptno IN (ANY))
  6  WHERE  job = 'ANALYST';

JOB       SALARY_ELEMENTS
--------- ---------------------------------------------------------------------------
ANALYST   <column name="DEPTNO">20</column><column name="SALARIES">6600</column>

1 row selected.
Using the ANY method, Oracle has generated an XML element for the only DEPTNO (20). We will repeat the query but use the subquery method, as follows.

SQL> SELECT job
  2  ,      EXTRACT(deptno_xml, '/PivotSet/item/column') AS salary_elements
  3  FROM   pivot_data
  4  PIVOT  XML
  5        (SUM(sal) AS salaries FOR deptno IN (SELECT deptno FROM dept))
  6  WHERE  job = 'ANALYST';

JOB       SALARY_ELEMENTS
--------- ---------------------------------------------------------------------------
ANALYST   <column name="DEPTNO">10</column><column name="SALARIES"/><column name="DEP
          TNO">20</column><column name="SALARIES">6600</column><column name="DEPTNO">
          30</column><column name="SALARIES"/><column name="DEPTNO">40</column><colum
          n name="SALARIES"/>


1 row selected.
Despite the fact that three departments do not have salary totals, Oracle has generated an empty element for each one. Again, only department 20 has a value for salary total. Whichever method developers choose, therefore, depends on requirements, but it is important to recognise that working with XML often leads to inflated dataset or resultset volumes. In this respect, the subquery method can potentially generate a lot of additional data over and above the results themselves.

unpivot

We have explored the new 11g pivot capability in some detail above. We will now look at the new UNPIVOT operator. As its name suggests, an unpivot operation is the opposite of pivot (albeit without the ability to disaggregate the data). A simpler way of thinking about unpivot is that it turns pivoted columns into rows (one row of data for every column to be unpivoted). We will see examples of this below, but will start with an overview of the syntax, as follows.

SELECT ...
FROM   ...
UNPIVOT [INCLUDE|EXCLUDE NULLS]
   ( unpivot_clause
     unpivot_for_clause
     unpivot_in_clause )
WHERE  ...
The syntax is similar to that of PIVOT with some slight differences, including the meaning of the various clauses. These are described as follows:

unpivot_clause: this clause specifies a name for a column to represent the unpivoted measure values. In our previous pivot examples, the measure column was the sum of salaries for each job and department grouping;
unpivot_for_clause: the unpivot_for_clause specifies the name for the column that will result from our unpivot query. The data in this column describes the measure values in the unpivot_clause column; and
unpivot_in_clause: this contains the list of pivoted columns (not values) to be unpivoted.
The unpivot clauses are quite difficult to describe and are best served by some examples.

simple unpivot examples

Before we write an unpivot query, we will create a pivoted dataset to use in our examples. For simplicity, we will create a view using one of our previous pivot queries, as follows.

SQL> CREATE VIEW pivoted_data
  2  AS
  3     SELECT *
  4     FROM   pivot_data
  5     PIVOT (SUM(sal)
  6     FOR    deptno IN (10 AS d10_sal,
  7                       20 AS d20_sal,
  8                       30 AS d30_sal,
  9                       40 AS d40_sal));

View created.
The PIVOTED_DATA view contains our standard sum of department salaries by job, with the four department totals pivoted as we've seen throughout this article. As a final reminder of the nature of the data, we will query this view.

SQL> SELECT *
  2  FROM   pivoted_data;

JOB           D10_SAL    D20_SAL    D30_SAL    D40_SAL
---------- ---------- ---------- ---------- ----------
CLERK            1430       2090       1045
SALESMAN                               6160
PRESIDENT        5500
MANAGER          2695     3272.5       3135
ANALYST                     6600

5 rows selected.
We will now unpivot our dataset using the new 11g syntax as follows.

SQL> SELECT *
  2  FROM   pivoted_data
  3  UNPIVOT (
  4               deptsal                              --<-- unpivot_clause
  5           FOR saldesc                              --<-- unpivot_for_clause
  6           IN  (d10_sal, d20_sal, d30_sal, d40_sal) --<-- unpivot_in_clause
  7          );

JOB        SALDESC       DEPTSAL
---------- ---------- ----------
CLERK      D10_SAL          1430
CLERK      D20_SAL          2090
CLERK      D30_SAL          1045
SALESMAN   D30_SAL          6160
PRESIDENT  D10_SAL          5500
MANAGER    D10_SAL          2695
MANAGER    D20_SAL        3272.5
MANAGER    D30_SAL          3135
ANALYST    D20_SAL          6600

9 rows selected.
We can see from the results that Oracle has transposed each of our pivoted columns in the unpivot_in_clause and turned them into rows of data that describes our measure (i.e. 'D10_SAL', 'D20_SAL' and so on). The unpivot_for_clause gives this new unpivoted column a name (i.e "SALDESC"). The unpivot_clause itself defines our measure data, which in this case is the sum of the department's salary by job.

It is important to note that unpivot queries can work on any columns (i.e. not just aggregated or pivoted columns). We are using the pivoted dataset for consistency but we could just as easily unpivot the columns of any table or view we have.

handling null data

The maximum number of rows that can be returned by an unpivot query is the number of distinct groupings multiplied by the number of pivot columns (in our examples, 5 (jobs) * 4 (pivot columns) = 20). However, our first unpivot query has only returned nine rows. If we look at the source pivot data itself, we can see nine non-null values in the pivot columns; in other words, eleven groupings are null. The default behaviour of UNPIVOT is to exclude nulls, but we do have an option to include them, as follows.

SQL> SELECT *
  2  FROM   pivoted_data
  3  UNPIVOT INCLUDE NULLS
  4        (deptsal
  5  FOR    saldesc IN (d10_sal,
  6                     d20_sal,
  7                     d30_sal,
  8                     d40_sal));

JOB        SALDESC       DEPTSAL
---------- ---------- ----------
CLERK      D10_SAL          1430
CLERK      D20_SAL          2090
CLERK      D30_SAL          1045
CLERK      D40_SAL
SALESMAN   D10_SAL
SALESMAN   D20_SAL
SALESMAN   D30_SAL          6160
SALESMAN   D40_SAL
PRESIDENT  D10_SAL          5500
PRESIDENT  D20_SAL
PRESIDENT  D30_SAL
PRESIDENT  D40_SAL
MANAGER    D10_SAL          2695
MANAGER    D20_SAL        3272.5
MANAGER    D30_SAL          3135
MANAGER    D40_SAL
ANALYST    D10_SAL
ANALYST    D20_SAL          6600
ANALYST    D30_SAL
ANALYST    D40_SAL

20 rows selected.
By including the null pivot values, we return the maximum number of rows possible from our dataset. Of course, we now have eleven null values, but this might be something we require for reporting purposes or "data densification".

unpivot aliasing options

In the pivot section of this article, we saw a wide range of aliasing options. The UNPIVOT syntax also allows us to use aliases, but it is far more restrictive. In fact, we can only alias the columns defined in the unpivot_in_clause, as follows.

SQL> SELECT job
  2  ,      saldesc
  3  ,      deptsal
  4  FROM   pivoted_data
  5  UNPIVOT (deptsal
  6  FOR      saldesc IN (d10_sal AS 'SAL TOTAL FOR 10',
  7                       d20_sal AS 'SAL TOTAL FOR 20',
  8                       d30_sal AS 'SAL TOTAL FOR 30',
  9                       d40_sal AS 'SAL TOTAL FOR 40'))
 10  ORDER  BY
 11         job
 12  ,      saldesc;

JOB        SALDESC                 DEPTSAL
---------- -------------------- ----------
ANALYST    SAL TOTAL FOR 20           6600
CLERK      SAL TOTAL FOR 10           1430
CLERK      SAL TOTAL FOR 20           2090
CLERK      SAL TOTAL FOR 30           1045
MANAGER    SAL TOTAL FOR 10           2695
MANAGER    SAL TOTAL FOR 20         3272.5
MANAGER    SAL TOTAL FOR 30           3135
PRESIDENT  SAL TOTAL FOR 10           5500
SALESMAN   SAL TOTAL FOR 30           6160

9 rows selected.
This is a useful option because it enables us to change the descriptive data to something other than its original column name. If we wish to alias the column in the unpivot_clause (in our case, DEPTSAL), we need to use standard column aliasing in the SELECT clause. Of course, aliasing the unpivot_for_clause is irrelevant because we have just defined this derived column name in the clause itself (in our case, "SALDESC").

general restrictions

The UNPIVOT syntax can be quite fiddly and there are some minor restrictions to how it can be used. The main restriction is that the columns in the unpivot_in_clause must all be of the same datatype. We will see this below by attempting to unpivot three columns of different datatypes from EMP. The unpivot query itself is meaningless: it is just a means to show the restriction, as follows.

SQL> SELECT empno
  2  ,      job
  3  ,      unpivot_col_name
  4  ,      unpivot_col_value
  5  FROM   emp
  6  UNPIVOT (unpivot_col_value
  7  FOR      unpivot_col_name
  8  IN      (ename, deptno, hiredate));
IN      (ename, deptno, hiredate))
                *
ERROR at line 8:
ORA-01790: expression must have same datatype as corresponding expression
Oracle is also quite fussy about datatype conversion. In the following example, we will attempt to convert the columns to the same VARCHAR2 datatype.

SQL> SELECT job
  2  ,      unpivot_col_name
  3  ,      unpivot_col_value
  4  FROM   emp
  5  UNPIVOT (unpivot_col_value
  6  FOR      unpivot_col_name
  7  IN      (ename, TO_CHAR(deptno), TO_CHAR(hiredate)));
IN      (ename, TO_CHAR(deptno), TO_CHAR(hiredate)))
                       *
ERROR at line 7:
ORA-00917: missing comma
It appears that using datatype conversions within the unpivot_in_clause is not even valid syntax and Oracle raises an exception accordingly. The workaround is, therefore, to convert the columns up-front, using an in-line view, subquery or a stored view. We will use subquery factoring, as follows.

SQL> WITH emp_data AS (
  2          SELECT empno
  3          ,      job
  4          ,      ename
  5          ,      TO_CHAR(deptno)   AS deptno
  6          ,      TO_CHAR(hiredate) AS hiredate
  7          FROM   emp
  8          )
  9  SELECT empno
 10  ,      job
 11  ,      unpivot_col_name
 12  ,      unpivot_col_value
 13  FROM   emp_data
 14  UNPIVOT (unpivot_col_value
 15  FOR      unpivot_col_name
 16  IN      (ename, deptno, hiredate));

     EMPNO JOB        UNPIVOT_COL_NAME     UNPIVOT_COL_VALUE
---------- ---------- -------------------- --------------------
      7369 CLERK      ENAME                SMITH
      7369 CLERK      DEPTNO               20
      7369 CLERK      HIREDATE             17/12/1980
      7499 SALESMAN   ENAME                ALLEN
      7499 SALESMAN   DEPTNO               30
      7499 SALESMAN   HIREDATE             20/02/1981
      
      <<...snip...>>

      7902 ANALYST    ENAME                FORD
      7902 ANALYST    DEPTNO               20
      7902 ANALYST    HIREDATE             03/12/1981
      7934 CLERK      ENAME                MILLER
      7934 CLERK      DEPTNO               10
      7934 CLERK      HIREDATE             23/01/1982

42 rows selected.
The output has been reduced, but we can see the effect of unpivoting on the EMP data (i.e. we have 3 unpivot columns, 14 original rows and hence 42 output records).

Another restriction with UNPIVOT is that the columns we include in the unpivot_in_clause are not available to us to project outside of the pivot_clause itself. In the following example, we will try to project the DEPTNO column.

SQL> WITH emp_data AS (
  2          SELECT empno
  3          ,      job
  4          ,      ename
  5          ,      TO_CHAR(deptno)   AS deptno
  6          ,      TO_CHAR(hiredate) AS hiredate
  7          FROM   emp
  8          )
  9  SELECT empno
 10  ,      job
 11  ,      deptno
 12  ,      unpivot_col_name
 13  ,      unpivot_col_value
 14  FROM   emp_data
 15  UNPIVOT (unpivot_col_value
 16  FOR      unpivot_col_name
 17  IN      (ename, deptno, hiredate));
,      deptno
       *
ERROR at line 11:
ORA-00904: "DEPTNO": invalid identifier
Oracle raises an invalid identifier exception. We can see why this is the case when we project all available columns from our unpivot query over EMP, as follows.

SQL> WITH emp_data AS (
  2          SELECT empno
  3          ,      job
  4          ,      ename
  5          ,      TO_CHAR(deptno)   AS deptno
  6          ,      TO_CHAR(hiredate) AS hiredate
  7          FROM   emp
  8          )
  9  SELECT *
 10  FROM   emp_data
 11  UNPIVOT (unpivot_col_value
 12  FOR      unpivot_col_name
 13  IN      (ename, deptno, hiredate));

     EMPNO JOB        UNPIVOT_COL_NAME     UNPIVOT_COL_VALUE
---------- ---------- -------------------- --------------------
      7369 CLERK      ENAME                SMITH
      7369 CLERK      DEPTNO               20
      7369 CLERK      HIREDATE             17/12/1980
      
      <<...snip...>>

      7934 CLERK      ENAME                MILLER
      7934 CLERK      DEPTNO               10
      7934 CLERK      HIREDATE             23/01/1982

42 rows selected.
We can see that the unpivot columns are not available as part of the projection.

execution plans for unpivot operations

Earlier we saw the GROUP BY PIVOT operation in the execution plans for our pivot queries. In the following example, we will use Autotrace to generate an explain plan for our last unpivot query.

SQL> set autotrace traceonly explain

SQL> SELECT job
  2  ,      saldesc
  3  ,      deptsal
  4  FROM   pivoted_data
  5  UNPIVOT (deptsal
  6  FOR      saldesc IN (d10_sal AS 'SAL TOTAL FOR 10',
  7                       d20_sal AS 'SAL TOTAL FOR 20',
  8                       d30_sal AS 'SAL TOTAL FOR 30',
  9                       d40_sal AS 'SAL TOTAL FOR 40'))
 10  ORDER  BY
 11         job
 12  ,      saldesc;

Execution Plan
----------------------------------------------------------
Plan hash value: 1898428924

----------------------------------------------------------------------------------------
| Id  | Operation               | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |              |    20 |   740 |    17  (30)| 00:00:01 |
|   1 |  SORT ORDER BY          |              |    20 |   740 |    17  (30)| 00:00:01 |
|*  2 |   VIEW                  |              |    20 |   740 |    16  (25)| 00:00:01 |
|   3 |    UNPIVOT              |              |       |       |            |          |
|   4 |     VIEW                | PIVOTED_DATA |     5 |   290 |     4  (25)| 00:00:01 |
|   5 |      HASH GROUP BY PIVOT|              |     5 |    75 |     4  (25)| 00:00:01 |
|   6 |       TABLE ACCESS FULL | EMP          |    14 |   210 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("unpivot_view"."DEPTSAL" IS NOT NULL)
The points of interest are highlighted. First, we can see a new UNPIVOT step (ID=3). Second, we can see a filter predicate to remove all NULL values for DEPTSAL. This is a result of the default EXCLUDING NULLS clause. If we use the INCLUDING NULLS option, this filter is removed. Note that the GROUP BY PIVOT operation at ID=5 is generated by the pivot query that underlies the PIVOTED_DATA view.

We will extract some more detailed information about this execution plan by using DBMS_XPLAN's format options, as follows. In particular, we will examine the alias and projection details, to see if it provides any clues about Oracle's implementation of UNPIVOT.

SQL> EXPLAIN PLAN SET STATEMENT_ID = 'UNPIVOT'
  2  FOR
  3     SELECT job
  4     ,      saldesc
  5     ,      deptsal
  6     FROM   pivoted_data
  7     UNPIVOT (deptsal
  8     FOR      saldesc IN (d10_sal AS 'SAL TOTAL FOR 10',
  9                          d20_sal AS 'SAL TOTAL FOR 20',
 10                          d30_sal AS 'SAL TOTAL FOR 30',
 11                          d40_sal AS 'SAL TOTAL FOR 40'))
 12     ORDER  BY
 13            job
 14     ,      saldesc;

Explained.

SQL> SELECT *
  2  FROM   TABLE(
  3             DBMS_XPLAN.DISPLAY(
  4                NULL, 'UNPIVOT', 'TYPICAL +PROJECTION +ALIAS'));

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------
Plan hash value: 1898428924

----------------------------------------------------------------------------------------
| Id  | Operation               | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |              |    20 |   740 |    17  (30)| 00:00:01 |
|   1 |  SORT ORDER BY          |              |    20 |   740 |    17  (30)| 00:00:01 |
|*  2 |   VIEW                  |              |    20 |   740 |    16  (25)| 00:00:01 |
|   3 |    UNPIVOT              |              |       |       |            |          |
|   4 |     VIEW                | PIVOTED_DATA |     5 |   290 |     4  (25)| 00:00:01 |
|   5 |      HASH GROUP BY PIVOT|              |     5 |    75 |     4  (25)| 00:00:01 |
|   6 |       TABLE ACCESS FULL | EMP          |    14 |   210 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$D50F4D64
   2 - SET$1        / unpivot_view@SEL$17
   3 - SET$1
   4 - SEL$CB31B938 / PIVOTED_DATA@SEL$4
   5 - SEL$CB31B938
   6 - SEL$CB31B938 / EMP@SEL$15

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("unpivot_view"."DEPTSAL" IS NOT NULL)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

  1 - (#keys=2) "unpivot_view"."JOB"[VARCHAR2,9],
       "unpivot_view"."SALDESC"[CHARACTER,16], "unpivot_view"."DEPTSAL"[NUMBER,22]
   2 - "unpivot_view"."JOB"[VARCHAR2,9],
       "unpivot_view"."SALDESC"[CHARACTER,16], "unpivot_view"."DEPTSAL"[NUMBER,22]
   3 - STRDEF[9], STRDEF[16], STRDEF[22]
   4 - "PIVOTED_DATA"."JOB"[VARCHAR2,9], "D10_SAL"[NUMBER,22],
       "PIVOTED_DATA"."D20_SAL"[NUMBER,22], "PIVOTED_DATA"."D30_SAL"[NUMBER,22],
       "PIVOTED_DATA"."D40_SAL"[NUMBER,22]
   5 - (#keys=1) "JOB"[VARCHAR2,9], SUM(CASE  WHEN ("DEPTNO"=10) THEN "SAL" END
       )[22], SUM(CASE  WHEN ("DEPTNO"=20) THEN "SAL" END )[22], SUM(CASE  WHEN
       ("DEPTNO"=30) THEN "SAL" END )[22], SUM(CASE  WHEN ("DEPTNO"=40) THEN "SAL" END
       )[22]
   6 - "JOB"[VARCHAR2,9], "SAL"[NUMBER,22], "DEPTNO"[NUMBER,22]

45 rows selected.
The projection of the unpivoted columns is highlighted between operations 1 and 3 above. This does not really provide any clues to how Oracle implements UNPIVOT. Note that a 10046 trace (SQL trace) provides no clues either, so has been omitted from this article.

The alias information is slightly more interesting, but still tells us little about UNPIVOT. It might be a red herring, but when Oracle transforms a simple query, the generated alias names for query blocks usually follow a pattern such as "SEL$1", "SEL$2" and so on. In our unpivot query, the aliases are as high as SEL$17, yet this is a relatively simple query with few components. This could suggest that a lot of query re-write is happening before optimisation, but we can't be certain from the details we have.

other uses for unpivot

Unpivot queries are not restricted to transposing previously pivoted data. We can pivot any set of columns from a table (within the datatype restriction described earlier). A good example is Tom Kyte's print_table procedure. This utility unpivots wide records to enable us to read the data down the page instead of across. The new UNPIVOT can be used for the same purpose. In the following example, we will write a static unpivot query similar to those that the print_table utility is used for.

SQL> WITH all_objects_data AS (
  2          SELECT owner
  3          ,      object_name
  4          ,      subobject_name
  5          ,      TO_CHAR(object_id)      AS object_id
  6          ,      TO_CHAR(data_object_id) AS data_object_id
  7          ,      object_type
  8          ,      TO_CHAR(created)        AS created
  9          ,      TO_CHAR(last_ddl_time)  AS last_ddl_time
 10          ,      timestamp
 11          ,      status
 12          ,      temporary
 13          ,      generated
 14          ,      secondary
 15          ,      TO_CHAR(namespace)      AS namespace
 16          ,      edition_name
 17          FROM   all_objects
 18          WHERE  ROWNUM = 1
 19          )
 20  SELECT column_name
 21  ,      column_value
 22  FROM   all_objects_data
 23  UNPIVOT (column_value
 24  FOR      column_name
 25  IN      (owner, object_name, subobject_name, object_id,
 26           data_object_id, object_type, created, last_ddl_time,
 27           timestamp, status, temporary, generated,
 28           secondary, namespace, edition_name));

COLUMN_NAME    COLUMN_VALUE
-------------- ---------------------
OWNER          SYS
OBJECT_NAME    ICOL$
OBJECT_ID      20
DATA_OBJECT_ID 2
OBJECT_TYPE    TABLE
CREATED        15/10/2007 10:09:08
LAST_DDL_TIME  15/10/2007 10:56:08
TIMESTAMP      2007-10-15:10:09:08
STATUS         VALID
TEMPORARY      N
GENERATED      N
SECONDARY      N
NAMESPACE      1

13 rows selected.
Turning this into a dynamic SQL solution is simple and can be an exercise for the reader.

unpivot queries prior to 11g

To complete this article, we will include a couple of techniques for unpivot queries in versions prior to 11g and compare their performance. The first method uses a Cartesian Product with a generated dummy rowsource. This rowsource has the same number of rows as the number of columns we wish to unpivot. Using the same dataset as our UNPIVOT examples, we will demonstrate this below.

SQL> WITH row_source AS (
  2          SELECT ROWNUM AS rn
  3          FROM   all_objects
  4          WHERE  ROWNUM <= 4
  5          )
  6  SELECT p.job
  7  ,      CASE r.rn
  8            WHEN 1
  9            THEN 'D10_SAL'
 10            WHEN 2
 11            THEN 'D20_SAL'
 12            WHEN 3
 13            THEN 'D30_SAL'
 14            WHEN 4
 15            THEN 'D40_SAL'
 16         END AS saldesc
 17  ,      CASE r.rn
 18            WHEN 1
 19            THEN d10_sal
 20            WHEN 2
 21            THEN d20_sal
 22            WHEN 3
 23            THEN d30_sal
 24            WHEN 4
 25            THEN d40_sal
 26         END AS deptsal
 27  FROM   pivoted_data p
 28  ,      row_source   r
 29  ORDER  BY
 30         p.job
 31  ,      saldesc;

JOB        SALDESC       DEPTSAL
---------- ---------- ----------
ANALYST    D10_SAL
ANALYST    D20_SAL          6600
ANALYST    D30_SAL
ANALYST    D40_SAL
CLERK      D10_SAL          1430
CLERK      D20_SAL          2090
CLERK      D30_SAL          1045
CLERK      D40_SAL
MANAGER    D10_SAL          2695
MANAGER    D20_SAL        3272.5
MANAGER    D30_SAL          3135
MANAGER    D40_SAL
PRESIDENT  D10_SAL          5500
PRESIDENT  D20_SAL
PRESIDENT  D30_SAL
PRESIDENT  D40_SAL
SALESMAN   D10_SAL
SALESMAN   D20_SAL
SALESMAN   D30_SAL          6160
SALESMAN   D40_SAL

20 rows selected.
The resultset is the equivalent of using the new UNPIVOT with the INCLUDING NULLS option. The second technique we can use to unpivot data joins the pivoted dataset to a collection of the columns we wish to transpose. The following example uses a generic NUMBER_NTT nested table type to hold the pivoted department salary columns. We can use a numeric type because all the pivoted columns are of NUMBER. We will create the type as follows.

SQL> CREATE OR REPLACE TYPE number_ntt AS TABLE OF NUMBER;
  2  /

Type created.
Using this collection type for the pivoted department salaries, we will now unpivot the data, as follows.

SQL> SELECT p.job
  2  ,      s.column_value AS deptsal
  3  FROM   pivoted_data p
  4  ,      TABLE(number_ntt(d10_sal,d20_sal,d30_sal,d40_sal)) s
  5  ORDER  BY
  6         p.job;

JOB           DEPTSAL
---------- ----------
ANALYST
ANALYST          6600
ANALYST
ANALYST
CLERK
CLERK            1045
CLERK            1430
CLERK            2090
MANAGER        3272.5
MANAGER
MANAGER          3135
MANAGER          2695
PRESIDENT
PRESIDENT
PRESIDENT
PRESIDENT        5500
SALESMAN         6160
SALESMAN
SALESMAN
SALESMAN

20 rows selected.
While we have unpivoted the department salaries, we have lost our descriptive labels for each of the values. There is no simple way with this technique to decode a row number (like we did in the Cartesian Product example). We can, however, change the collection type we use to include a descriptor. For this purpose, we will first create a generic object type to define a single row of numeric unpivot data, as follows.

SQL> CREATE TYPE name_value_ot AS OBJECT
  2  ( name  VARCHAR2(30)
  3  , value NUMBER
  4  );
  5  /

Type created.
We will now create a collection type based on this object, as follows.

SQL> CREATE TYPE name_value_ntt
  2     AS TABLE OF name_value_ot;
  3  /

Type created.
We will now repeat our previous unpivot query, but provide descriptions using our new collection type.

SQL> SELECT p.job
  2  ,      s.name  AS saldesc
  3  ,      s.value AS deptsal
  4  FROM   pivoted_data p
  5  ,      TABLE(
  6            name_value_ntt(
  7               name_value_ot('D10_SAL', d10_sal),
  8               name_value_ot('D20_SAL', d20_sal),
  9               name_value_ot('D30_SAL', d30_sal),
 10               name_value_ot('D40_SAL', d40_sal) )) s
 11  ORDER  BY
 12         p.job
 13  ,      s.name;

JOB        SALDESC       DEPTSAL
---------- ---------- ----------
ANALYST    D10_SAL
ANALYST    D20_SAL          6600
ANALYST    D30_SAL
ANALYST    D40_SAL
CLERK      D10_SAL          1430
CLERK      D20_SAL          2090
CLERK      D30_SAL          1045
CLERK      D40_SAL
MANAGER    D10_SAL          2695
MANAGER    D20_SAL        3272.5
MANAGER    D30_SAL          3135
MANAGER    D40_SAL
PRESIDENT  D10_SAL          5500
PRESIDENT  D20_SAL
PRESIDENT  D30_SAL
PRESIDENT  D40_SAL
SALESMAN   D10_SAL
SALESMAN   D20_SAL
SALESMAN   D30_SAL          6160
SALESMAN   D40_SAL

20 rows selected.
We can see that the new 11g UNPIVOT syntax is easier to use than the pre-11g alternatives. We will also compare the performance of each of these techniques, using Autotrace, the wall-clock and our MILLION_ROWS test table. We will start with the new 11g syntax and unpivot the three numeric columns of our test table, as follows.

SQL> set autotrace traceonly statistics

SQL> set timing on

SQL> SELECT *
  2  FROM   million_rows
  3  UNPIVOT (column_value
  4  FOR      column_name
  5  IN      (pivoting_col, summing_col, grouping_col));

3000000 rows selected.

Elapsed: 00:00:09.51

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
      20290  consistent gets
      14286  physical reads
          0  redo size
   80492071  bytes sent via SQL*Net to client
      66405  bytes received via SQL*Net from client
       6001  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
    3000000  rows processed
The 11g UNPIVOT method generated 3 million rows in under 10 seconds with only slightly more logical I/O than in our PIVOT tests. We will compare this with the Cartesian Product method, but using a rowsource technique that generates no additional I/O (instead of the ALL_OBJECTS view that we used previously).

SQL> WITH row_source AS (
  2          SELECT ROWNUM AS rn
  3          FROM   dual
  4          CONNECT BY ROWNUM <= 3
  5          )
  6  SELECT m.padding_col
  7  ,      CASE r.rn
  8            WHEN 0
  9            THEN 'PIVOTING_COL'
 10            WHEN 1
 11            THEN 'SUMMING_COL'
 12            ELSE 'GROUPING_COL'
 13         END AS column_name
 14  ,      CASE r.rn
 15            WHEN 0
 16            THEN m.pivoting_col
 17            WHEN 1
 18            THEN m.summing_col
 19            ELSE m.grouping_col
 20         END AS column_value
 21  FROM   million_rows m
 22  ,      row_source   r;
 
3000000 rows selected.

Elapsed: 00:00:24.95

Statistics
----------------------------------------------------------
        105  recursive calls
          2  db block gets
      14290  consistent gets
      54288  physical reads
          0  redo size
   42742181  bytes sent via SQL*Net to client
      66405  bytes received via SQL*Net from client
       6001  SQL*Net roundtrips to/from client
          1  sorts (memory)
          1  sorts (disk)
    3000000  rows processed
The Cartesian Product method is considerably slower than the new 11g UNPIVOT syntax. It generates considerably more I/O and takes over twice as long (note that these results are repeatable across multiple re-runs). However, investigations with SQL trace indicate that this additional I/O is a result of direct path reads and writes to the temporary tablespace, to support a large buffer sort (i.e. the sort that accompanies a MERGE JOIN CARTESIAN operation). On most commercial systems, this buffer sort will probably be performed entirely in memory or the temporary tablespace access will be quicker. For a small system with slow disk access (such as the 11g database used for this article), it has a large impact on performance. We can tune this to a degree by forcing a nested loop join and/or avoiding the disk sort altogether, as follows.

SQL> WITH row_source AS (
  2          SELECT ROWNUM AS rn
  3          FROM   dual
  4          CONNECT BY ROWNUM <= 3
  5          )
  6  SELECT + ORDERED USE_NL(r) 
  7         m.padding_col
  8  ,      CASE r.rn
  9            WHEN 0
 10            THEN 'PIVOTING_COL'
 11            WHEN 1
 12            THEN 'SUMMING_COL'
 13            ELSE 'GROUPING_COL'
 14         END AS column_name
 15  ,      CASE r.rn
 16            WHEN 0
 17            THEN m.pivoting_col
 18            WHEN 1
 19            THEN m.summing_col
 20            ELSE m.grouping_col
 21         END AS column_value
 22  FROM   million_rows m
 23  ,      row_source   r;

3000000 rows selected.

Elapsed: 00:00:14.17

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
      20290  consistent gets
      14286  physical reads
          0  redo size
   64742156  bytes sent via SQL*Net to client
      66405  bytes received via SQL*Net from client
       6001  SQL*Net roundtrips to/from client
    1000000  sorts (memory)
          0  sorts (disk)
    3000000  rows processed
We have significantly reduced the elapsed time and I/O for this method on this database, but have introduced one million tiny sorts. We can easily reverse the nested loops order or use the NO_USE_MERGE hint (which also reverses the NL order), but this doubles the I/O and adds 10% to the elapsed time.

Moving on, we will finally compare our collection method, as follows.

SQL> SELECT m.padding_col
  2  ,      t.name  AS column_name
  3  ,      t.value AS column_value
  4  FROM   million_rows m
  5  ,      TABLE(
  6            name_value_ntt(
  7               name_value_ot('PIVOTING_COL', pivoting_col),
  8               name_value_ot('SUMMING_COL',  summing_col),
  9               name_value_ot('GROUPING_COL', grouping_col ))) t;

3000000 rows selected.

Elapsed: 00:00:12.84

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
      20290  consistent gets
      14286  physical reads
          0  redo size
   80492071  bytes sent via SQL*Net to client
      66405  bytes received via SQL*Net from client
       6001  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
    3000000  rows processed
This method is comparable in I/O to the new UNPIVOT operation but is approximately 35-40% slower. Further investigation using SQL trace suggests that this is due to additional CPU time spent in the collection iterator fetches. Therefore, the new UNPIVOT operation is both easier to code and quicker to run than its SQL alternatives.
/*