-- 1. Give the tables (table_name) which has a column indexed in descending order.
select distinct table_name from  dba_ind_columns where descend = 'DESC'  ;
--See the name of the column. Why is it so strange? -> DBA_IND_EXPRESSIONS
select * from  dba_ind_columns where descend = 'DESC'  ;
select * from DBA_IND_EXPRESSIONS where index_name = 'EMP2' and index_owner = 'NIKOVITS';
--2. Give the indexes (index name) which are composite and have at least 9 columns (expressions).
select index_owner,index_name from dba_ind_columns group by index_owner,index_name having count(*) >= 9;

select * from dba_ind_columns where index_owner = 'SYS' and  index_name = 'I_OBJ2';

--3. Give the name of bitmap indexes on table NIKOVITS.CUSTOMERS.
select index_name from dba_indexes where owner = 'NIKOVITS' and table_name = 'CUSTOMERS' 
and index_type = 'BITMAP';


--4.Give the indexes which has at least 2 columns and are function-based.
select distinct index_type from dba_indexes;
select i.index_name from dba_indexes i , dba_ind_columns ic where i.INDEX_NAME = ic.INDEX_NAME and i.owner = 'NIKOVITS' and i.index_type like 'FUNCTION-BASED%'
group by i.index_name having count(*)>2 ;

select * from dba_ind_expressions;

--5.Give for one of the above indexes the expression for which the index was created.
SELECT * FROM dba_ind_expressions WHERE index_owner='NIKOVITS' and index_name = 'EMP2';

--Write a PL/SQL procedure which prints out the names and sizes (in bytes) of indexes created
--on the parameter table. Indexes should be in alphabetical order, and the format of the 
--output should be like this: (number of spaces doesn't count between the columns)
--CUSTOMERS_YOB_BIX:   196608

--CREATE OR REPLACE PROCEDURE list_indexes(p_owner VARCHAR2, p_table VARCHAR2) IS

select * from  dba_ind_expressions ;
select INDEX_NAME from dba_indexes where owner = 'NIKOVITS' and table_name = 'CUSTOMERS';
select * from dba_objects where object_type = 'INDEX' and  owner = 'NIKOVITS' ;

select * from dba_objects  where object_type = 'INDEX' and  object_name like 'CUSTOMERS%' ;

SELECT * FROM dba_segments where segment_name like 'CUSTOMERS%' and  owner = 'NIKOVITS' ;


CREATE OR REPLACE PROCEDURE list_indexes(p_owner VARCHAR2, p_table VARCHAR2) IS
    v_str VARCHAR2(2000);
    v_str2 VARCHAR2(2000);
    type type_array is table of varchar(200) index by binary_integer;
    indexarray type_array;
    tmpbytes integer;
begin
        v_str:= 'select INDEX_NAME from dba_indexes where owner = '''||p_owner||''' and table_name = '''||p_table||'''' ;

        EXECUTE IMMEDIATE v_str bulk collect into indexarray;
        for i in 1..indexarray.count loop
            v_str2 := 'SELECT bytes FROM dba_segments where segment_name ='''||indexarray(i)||'''and  owner ='''|| p_owner||'''';
            EXECUTE IMMEDIATE v_str2  into tmpbytes;
            dbms_output.put_line(indexarray(i)||':'||to_char(tmpbytes));  
        end loop;
end;
/

SET SERVEROUTPUT ON
EXECUTE list_indexes('NIKOVITS', 'CUSTOMERS');
EXECUTE check_plsql('list_indexes(''NIKOVITS'',''CUSTOMERS'')');



------------------------------------------------------------------------
--Write a PL/SQL procedure which gets a file_id and block_id as a parameter and prints out the database
--object to which this datablock is allocated. (owner, object_name, object_type).
--If the specified datablock is not allocated to any object, the procedure should print out 'Free block'.

--CREATE OR REPLACE PROCEDURE block_usage(p_fileid NUMBER, p_blockid NUMBER) IS

select * from dba_objects;
select * from dba_segments;
select * from dba_extents;

CREATE OR REPLACE PROCEDURE block_usage(p_fileid NUMBER, p_blockid NUMBER) IS
    v_str VARCHAR2(2000);
    o varchar2(50);
    n varchar2(50);
    t varchar2(50);
begin
    v_str:= 'select OWNER,SEGMENT_NAME,SEGMENT_TYPE FROM dba_extents where file_id='|| p_fileid||'and BLOCK_ID = '||p_blockid;
    EXECUTE IMMEDIATE v_str into o,n,t;
    dbms_output.put_line(o||n||t);
EXCEPTION
    when others Then
        dbms_output.put_line('Free block');
end;
/
SET SERVEROUTPUT ON
EXECUTE block_usage(2, 615);




   
    


