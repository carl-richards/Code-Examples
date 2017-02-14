 

declare

 

   v_evaluate_n       number ;

 

   v_counter          number ;

 

begin

 

    v_evaluate_n := 5;

 

   v_counter := 1;

 

 

   for i in 1 .. 100

   loop

 

       IF MOD(v_counter,v_evaluate_n) = 0  -- comments

       THEN

           dbms_output.put_line(to_char(v_counter)||'  '||to_char(v_evaluate_n));

       ELSE

           dbms_output.put_line('Looping around');

       end If ;

 

      v_counter := v_counter + 1 ;

 

   end loop;

 

end;
