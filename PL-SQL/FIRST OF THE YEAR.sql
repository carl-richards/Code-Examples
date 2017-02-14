-- If you want the first day of the First month but for this year, then use this query

select trunc(to_date(sysdate,'DD-MON-RRRR'),'year') from dual;