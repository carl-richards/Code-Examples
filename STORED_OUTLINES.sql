STORED OUTLINE in Oracle 10g
Scope of this document 

This applies to Oracle 10g
How to use STORED Outline to fix a performance issue?
Ho to change the plan in the outline after generating it?
Some Pros & Cons of STORED OUTLINE
This document also highlight some of the key facts that an Oracle DBA should be aware of while using STORED OUTLINE. 

Query to identify stored Outlines in the database.

SELECT * FROM all_outlines;

Facts

When the desired execution plan is occuring for a SQL statement which is not identical in SQL text (whitespacing and case differences ignored) to the original SQL statement, then a Stored Outline for that SQL is not usable as the signature of the Stored Outline does not match
In other words, STORED OUTLINE are driven by the SIGNATURE of an inidivual SQL statement.
To create private stored outline do not use the procedure DBMS_OUTLN_EDIT.CREATE_EDIT_TABLES in Oracle10g and Oracle11g
DBMS_OUTLN.CREATE_OUTLINE procedure is hard parsing and using the optimizer environment of the session executing the procedure instead of using the one from the library cache. This is a BUG. Hence the stored outline created out of this procedure might differ from the original plan.
Unlike the traditional way, creating the stored outline in the lower environment and do export/import to get the outline to production, Oracle 10g has got the new way of creating it directly using the SQL ID, SQL_HASH_VALUE, SQL_CHILD_NUMBEr from the memory.
STORED OUTLINES doesnot work when you try it as SYS user.
Important : Though outlines are used and you follow all the steps correctly, NOT ALWAYS the execution plan is imposed as expected/desired. 
When swapping the outline (to replace the BAD plan with a GOOD plan) ensure the HINTCOUNT column is taken care.
Generally you may have read CURSOR_SHARING = FORCE disables the use of stored outlines. Actually the interpretation should be the other way.
i.e.
STORED OUTLINE creation also captures the essential optimizer paramaters which is also assessed before overwriting a plan.
If there is a mismatch then STORED OUTLINE will not be used for a SQL statement.
For Eg.
If OL1 is created with CURSOR_SHARING=FORCE, then a session with CURSOR_SHARING=EXACT/SIMILAR would not be able to use the outline OL1.
In this scenario STORED OUTLINE is disabled.
PRIVATE outlines are automatically created in SYSTEM.OL$ table and this is a local temporary table. Hence the records vanishes the moment you exit the session
To use stored outline for your SQL statements a. alter session set use_stored_outlines=true; b. Ensure CURSOR_SHARING is NOT set to FORCE
Scenario

I have a single query which is using a BAD plan in the production database.You have the SQL_ID, SQL_HASH_VALUE & SQL_CHILD_NUMBER of this query which is using the BAD plan.

On the other side you either tune it by adding HINTS or have another version of this same query which is runinng fine in the same production database. What do I mean by another version of this same query?

For example, I ran the same SQL statement from another SQL prompt after substituting the BIND variables with the literalsand confirmed the execution plan was GOOD.

Important Note : This GOOD one was having different SQL_ID & SQL_HASH_VALUE

Goal of this article,

a. From the same database, create the OUTLINE out of the SQL statement which is having the GOOD plan

b. Make the original query adopt the above outline
Remember, all these steps are done in the same production database and out of the buffer cache.

Assumptions:

a. connect to a schema with CREATE ANY OUTLINE privilege

b. Perform these tasks as any schema other than SYS

c. Using DEFAULT category

d. The schema should have privilege to query v$sql & v$session

e. HINTCOUNT is same for both GOOD & BAD plan

Overall Steps

a) Generate the outline, name it OL1, for the BAD plan using the seperate SQL_HASH_VALUE & SQL_CHILD_NUMBER.

b) Generate an another outline, name it OL2, for the GOOD plan using seperate SQL_HASH_VALUE & SQL_CHILD_NUMBER.
Eg.
GOOD : select * from emp; ===> OL1

BAD : select * from emp where ename='scott'; ===> OL2


Method 1

c) Update/Edit the outline OL2 by replacing with the values of OL1, so that both OL1 & OL2 should look alike.

Method 2

c) Rename the outline OL2 to OL1 and viceversa.

Method 3

c) Create a new private outline "PRIVOL2" out of OL2

d) Edit the private outline

f) resynchronize the private Stored Outline

g) Replace the original outline OL2 with this edited private outline "PRIVOL2"

Method 4

c) Create a new private outline "PRIVOL1" out of OL1

d) Create a new private outline "PRIVOL2" out of OL2

e) Edit the private outline

f) resynchronize the private Stored Outline

g) Replace the original outline OL2 with this edited private outline "PRIVOL2"


Detailed Steps

create table emp (empno number, ename varchar2(10)) tablespace users01;

create index empidx on emp(empno,ename) tablespace users01;

begin
for i in 1..200 loop
insert into emp values (i,'blake');
end loop;
commit;
end;
/

begin
for i in 1..200 loop
insert into emp values (i,'scott');
end loop;
commit;
end;
/

execute DBMS_STATS.GATHER_TABLE_STATS(ownname =>'SCOTT', tabname => 'EMP', estimate_percent => 100, cascade => TRUE);


Open two seperate sqlplus session as SCOTT user
In Session 1 : select distinct sid from v$mystat; ----- Lets assume the SID # 514

In Session 1 : select * from emp;

In session 2 :

select sid,serial#,sql_id,sql_child_number,sql_hash_value,prev_sql_id,prev_hash_value,prev_child_number from v$session where sid=514;

In session 1 : select * from emp where ename='scott';

In session 2 :

select sid,serial#,sql_id,sql_child_number,sql_hash_value,prev_sql_id,prev_hash_value,prev_child_number from v$session where sid=514;

From the above exercise we got SQL ID, SQL HASH VALUE and CHILD NUMBER of both GOOD & BAD sql statement.

GOOD : select * from emp; ===> OL1

BAD : select * from emp where ename='scott'; ===> OL2

SQL_ID SQL_HASH_VALUE SQL_PLAN_HASH_VALUE SQL_CHILD_NUMBER SQL_TEXT============== ============== =================== ================ =====================================a2dk8bdn0ujx7 1745700775 2872589290 0 select * from emp;7h38thzz3wug9 4265503209 818394873 0 select * from emp where ename='badri'
select * from TABLE(dbms_xplan.display_cursor('a2dk8bdn0ujx7',0));
Plan hash value: 2872589290
-------------------------------------------------------------------------- Id Operation Name Rows Bytes Cost (%CPU) Time -------------------------------------------------------------------------- 0 SELECT STATEMENT 2 (100) 1 TABLE ACCESS FULL EMP 60 540 2 (0) 00:00:01 

select * from TABLE(dbms_xplan.display_cursor('7h38thzz3wug9',0));
Plan hash value: 818394873
--------------------------------------------------------------------------- Id Operation Name Rows Bytes Cost (%CPU) Time --------------------------------------------------------------------------- 0 SELECT STATEMENT 1 (100) * 1 INDEX FULL SCAN EMPIDX 20 180 1 (0) 00:00:01


Goal : To make the BAD sql statement to use FULL TABLE SCAN instead of INDEX FULL SCAN.
Steps Common to ALL methods

1) Create outline using the SQL HASH VALUE & CHILD NUMBER

alter session set create_stored_outlines=true;

exec dbms_outln.CREATE_OUTLINE(1745700775,0);

exec dbms_outln.CREATE_OUTLINE(4265503209,0);

alter session set create_stored_outlines=false;

2) Query them to confirm the presence
col ol_name form a30

col sql_text form a40

col category form a10

col hint_text form a75

set lines 200
select ol_name,hintcount,HASH_VALUE,CATEGORY,HASH_VALUE2,SIGNATURE,sql_text from outln.ol$;

select ol_name,hint#,hint_text from outln.ol$hints order by 1,2;


3) Rename them for easy use


alter outline SYS_OUTLINE_09061700365898670 rename to OL1;

commit;

alter outline SYS_OUTLINE_09061700365899172 rename to OL2;

commit;

Method 1

UPDATE outln.ol$hints a SET a.hint_text=(select b.hint_text from outln.ol$hints b where b.ol_name='OL1' and a.hint#=b.hint#) where a.ol_name='OL2'; and a.hint#=1;

commit;

Method 2

UPDATE outln.ol$hints SET ol_name = decode(ol_name, 'OL1','OL2','OL2','OL1') WHERE ol_name in ('OL1','OL2');

commit;

Method 3

create private outline PRIVOL2 from OL2;

commit;

update system.ol$hints set hint_text='FULL(@"SEL$1" http://www.blogger.com/'mailto: where ol_name='PRIVOL1' and hint#=6;

commit;

execute dbms_outln_edit.refresh_private_outline('PRIVOL2');

create or replace outline OL2 from private PRIVOL2;

Method 4

create private outline PRIVOL1 from OL1;

commit;

create private outline PRIVOL2 from OL2;

commit;

UPDATE system.ol$hints SET ol_name = decode(ol_name, 'PRIVOL1','PRIVOL2','PRIVOL2','PRIVOL1') WHERE ol_name in ('PRIVOL1','PRIVOL2');

commit;

execute dbms_outln_edit.refresh_private_outline('PRIVOL1');

commit;

execute dbms_outln_edit.refresh_private_outline('PRIVOL2');

commit;

create or replace outline OL2 from private PRIVOL2;

Keywords:

stored; outline; create;memory ; cache; edit;swap;dbms_outln.CREATE_OUTLINE