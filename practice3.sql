--1
--How many data blocks are allocated in the database for the table NIKOVITS.CIKK?
--There can be empty blocks, but we count them too.
--The same question: how many data blocks does the segment of the table have?

select blocks from dba_segments
where owner='NIKOVITS' and segment_name='CIKK'
and segment_type='TABLE';

-- 2.
--How many filled data blocks does the previous table have?
--Filled means that the block is not empty (there is at least one row in it).
--This question is not the same as the previous !!!
--How many empty data blocks does the table have?

--dbms_rowid.rowid_block_number(rowid) 获取该行数据所在的块no
select distinct dbms_rowid.rowid_block_number(ROWID) from nikovits.cikk;
--
select ALLBOCKS - freeblocks from (select BLOCKS ALLBOCKS  from dba_segments where segment_name = 'CIKK' and owner ='NIKOVITS'),(select  count (distinct dbms_rowid.rowid_block_number(ROWID)) freeblocks from nikovits.cikk);

select BLOCKS from dba_segments where segment_name = 'CIKK' and owner ='NIKOVITS';

-- 3.How many rows are there in each block of the previous table?
SELECT dbms_rowid.rowid_block_number(ROWID) block_no,count(*)
FROM nikovits.cikk group by dbms_rowid.rowid_block_number(ROWID);

--4 There is a table NIKOVITS.ELADASOK which has the following row:
--- szla_szam = 100 (szla_szam is a column name)
--- In which datafile is the given row stored?
--- Within the datafile in which block? (block number) 
--- In which data object? (Give the name of the segment.)

select dbms_rowid.rowid_relative_fno(ROWID) file_id,dbms_rowid.rowid_block_number(ROWID) block_no 
,dbms_rowid.rowid_object(ROWID) data_object from NIKOVITS.ELADASOK where szla_szam = 100;

SELECT * FROM dba_data_files WHERE file_id=7;           
SELECT * FROM dba_objects WHERE data_object_id=86049;

SELECT dbms_rowid.rowid_relative_fno(e.ROWID) file_id, f.file_name 
FROM nikovits.eladasok e, dba_data_files f
WHERE szla_szam = 100 AND dbms_rowid.rowid_relative_fno(e.ROWID)=f.file_id;

--5
--Write a PL/SQL procedure which prints out the number of rows in each data block for the 
--following table: NIKOVITS.TABLA_123. The output has 3 columns: file_id, block_id, num_of_rows.

CREATE OR REPLACE PROCEDURE num_of_rows IS
    n integer;
begin
    for i in (select distinct dbms_rowid.rowid_block_number(ROWID) bn from NIKOVITS.TABLA_123) loop
            select count(*) into n from (select dbms_rowid.rowid_block_number(ROWID) blocknum from NIKOVITS.TABLA_123 ) where blocknum = i.bn;
            dbms_output.put_line(i.bn||','||to_char(n));
    end loop;
end;
/

SET SERVEROUTPUT ON
execute num_of_rows();

--6 Write a PL/SQL procedure which counts and prints the number of empty blocks of a table.
CREATE OR REPLACE PROCEDURE empty_blocks(p_owner VARCHAR2, p_table VARCHAR2) IS
    n integer;
    allblock integer;
    res integer;
    v_str VARCHAR2(2000);
begin 

      v_str:= 'select count(distinct dbms_rowid.rowid_block_number(ROWID)) from '||p_owner||'.'||p_table ;
        EXECUTE IMMEDIATE v_str into n ;
       select blocks into allblock from dba_segments 
            where owner= p_owner and segment_name= p_table and segment_type='TABLE';
        
            select (allblock - n) into res from dual;
        dbms_output.put_line(to_char(res));
end;
/
SET SERVEROUTPUT ON
execute empty_blocks('NIKOVITS', 'EMPLOYEES');
----------------------------------------------------------------------------------------------
select count(distinct dbms_rowid.rowid_block_number(ROWID)) from NIKOVITS.EMPLOYEES;

declare 
    r varchar(10) := 'dual';
    t VARCHAR2(2000) := 'select * from'||r;
begin
    EXECUTE IMMEDIATE t ;
end;
/


