You Asked

Can you give me a solution for converting CLOBS datatype to VARCHAR datatypes, all the 
documents I refer to talk about converting BLOBS to VARCHAR and when I try and apply the 
examples to CLOBS, get errors 

and we said...


dbms_lob.substr( clob_column, for_how_many_bytes, from_which_byte );


for example:

  select dbms_lob.substr( x, 4000, 1 ) from T;

will get me the first 4000 bytes of the clob.  Note that when using SQL as I did, the max 
length is 4000.  You can get 32k using plsql:


declare
   my_var long;
begin
   for x in ( select X from t ) 
   loop
       my_var := dbms_lob.substr( x.X, 32000, 1 );
       ....
