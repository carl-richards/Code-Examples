--Global temporary tables are distinct within SQL sessions.

--The basic syntax is:

    CREATE GLOBAL TEMPORARY TABLE table_name ( ...);


--For example:

    CREATE GLOBAL TEMPORARY TABLE supplier
    (     supplier_id     numeric(10)     not null,
        supplier_name     varchar2(50)     not null,
        contact_name     varchar2(50)     
    )             

--This would create a global temporary table called supplier .