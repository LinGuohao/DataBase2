--1.Give the names and sizes of the database data files (*.dbf). (file_name, size_in_bytes)
SELECT file_name, bytes size_in_bytes FROM dba_data_files where file_name like '%.dbf';

 
--2.Give the names of the tablespaces in the database. (tablespace_name)
SELECT tablespace_name FROM dba_tablespaces;

 
--3.Which datafile belongs to which tablespace? List them. (filename, tablespace_name)
select file_name,tablespace_name from DBA_DATA_FILES;

--4.Is there a tablespace that doesn't have any datafile in dba_data_files? -> see dba_temp_files
SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name NOT IN
(SELECT tablespace_name FROM dba_data_files);
SELECT file_name, tablespace_name FROM dba_temp_files;

--5. What is the datablock size in USERS tablespace? (block_size)
select BLOCK_SIZE from dba_tablespaces where TABLESPACE_NAME = 'USERS' ;

--6.Find some segments whose owner is NIKOVITS. What segment types do they have? List the types. (segment_type)
-- dba_segments 表 查看某个数据库对象（TABLE, INDEX ....）所占得物理存储空间
select distinct segment_type from dba_segments where owner='NIKOVITS';
select * from dba_segments;

--7.How many extents are there in file 'users02.dbf' ? (num_extents)
--How many bytes do they occupy? (sum_bytes)
select count(*) num_extents , sum(e.bytes) sum_bytes   from dba_data_files f , dba_extents e where FILE_NAME like '%/users02%' and f.FILE_ID = e.FILE_ID;

--8.How many free extents are there in file 'users02.dbf', and what is the summarized size of them ? (num, sum_bytes)
select count(*) num , sum(fs.bytes) sum_bytes from dba_free_space fs , dba_data_files f where f.file_name like '%users02.dbf' and fs.file_id = f.file_id;
-- How many percentage of file 'users02.dbf' is full (allocated to some object)?
select sum(e.bytes)/(sum(f.bytes)/count(f.bytes)) * 100 from dba_extents e , dba_data_files f 
where  f.file_name like '%users02.dbf' and f.file_id = e.file_id group by f.file_id ;

--9.Who is the owner whose objects occupy the most space in the database? (owner, sum_bytes)
select * from (select owner , sum(bytes) sum_bytes from dba_segments group by OWNER order by sum_bytes desc) where rownum = 1;

select owner,sum(bytes) from dba_segments 
group by owner 
order by sum(bytes) desc FETCH FIRST 1 ROWS ONLY;

select * from dba_segments;


--10.Is there a table of owner NIKOVITS that has extents in at least two different datafiles? (table_name)



select SEGMENT_NAME table_name from dba_extents where  OWNER = 'NIKOVITS' and SEGMENT_TYPE = 'TABLE' group by segment_name HAVING count(*) >=2;
---- Select one from the above tables (e.g. tabla_123) and give the occupied space by files. (filename, bytes)
-- Dont know 
select * from dba_segments where  segment_name = 'TABLA_123';

--11.On which tablespace is the table ORAUSER.dolgozo?
select TABLESPACE_NAME from dba_segments where owner = 'ORAUSER' and segment_name = 'DOLGOZO' ;
--On which tablespace is the table NIKOVITS.eladasok? Why NULL (Dont know)? 
select TABLESPACE_NAME from dba_segments where owner = 'NIKOVITS' and segment_name = 'ELADASOK' and segment_type = 'TABLE' ;
--12
SELECT * FROM (select * from DBA_OBJECTS where OBJECT_TYPE = 'TABLE' AND OWNER = 'NIKOVITS' ORDER BY created DESC) WHERE ROWNUM = 1;

SET SERVEROUTPUT ON;

execute check_plsql('newest_table(''NIKOVITS'')','IW3XV9');



----------------------------------------------------------------------------------------------
--dba_extents 表存放extents数据 file id 能够判断项目是否相等
select * from dba_extents;





SELECT file_name filename, d1.tablespace_name  FROM dba_tablespaces d1, dba_data_files d2
 where d1.tablespace_name = d2.tablespace_name;
 
select tablespace_name from dba_tablespaces
minus
select tablespace_name from dba_data_files;

 

select block_size from dba_tablespaces where tablespace_name = 'USERS';

 

SELECT distinct segment_type FROM dba_segments WHERE owner='NIKOVITS'; 






















--DB LINK
CREATE DATABASE LINK aramisdb CONNECT TO iw3xv9 IDENTIFIED BY iw3xv9       -- your username/password
USING 'aramis.inf.elte.hu:1521/aramis';

drop DATABASE LINK aramisdb;
SELECT r.rname, c.cname, c.tld, r.countries 
FROM NIKOVITS.countries_v@aramisdb c, NIKOVITS.rivers_v r
WHERE r.rname = 'Mekong' AND r.countries LIKE '%'||c.tld||'%';












