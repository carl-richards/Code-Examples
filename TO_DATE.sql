/*
This Oracle tutorial explains how to use the Oracle/PLSQL TO_DATE function with syntax and examples.

DESCRIPTION

The Oracle/PLSQL TO_DATE function converts a string to a date.

SYNTAX

The syntax for the Oracle/PLSQL TO_DATE function is:

TO_DATE( string1, [ format_mask ], [ nls_language ] )
Parameters or Arguments

string1 is the string that will be converted to a date.

format_mask is optional. This is the format that will be used to convert string1 to a date.

nls_language is optional. This is the nls language used to convert string1 to a date.

The following is a list of options for the format_mask parameter. These parameters can be used in many combinations.

Parameter	Explanation
YEAR	Year, spelled out
YYYY	4-digit year
YYY
YY
Y	Last 3, 2, or 1 digit(s) of year.
IYY
IY
I	Last 3, 2, or 1 digit(s) of ISO year.
IYYY	4-digit year based on the ISO standard
RRRR	Accepts a 2-digit year and returns a 4-digit year.
A value between 0-49 will return a 20xx year.
A value between 50-99 will return a 19xx year.
Q	Quarter of year (1, 2, 3, 4; JAN-MAR = 1).
MM	Month (01-12; JAN = 01).
MON	Abbreviated name of month.
MONTH	Name of month, padded with blanks to length of 9 characters.
RM	Roman numeral month (I-XII; JAN = I).
WW	Week of year (1-53) where week 1 starts on the first day of the year and continues to the seventh day of the year.
W	Week of month (1-5) where week 1 starts on the first day of the month and ends on the seventh.
IW	Week of year (1-52 or 1-53) based on the ISO standard.
D	Day of week (1-7).
DAY	Name of day.
DD	Day of month (1-31).
DDD	Day of year (1-366).
DY	Abbreviated name of day.
J	Julian day; the number of days since January 1, 4712 BC.
HH	Hour of day (1-12).
HH12	Hour of day (1-12).
HH24	Hour of day (0-23).
MI	Minute (0-59).
SS	Second (0-59).
SSSSS	Seconds past midnight (0-86399).
FF	Fractional seconds. Use a value from 1 to 9 after FF to indicate the number of digits in the fractional seconds. For example, 'FF4'.
AM, A.M., PM, or P.M.	Meridian indicator
AD or A.D	AD indicator
BC or B.C.	BC indicator
TZD	Daylight savings information. For example, 'PST'
TZH	Time zone hour.
TZM	Time zone minute.
TZR	Time zone region.
APPLIES TO

The TO_DATE function can be used in the following versions of Oracle/PLSQL:

Oracle 12c, Oracle 11g, Oracle 10g, Oracle 9i, Oracle 8i
EXAMPLE

Let's look at some Oracle TO_DATE function examples and explore how to use the TO_DATE function in Oracle/PLSQL.

For example:
*/
TO_DATE('2003/07/09', 'yyyy/mm/dd')
-- Result: date value of July 9, 2003

TO_DATE('070903', 'MMDDYY')
-- Result: date value of July 9, 2003

TO_DATE('20020315', 'yyyymmdd')
-- Result: date value of Mar 15, 2002