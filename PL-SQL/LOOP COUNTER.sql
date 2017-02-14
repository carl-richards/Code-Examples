



BEGIN
FOR v_loopcounter IN 2..7 LOOP
DBMS_OUTPUT.PUT_LINE('Loop counter is ' || v_loopcounter);
END LOOP;
END;
/