--Only get the first 3 rows:

select * from X order by id
fetch first 3 rows only;

--Skip the first 3 rows and get the next 3 rows:

select * from X order by id
offset 3 rows fetch next 3 rows only;

--Get the first 50% of records

select * from X order by id
fetch first 50 percent rows only;

--Get the first 3 rows together with the records equal to these department id’s

select * from emp order by deptno
fetch first 3 rows with ties;
--If you want the capture the last rows, you can obviously change ‘first’ with ‘last’
