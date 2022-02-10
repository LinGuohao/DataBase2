select cluster_name ,bytes from dba_CLUSTERS c,dba_segments s where cluster_name = segment_name and c.owner = s.owner and 
c.owner = 'NIKOVITS' and cluster_type = 'HASH';



-------6
CREATE OR REPLACE FUNCTION nt_tabs RETURN varchar2 IS
 tablename varchar(200);
 n integer;
 tmp integer;
 nt integer :=0;
begin
    for i in (select distinct segment_name from dba_extents where owner = 'NIKOVITS' and segment_type = 'TABLE' order by segment_name) loop
        select count(*) into tmp from dba_tab_columns where owner = 'NIKOVITS' and table_name = i.segment_name and data_type = 'NUMBER';   
        if(tmp > 0) then
             select count(*) into n from (select distinct file_id from dba_extents where  owner = 'NIKOVITS' and segment_type = 'TABLE' and segment_name = i.segment_name);
             if(n =2) then
                tablename := tablename || i.segment_name||',';
             end if;
        end if;
    end loop;
    return substr(tablename,0,length(tablename)-1);
end ;
/

select * from dba_tab_columns;
set serveroutput on
EXECUTE check_plsql('nt_tabs()');
SELECT nt_tabs() from dual;
select file_id from dba_extents;

select nt_tabs() from dual;
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


CREATE OR REPLACE PROCEDURE equal_35 IS
begin
    for i in (select file_no, block_no , count(*) n from (select dbms_rowid.rowid_relative_fno(ROWID) file_no, dbms_rowid.rowid_block_number(ROWID) block_no  from NIKOVITS.CUSTOMERS) group by file_no, block_no having count(*) = 35 order by block_no) loop
        dbms_output.put_line(i.file_no||';'||i.block_no||';'||i.n||';');
    end loop;
end;
/
EXECUTE check_plsql('equal_35()');
execute equal_35();

select * from dba_tab_columns;