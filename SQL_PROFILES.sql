Think of a profile as a method of "analyzing a query"

In the past, the DBA could analyze:

o a table (getting number of rows, blocks and such)
o a column in a table (histograms)
o an index
o the "system"

Problem is - this gives the optimizer no information about the relationship between table 
T1 and table T2 when joined to T3.  It does not understand the relationship between these 
objects, especially when some other predicates are applied...

So, a sql profile is simply "more statistical information but gathered for a particular 
set of tables when queried together".  It helps the optimizer understand the unique 
relationship between table T1, T2, T3, .... 

http://download-west.oracle.com/docs/cd/B14117_01/server.101/b10743/mgmt_db.htm#sthref2203
http://download-west.oracle.com/docs/cd/B14117_01/server.101/b10752/sql_tune.htm#36550

think of the sql profile as the ability to "analyze a query"

A query to view all SQL profiles stored in a database. 
  
SELECT * FROM dba_sql_profiles;