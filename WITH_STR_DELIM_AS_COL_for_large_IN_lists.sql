--VARIABLE txt VARCHAR2(2000)
VARIABLE txt CLOB


EXEC :txt := '-
10974178,-
11023165,-
11023187,-
11023194,-
11023201,-
11023211,-
11023244,-
11023253,-
11023268,-
11023276,-
11023916,-
11023947,-
11023950,-
11023963,-
11023968,-
11023971,-
11023974,-
11023978,-
11023982,-
11023984,-
11023992,-
11023999,-
11024830,-
11024840,-
11024842,-
11024853,-
11024859,-
11024867,-
11024869,-
11024876,-
11024891,-
11024897,-
11024903,-
11024906,-
11024909,-
11024918,-
11024923,-
11024930,-
11024938,-
11024942,-
11024945,-
11024949,-
11024950,-
11024954,-
11024956,-
11024957,-
11024958,-
11025000,-
11025001,-
11025017,-
11025028,-
11025050,-
11025062,-
11025063,-
11025072,-
11025073,-
11025077,-
11025079,-
11030620,-
11030632,-
11030661,-
11030665,-
11030773,-
11031024'       
         


COLUMN strpolnbr FORMAT a30         
         
         
WITH data
AS       
(        
 SELECT TRIM( SUBSTR (str,
              INSTR (str, ',', 1, level  ) + 1,
              INSTR (str, ',', 1, level+1)
              - 
              INSTR (str, ',', 1, level) -1 ) ) AS token
   FROM (SELECT ','||:txt||',' str FROM dual)
   CONNECT BY level <= LENGTH(:txt)-LENGTH(REPLACE(:txt,',',''))+1
)        
SELECT strpolnbr 
  FROM hsasys.com_policy_m    c ,
       (SELECT * FROM data) d
 WHERE c.strpolnbr = TO_CHAR(d.token)  -- to_char if using clob above !
   AND c.npolstatcd = 1
   AND c.npmtmode = 12    
/        
         