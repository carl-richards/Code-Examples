DECLARE

    d_ext_from      DATE;

   CURSOR get_hdrs(c_ext_date IN DATE)
   IS
      SELECT /*+ index(pam IDX_PAM_STRALTTRANSHDRNBR) */
            pah.stralttranshdrnbr
            ,pah.strpolnbr
            ,pah.strclientcd
            ,pah.dtalteff
            ,pah.dtaltentry
            ,(SELECT cs.strcddesc
              FROM   com_param_system_m cs
              WHERE  cs.iparamtypecd = 3001
                 AND cs.nparamcd = pam.nalttype)
                c_desc
            ,pam.nalttype
      FROM   ps_alt_map pam, ps_alt_hdr pah
      WHERE  pah.stralttranshdrnbr = pam.stralttranshdrnbr
         AND pah.dtalteff = c_ext_date
         AND pah.dtaltentry = (SELECT MAX(x.dtaltentry)
                               FROM   ps_alt_hdr x
                               WHERE  x.strpolnbr = pah.strpolnbr)
      ORDER BY pah.strpolnbr, pah.dtaltentry DESC;
      
BEGIN
    
    SELECT dtlogical 
    INTO   d_ext_from
    FROM   com_logical_date;

   FOR c1 IN get_hdrs(d_ext_from)
   LOOP
   
      BEGIN
      
         NULL;
         
      END;
      
   END LOOP;
   
END;