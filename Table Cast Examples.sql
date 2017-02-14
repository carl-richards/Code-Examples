create or replace TYPE Dummy AS VARRAY (500) OF VARCHAR2(50);
/ 
 
 
declare

  in_dummy  dummy default dummy('a','b');
  x         number;

begin

  select count(*)
  into x
  from dual
  where 'a' in (select column_value from table(cast(in_dummy as dummy)));

  dbms_output.put_line(x);

end;
/ 



.... and some more complex examples....

/*
|| CAST and Table Functions - Listing 1
||
|| Contains practical examples of CAST function and table functions
||
|| Usage Notes:
|| This script is provided to demonstrate various Oracle features and 
|| should be carefully proofread before executing against any existing 
|| Oracle database to insure that no potential damage can occur.
||
*/

-----
-- Listing 1.1: Sorting PL/SQL Contents With CAST
-----

DROP TYPE person_names_t;
CREATE OR REPLACE TYPE person_names_t AS TABLE OF VARCHAR2(100);

SET SERVEROUTPUT ON 
DECLARE
    -- List of presidents since 1932, in no particular order
    presidents_t person_names_t := person_names_t(
        'Bush, George W. - 2000', 
        'Bush, George H. W. - 1988', 
        'Johnson, Lyndon B. - 1963',
        'Reagan, Ronald W. - 1980', 
        'Clinton, William J. -1992',
        'Truman, Harry S. - 1945',
        'Roosevelt, Franklin D. - 1932',
        'Eisenhower, Dwight D. - 1952',
        'Kennedy, John F. - 1960',
        'Nixon, Richard M. - 1968',
        'Ford, Gerald R. - 1976',
        'Carter, Jimmy - 1980'
        );
BEGIN
    -- Display all table entries in descending sequence
    DBMS_OUTPUT.PUT_LINE('Presidents after 1932, in reverse alphabetical order:');
    FOR rec IN (SELECT column_value favs
                  FROM TABLE (CAST (presidents_t AS person_names_t))
                 ORDER BY column_value DESC)
        LOOP
            DBMS_OUTPUT.PUT_LINE(rec.favs);
        END LOOP;

EXCEPTION
    WHEN OTHERS THEN 
        NULL;
END;
/

-----
-- Listing 1.2: Using CAST With Group Functions
-----
DROP TYPE numbers_t;
CREATE OR REPLACE TYPE numbers_t AS TABLE OF NUMBER(10);

DECLARE       
    random_numbers numbers_t := numbers_t(
            1000, 
            100, 
            500, 
            3000,
            4000, 
            2000, 
            300, 
            400, 
            200
    );
    tot_entries NUMBER(10) := 0;
    sum_number  NUMBER(10) := 0;
    min_number  NUMBER(10) := 0;
    max_number  NUMBER(10) := 0;
BEGIN

    SELECT 
        SUM(Column_value) total,
        COUNT(Column_value) tally,
        MIN(Column_value) bottom,
        MAX(Column_value) top
      INTO 
        sum_number,
        tot_entries,
        min_number,
        max_number
      FROM TABLE(CAST(random_numbers AS numbers_t));

     DBMS_OUTPUT.PUT_LINE('Results from Random Number Survey');
     DBMS_OUTPUT.PUT_LINE('Count:   ' || tot_entries );
     DBMS_OUTPUT.PUT_LINE('Total:   ' || sum_number );
     DBMS_OUTPUT.PUT_LINE('Minimum: ' || min_number );
     DBMS_OUTPUT.PUT_LINE('Maximum: ' || max_number );

EXCEPTION
    WHEN OTHERS THEN 
        NULL;
END;
/


-----
-- Listing 1.3: Create TYPEs and Table Function
-----
DROP TYPE wgt_cost_ctr;
DROP TYPE wgt_cost_ctr_t;

CREATE OR REPLACE TYPE wgt_cost_ctr IS OBJECT (
     cc_lvl     NUMBER(3),
     cc_nbr     NUMBER(5),
     cc_value   VARCHAR2(32)
);

CREATE OR REPLACE TYPE wgt_cost_ctr_t AS TABLE OF wgt_cost_ctr;

CREATE OR REPLACE FUNCTION hr.sf_gather_cost_centers (
    a_employee_id IN hr.employees.employee_id%TYPE
) RETURN hr.wgt_cost_ctr_t
IS
/*
|| Function: sf_gather_cost_centers
||
|| Description: Using the Cost Center type, accepts an Employee's current
|| list of  preferred cost centers and walks up the Division / Department / 
|| Employee hierarchy to find the appropriate one Cost Center for posting.
||
||
*/
    l_department_id NUMBER(5)   := 0;
    l_division_id   NUMBER(5)   := 0;
    retval wgt_cost_ctr_t := wgt_cost_ctr_t();

    CURSOR cur_cost_ctr_asgn (
        a_entity_id IN hr.cost_center_assignments.entity_id%TYPE,
        a_entity_type IN hr.cost_center_assignments.entity_type%TYPE
        ) IS       
      SELECT 
         DECODE(a_entity_type,'V', 1, 'D', 2, 'E', 3, NULL) cc_lvl,
         CCA.cost_ctr_id cc_nbr,
         CC.description cc_value
        FROM 
            hr.cost_center_assignments CCA,
            hr.cost_centers CC
       WHERE CCA.COST_CTR_ID = CC.COST_CTR_ID 
         AND CCA.entity_id = a_entity_id
         AND CCA.entity_type = a_entity_type;

    PROCEDURE expand_collection (cc_in IN wgt_cost_ctr)
    IS
    /*
    || Procedure: expand_collection
    || Adds the specified entry to the collection
    */
    BEGIN
        retval.EXTEND;
        retval(retval.LAST) := cc_in;
    END;
    
BEGIN

    -- Get the Department ID and Division ID for the specified Employee
    SELECT 
        E.department_id,
        D.division_id
    INTO
        l_department_id,
        l_division_id
    FROM 
        hr.employees E,
        hr.departments D,
        hr.divisions V
   WHERE E.Department_Id = D.Department_Id
     AND D.division_id = V.division_id
     AND E.employee_id = a_employee_id;


    -- Gather eligible Cost Centers for the specified Employee
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(a_employee_id, 'E')
        LOOP
            expand_collection(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;
  
    -- Gather eligible Cost Centers for the specified Employee's Department
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(l_department_id, 'D')
        LOOP
            expand_collection(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;

    -- Gather eligible Cost Centers for the specified Employee's Division
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(l_division_id, 'V')
        LOOP
        expand_collection(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;
    
    RETURN retval;
    
EXCEPTION
    WHEN OTHERS THEN 
        dbms_output.put_line('Fatal error encountered!');
         RETURN retval;
       
END sf_gather_cost_centers;
/


-----
-- Listing 1.4: Using a Table Function with CAST
-----

SELECT *
    FROM TABLE (CAST (sf_gather_cost_centers (114) 
        AS wgt_cost_ctr_t));

SELECT * 
    FROM TABLE (CAST (sf_gather_cost_centers (120) 
        AS wgt_cost_ctr_t));

SELECT * FROM (    
    SELECT 
        DISTINCT *  
        FROM TABLE (CAST (sf_gather_cost_centers (120) 
            AS wgt_cost_ctr_t))
      ORDER BY cc_lvl DESC
    )
WHERE rownum <= 5;


-----
-- Listing 1.5: Using a PIPELINED Table Function
-----
CREATE OR REPLACE FUNCTION hr.sf_gather_cost_centers (
    a_employee_id IN hr.employees.employee_id%TYPE
) RETURN hr.wgt_cost_ctr_t PIPELINED 
IS
/*
|| Function: sf_gather_cost_centers (PIPELINED)
||
|| Description: Using the Cost Center type, accepts an Employee's current
|| list of  preferred cost centers and walks up the Division / Department / 
|| Employee hierarchy to find the appropriate one Cost Center for posting.
||
||
*/
    l_department_id NUMBER(5)       := 0;
    l_division_id   NUMBER(5)       := 0;

    CURSOR cur_cost_ctr_asgn (
        a_entity_id IN hr.cost_center_assignments.entity_id%TYPE,
        a_entity_type IN hr.cost_center_assignments.entity_type%TYPE
        ) IS       
      SELECT 
         DECODE(a_entity_type,'V', 1, 'D', 2, 'E', 3, NULL) cc_lvl,
         CCA.cost_ctr_id cc_nbr,
         CC.description cc_value
        FROM 
            hr.cost_center_assignments CCA,
            hr.cost_centers CC
       WHERE CCA.COST_CTR_ID = CC.COST_CTR_ID 
         AND CCA.entity_id = a_entity_id
         AND CCA.entity_type = a_entity_type;

BEGIN

    -- Get the Department ID and Division ID for the specified Employee
    SELECT 
        E.department_id,
        D.division_id
    INTO
        l_department_id,
        l_division_id
    FROM 
        hr.employees E,
        hr.departments D,
        hr.divisions V
   WHERE E.Department_Id = D.Department_Id
     AND D.division_id = V.division_id
     AND E.employee_id = a_employee_id;


    -- Gather eligible Cost Centers for the specified Employee
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(a_employee_id, 'E')
        LOOP
            PIPE ROW(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;

    -- Gather eligible Cost Centers for the specified Employee's Department
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(l_department_id, 'D')
        LOOP
            PIPE ROW(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;

    -- Gather eligible Cost Centers for the specified Employee's Division
    FOR rec_cost_ctr_asgn IN cur_cost_ctr_asgn(l_division_id, 'V')
        LOOP
            PIPE ROW(wgt_cost_ctr(
                rec_cost_ctr_asgn.cc_lvl,
                rec_cost_ctr_asgn.cc_nbr,
                rec_cost_ctr_asgn.cc_value)
                );
        END LOOP;
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN 
        dbms_output.put_line('Fatal error encountered!');
         RETURN;
       
END sf_gather_cost_centers;
/


-----
-- Listing 1.6: Using a PIPELINED Table Function with CAST
-----
SELECT * 
    FROM TABLE (sf_gather_cost_centers (114));

SELECT * 
    FROM TABLE (sf_gather_cost_centers (120));

SELECT * FROM (    
    SELECT 
        DISTINCT *  
        FROM TABLE (sf_gather_cost_centers (120)) 
      ORDER BY cc_lvl DESC
    )
WHERE rownum <= 5;



