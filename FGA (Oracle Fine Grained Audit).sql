--BEGIN 
--dbms_fga.drop_policy(
--   object_schema => 'SALES_MI',
--   object_name   => 'SAL_ABSENCE',
--   policy_name   => 'SAL_ABSENCE_ADT'
--);
-- 
--END;
--
--/* Formatted on 08/01/2016 09:29:01 (QP5 v5.269.14213.34769) */
--BEGIN
-- dbms_fga.add_policy  (object_schema   =>'SALES_MI',
--                          object_name      =>'SAL_ABSENCE',
--                          policy_name      =>'SAL_ABSENCE_ADT',
--                          audit_condition  => NULL,
--                          audit_column     => NULL,
--                          statement_types  => 'INSERT,UPDATE,DELETE'
--      );
--      
--END;    

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_AD_USER_REDIRECT',
                          policy_name      =>'SAL_AD_USER_REDIRECT_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;    

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_AME_RELN',
                          policy_name      =>'SAL_AME_RELN_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END; 

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_JOKER_DAYS',
                          policy_name      =>'SAL_JOKER_DAYS_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_QUALITY_GATE',
                          policy_name      =>'SAL_QUALITY_GATE_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_SALESPERSONS',
                          policy_name      =>'SAL_SALESPERSONS_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_SHOUTED_RAV',
                          policy_name      =>'SAL_SHOUTED_RAV_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_TARGETS_FF',
                          policy_name      =>'SAL_TARGETS_FF_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_TARGETS_FF_STM',
                          policy_name      =>'SAL_TARGETS_FF_STM_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_TARGETS_TS',
                          policy_name      =>'SAL_TARGETS_TS_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;
   

BEGIN
 dbms_fga.add_policy  (object_schema   =>'SALES_MI',
                          object_name      =>'SAL_TARGET_EXCEPTIONS',
                          policy_name      =>'SAL_TARGET_EXCEPTIONS_ADT',
                          audit_condition  => NULL,
                          audit_column     => NULL,
                          statement_types  => 'INSERT,UPDATE,DELETE'
      );
      
END;



SELECT * FROM dba_audit_policies; 

SELECT *
    FROM dba_fga_audit_trail
ORDER BY timestamp;

TRUNCATE TABLE sys.fga_log$;