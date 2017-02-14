--The CREATE TABLE statement allows you to create and define a table.

--The basic syntax for a CREATE TABLE statement is:

    CREATE TABLE table_name
    ( column1 datatype null/not null,
      column2 datatype null/not null,
      ...
    );

--Each column must have a datatype. The column should either be defined as "null" or "not null" and if this value is left blank, the database assumes "null" as the default.

--For example:

    CREATE TABLE suppliers
    (     supplier_id     number(10)     not null,
          supplier_name     varchar2(50)     not null,
          contact_name     varchar2(50)     
    );             


--Practice Exercise #1:

--Create a customers table that stores customer ID, name, and address information. The customer ID should be the primary key for the table.

--Solution:

--The CREATE TABLE statement for the customers table is:

    CREATE TABLE customers
    (     customer_id     number(10)     not null,
          customer_name     varchar2(50)     not null,
          address     varchar2(50),     
          city     varchar2(50),     
          state     varchar2(25),     
          zip_code     varchar2(10),     
          CONSTRAINT customers_pk PRIMARY KEY (customer_id)
    );             


--Practice Exercise #2:

--Based on the departments table below, create an employees table that stores employee number, employee name, department, and salary information. The primary key for the employees table should be the employee number. Create a foreign key on the employees table that references the departments table based on the department_id field.

    CREATE TABLE departments
    (     department_id     number(10)     not null,
          department_name     varchar2(50)     not null,
          CONSTRAINT departments_pk PRIMARY KEY (department_id)
    );             

--Solution:

--The CREATE TABLE statement for the employees table is:

    CREATE TABLE employees
    (     employee_number     number(10)     not null,
          employee_name     varchar2(50)     not null,
          department_id     number(10),     
          salary     number(6),     
          CONSTRAINT employees_pk PRIMARY KEY (employee_number),
          CONSTRAINT fk_departments
            FOREIGN KEY (department_id)
            REFERENCES departments(department_id)
    );             