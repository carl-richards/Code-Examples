Not sure if you have already seen this but this will give you a nice grand total on a report.

 

select nrecstatus, strexceptionflag, sum(dpmtamnt), count(*) 

from int_payment_dtl 

where dtdue = '01-Sep-2010' 

and strcashbankcd = 'BBCW'

and strpayflag = 'D'

group by grouping sets ((nrecstatus, strexceptionflag),())

 

 

And to get it to display GRAND TOTAL:

 

select nvl(to_char(nrecstatus),'GRAND TOTAL') record_status, strexceptionflag exception_flag, total_amount, total_no

from 

(select nrecstatus, strexceptionflag, sum(dpmtamnt) total_amount, count(*) total_no

 from int_payment_dtl 

 where dtdue = '01-Sep-2010' 

 and strcashbankcd = 'BBCW'

 and strpayflag = 'D'

 group by grouping sets ((nrecstatus, strexceptionflag),()))

 

