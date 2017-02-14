-- A typical query that compares the sales for each store with the average sales for all stores
-- would require compuations as follows :-
--
--   * The total sales for all stores
--   * The number of stores
--   * The sum of sales for each store
--
-- A single SQL statement to sum salary deptwise would need to employ in-line views and also a subquery inside a HAVING clause:

SELECT  store_name,
        SUM(quantity)                                                   store_sales,
        (SELECT SUM(quantity) FRORM sales)/(SELECT count(*) FROM store) avg_sales
  FROM  store  s,
        sales  sl
 WHERE  s.store_key = sl.store_key
HAVING  SUM(quantity) > (SELECT SUM(quantity) FRORM sales)/(SELECT count(*) FROM store)
 GROUP
    BY  store_name
/



-- While this query provides the correct answer, it is difficult to read and complex to execute, re-computing the sum of sales multiple times.  
--
-- To prevent the unnecessary re-execution of the aggregation (SUM(sales)), we could create multiple temporary tables (CTAS) and use them to simplify our query.  
--
-- However, from 9i onwards it is possible to utilise the “WITH clause” instead of temporary tables - it computes the aggregation once, allocates a name, 
-- and can be referenced multiple times later in the query.
--

WITH
sum_sales 
AS 
  (select sum(quantity) all_sales from stores),
number_stores 
AS 
  (select count(*) nbr_stores from stores),
sales_by_store 
AS
  (select store_name, sum(quantity) store_sales from store s , sales  sl where s.store_key = sl.store_key)
SELECT
   store_name
FROM
   store,
   sum_sales,
   number_stores,
   sales_by_store
where
   store_sales > (all_sales / nbr_stores)
/