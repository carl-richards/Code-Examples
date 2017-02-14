Date and Time formats
When a date format is used by TO_CHAR or TO_DATE they return a formatted date/time. When used by TRUNC they will return the first day of the period. When used by ROUND the values will round up at mid year/mid month (July 1 or 16th day)
 CC    Century
 SCC   Century BC prefixed with -

 YYYY  Year 1956
 SYYY  Year BC prefixed with -
 IYYY  ISO Year 1956
 YY    Year 56
 RR    Year 56 rollover for Y2K compatibility *
 RRRR  Year rollover (accepts 2 digits, returns 4) *
 YEAR  Year spelled out
 SYEAR Year spelled out BC prefixed with -
 BC    BC/AD Indicator *

 Q     Quarter : Jan-Mar=1, Apr-Jun=2

 MM    Month of year 01, 02…12
 MON   JAN, FEB
 MONTH In full [January  ]…[December ]
 FMMONTH In full [January]…[December] no trailing spaces
 RM    Roman Month I, II…XII *

 WW    Week of year 1-52
 W     Week of month 1-5
 IW    ISO std week of year

 DDD   Day of year 1-366 *
 DD    Day of month 1-31
 D     Day of week 1-7
 DAY   In full [Monday   ]…[Sunday   ]
 FMDAY In full [Monday]…[Sunday] no trailing spaces
 DY    MON…SUN
 DDTH  Ordinal Day 7TH
 DDSPTH Spell out ordinal SEVENTH
 J     Julian Day (days since 31/12/4713)

 HH    Hours of day (1-12)
 HH12  Hours of day (1-12)
 HH24  Hours of day (1-24)
 AM    am or pm *
 PM    am or pm *
 A.M.  a.m. or p.m. * 
 P.M.  a.m. or p.m. *
 MI    Minutes 0-59
 SS    Seconds 0-59 *
 SSSSS Seconds past midnight (0-86399) *

 TH    Convert to ordinal format. e.g. 1 becomes 1st
 SP    Spelled format (English.) Add SP to the end of a number element. 
       For example MMSP for months or HHsp for hours. 

 TZD   Abbreviated time zone name. ie PST.
 TZH   Time zone hour displacement
 TZM   Time zone minute displacement
 TZR   Time zone region• The following punctuation -/,.;: can be included in any date format, any other chars can be included "in quotes"
• Formats marked with * can only be used with TO_CHAR or TO_DATE not TRUNC() or ROUND()
• Formats that start with FM - zeros and blanks are suppressed. 
e.g. 
to_char(sysdate, 'FMMonth DD, YYYY'); will return 'June 9, 2005' not 'June 09 2005'
• Date formats that are spelled out in characters will adopt the capitalisation of the format
e.g. 
'MONTH' =JANUARY
'Month' = January
Examples
SQL> Select to_char(sysdate, 'yyyy/mm/dd') "Date Today" FROM dual;
 '2010/12/24'

SQL> Select to_char(sysdate, 'FMMonth DD, YYYY') FROM dual;
 'June 9, 2005'

SQL> select to_char(sysdate,'HH24:MI:SS') "Time Now" from dual;
 '14:35:56'