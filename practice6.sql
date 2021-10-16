-- 3.Give the index organized tables of user NIKOVITS. (table_name)

SELECT table_name FROM dba_tables WHERE owner='NIKOVITS' AND iot_type = 'IOT';

--Find the table_name, index_name and overflow name (if exists) of the above tables. (table_name, index_name, overflow_name)
SELECT index_name FROM dba_indexes where table_name like 'CIKK%' and  owner = 'NIKOVITS';
---find the overflow
SELECT table_name, iot_name, iot_type FROM dba_tables 
WHERE owner='NIKOVITS' AND iot_type = 'IOT_OVERFLOW';

select * from dba_tables;


--Give the names and sizes (in bytes) of the partitions of table NIKOVITS.ELADASOK (name, size)

SELECT * FROM dba_part_tables WHERE owner='NIKOVITS' AND table_name='ELADASOK';
SELECT * FROM dba_tab_partitions WHERE table_owner='NIKOVITS' AND table_name='ELADASOK';

SELECT partition_name, segment_type, bytes FROM dba_segments 
WHERE owner='NIKOVITS' AND segment_name = 'ELADASOK' AND segment_type LIKE 'TABLE%';


--5 Which is the biggest partitioned table (in bytes) in the database? (owner, name, size)
--It can have subpartitions as well.
select owner , segment_name  , sum(bytes) from dba_segments where  segment_type like '%PARTITION' group by owner , segment_name order by sum(bytes) desc FETCH FIRST 1 rows ONLY;

SELECT owner, segment_name, sum(bytes) 
FROM dba_segments WHERE segment_type LIKE 'TABLE%PARTITION'
GROUP BY owner, segment_name ORDER BY sum(bytes) DESC
FETCH FIRST 1 ROWS ONLY;


-- 6.Give a cluster whose cluster key consists of 3 columns. (owner, name) A cluster can have more than two tables on it!!!

SELECT owner, cluster_name FROM dba_clu_columns GROUP BY owner, cluster_name 
HAVING count(DISTINCT clu_column_name) = 3;

--7.List the clusters which use NOT THE DEFAULT hash function. (owner, name)
--(So the creator defined a hash expression.)

SELECT * FROM dba_cluster_hash_expressions;

--8.Write a PL/SQL procedure which prints out the storage type (heap organized, partitioned, index organized or clustered) 
--for the parameter table.
CREATE OR REPLACE PROCEDURE print_type(p_owner VARCHAR2, p_table VARCHAR2) IS
    v_str VARCHAR2(2000);
    clu_name varchar2(200);
    par varchar2(20);
    IOT varchar2(20);
begin
    v_str := 'select cluster_name, partitioned, iot_type  from  dba_tables WHERE owner=''' || p_owner ||'''
        AND table_name =''' || p_table||''''; 
    EXECUTE IMMEDIATE v_str  into clu_name,par,IOT;
    if IOT is null and par = 'NO' and clu_name is null then
        dbms_output.put_line('heap organized');
    elsif IOT IS NOT NULL THEN
        dbms_output.put_line('index organized');
    elsif par = 'YES' then 
        dbms_output.put_line('partitioned');
    elsif clu_name is not null then
        dbms_output.put_line('clustered');
    end if;
    
end;
/
SET SERVEROUTPUT ON
execute print_type('NIKOVITS', 'EMP');

execute print_type('NIKOVITS', 'ELADASOK5');

execute print_type('NIKOVITS', 'EMP_CLT');

execute print_type('NIKOVITS', 'CIKK_IOT');
 