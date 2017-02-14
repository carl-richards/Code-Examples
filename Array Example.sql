DECLARE

 

    CURSOR c1 (c_in VARCHAR2)
    IS
    SELECT table_name 
    FROM   user_tables
    WHERE  table_name LIKE c_in||'%' 
    ORDER
    BY     table_name DESC ;

    TYPE my_table_type IS TABLE of c1%ROWTYPE;
    my_tab  my_table_type  := my_table_type() ;

    TYPE my_array_type IS TABLE OF VARCHAR2(20) ;
    my_array my_array_type := my_array_type();

BEGIN

    my_array.extend(10);
 

    my_array(1)  := 'CPRD_NOT_IN_FVAD_' ;
    my_array(2)  := 'CPRA_NOT_IN_FVAD_' ;
    my_array(3)  := 'CAPA_NOT_IN_FVAD_' ;
    my_array(4)  := 'CAPD_NOT_IN_FVAD_' ;
    my_array(5)  := 'CAP_NOT_IN_CAPD_' ;
    my_array(6)  := 'CAPD_NOT_IN_CAP_' ;
    my_array(7)  := 'CPD_NOT_IN_CPRD_' ;
    my_array(8)  := 'CPRD_NOT_IN_CPD_' ;
    my_array(9)  := 'CPD_NOT_EQ_CPRD_' ;
    my_array(10) := 'CAP_NOT_EQ_CAPD_' ;
 
    FOR i in 1 .. my_array.LAST
    LOOP

        OPEN c1(my_array(i)) ;
        FETCH c1 BULK COLLECT INTO my_tab ;
        CLOSE c1;

        FOR j in 15 .. my_tab.COUNT
        LOOP
            dbms_output.put_line(my_array(i) ||' '||my_tab(j).table_name ) ;
        END LOOP;

    END LOOP;

END;

/

