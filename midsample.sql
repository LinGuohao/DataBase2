---5.Give the name and size of the Hash clusters whose owner is ¡¯NIKOVITS¡¯ (Cluster_name, Size)

select cluster_name ,bytes from dba_CLUSTERS c,dba_segments s where cluster_name = segment_name and c.owner = s.owner and 
c.owner = 'NIKOVITS' and cluster_type = 'HASH';

--6. (10 points)
--Write a PL/SQL function which returns in a character string the list of table names 
--(comma separated list in alphabetical order) of owner NIKOVITS, where the table has a NUMBER data type column,
--and the table has datablocks in two different datafiles.

CREATE OR REPLACE FUNCTION nt_tabs RETURN VARCHAR2 IS
 tablename varchar(200);
 n integer;
begin
    for i in (select distinct TABLE_NAME from all_tab_columns where owner = 'NIKOVITS' and data_type = 'NUMBER' order by table_name) loop
        select count(*) into n from (select segment_name,file_id from dba_extents where segment_name = i.table_name  group by segment_name,file_id);
        if(n=2) then
             tablename:= tablename || i.table_name||',';
        end if;
    end loop;
    return tablename;
end ;
/

SET SERVEROUTPUT ON
EXECUTE check_plsql('nt_tabs()');


--7. (10 points)
--Write a PL/SQL procedure which prints out the average blocking factor
--[(number of rows)/(number of non-empty blocks)] of table NIKOVITS.CUSTOMERS.
CREATE OR REPLACE PROCEDURE bl_factor IS
rownum integer;
blocknum integer;
begin
    select count(*) into rownum from NIKOVITS.CUSTOMERS;
    select count(*) into blocknum from (select DISTINCT dbms_rowid.rowid_block_number(ROWID) from nikovits.CUSTOMERS);
    dbms_output.put_line(to_char(round(rownum/blocknum))); 
end;
/
EXECUTE bl_factor;

select block_id from dba_extents where segment_name = 'CUSTOMERS' and owner = 'NIKOVITS';

select  dbms_rowid.rowid_block_number(ROWID) from nikovits.CUSTOMERS;




------------------------------------------------------------------------------------------------------
--5 Give the name and size of the BITMAP indexes whose owner is 'NIKOVITS' (Index_name, Size)
select distinct index_name, bytes from DBA_INDEXES i ,dba_segments s where i.owner = 'NIKOVITS' and index_type = 'BITMAP' and index_name = segment_name;

--6. (10 points)
--Write a PL/SQL function which returns in a character string the list of table names 
--(comma separated list in alphabetical order) of owner NIKOVITS, whose second last column has data type DATE.
CREATE OR REPLACE FUNCTION nt_tables RETURN VARCHAR2 IS
 res varchar(2000);
 colnum integer;
 dtype varchar2(200);
 tablename varchar2(200);
 begin
    for i in (select table_name from dba_tables where owner = 'NIKOVITS') loop
        select count(*) into colnum from dba_tab_columns where owner = 'NIKOVITS' and table_name = i.table_name;
        if(colnum-1 > 0) then
            select data_type ,table_name into dtype , tablename from dba_tab_columns where owner = 'NIKOVITS' and table_name = i.table_name and column_id = colnum - 1;
            if(dtype = 'DATE') then 
                res := res||tablename||',';
            end if;
        end if;
    end loop;
    return  substr(res,0,length(res)-2);
    
end;
/

SET SERVEROUTPUT ON
EXECUTE check_plsql('nt_tables()');
select nt_tables() from dual;


--7. (10 points)
--Write a PL/SQL procedure which prints out the data blocks of table NIKOVITS.CUSTOMERS
--in which the number of records is greater than 40. The output has 3 columns: File_id, Block_number
--and the number of records within that block. Columns are separeted by spaces.
CREATE OR REPLACE PROCEDURE gt_40 IS
begin
    for i in (select file_no, block_no , count(*) n from (select dbms_rowid.rowid_relative_fno(ROWID) file_no, dbms_rowid.rowid_block_number(ROWID) block_no  from NIKOVITS.CUSTOMERS) group by file_no, block_no having count(*) > 40) loop
        dbms_output.put_line(i.file_no||' '||i.block_no||' '||i.n);
    end loop;
end;
/

select dbms_rowid.rowid_block_number(ROWID) from NIKOVITS.CUSTOMERS;
EXECUTE check_plsql('gt_40');
EXECUTE gt_40;


