-- practice 1


select owner from DBA_OBJECTS
where object_name='DBA_TABLES' and object_type='VIEW';


select owner from DBA_OBJECTS
where object_name='DUAL' and object_type='TABLE';


select owner from DBA_OBJECTS
where object_name='DBA_TABLES' and object_type='SYNONYM';


select distinct object_type from DBA_OBJECTS
where owner='ORAUSER';


select distinct object_type from DBA_OBJECTS
order by object_type;


select owner from DBA_OBJECTS
group by owner having count(distinct object_type) > 10;


select owner from DBA_OBJECTS
where object_type ='TRIGGER' 
INTERSECT
SELECT OWNER FROM DBA_OBJECTS 
WHERE object_type='VIEW';


select owner from DBA_OBJECTS
where object_type ='VIEW' 
minus
SELECT OWNER FROM DBA_OBJECTS 
WHERE object_type='TRIGGER';


select owner from DBA_OBJECTS
where object_type ='TABLE'
group by owner having count(*) > 40 
INTERSECT
select owner from DBA_OBJECTS
where object_type='INDEX'
group by owner having count(*) < 30;


select distinct data_object_id from DBA_OBJECTS
where object_type='TABLE'
minus
select distinct data_object_id from DBA_OBJECTS
where object_type='VIEW';


select object_type from DBA_OBJECTS
where data_object_id is null;


select object_type from DBA_OBJECTS
where data_object_id is not null;


select object_type from DBA_OBJECTS
where data_object_id is null
intersect
select object_type from DBA_OBJECTS
where data_object_id is not null;


select count(*) as num from DBA_TAB_COLUMNS
where owner='NIKOVITS' and TABLE_NAME ='EMP';


select data_type from DBA_TAB_COLUMNS
where owner='NIKOVITS' and table_name='EMP' and  column_id=6;


select owner, table_name from DBA_TAB_COLUMNS
where column_name like 'Z%';


select owner, table_name from (DBA_TAB_COLUMNS)
where data_type='DATE'
group by owner, table_name having count(*) >7;


select owner, table_name from (DBA_TAB_COLUMNS)
where data_type ='VARCHAR2' and column_id=4
intersect
select owner, table_name from (DBA_TAB_COLUMNS)
where data_type ='VARCHAR2' and column_id=2;


create or replace PROCEDURE table_print(p_char VARCHAR2) is
  CURSOR curs1 IS 
  select owner, table_name from dba_tables
  where upper(table_name) like upper(p_char)||'%';
  rec curs1%ROWTYPE;
BEGIN
  OPEN curs1;
  LOOP
    FETCH curs1 INTO rec;
    EXIT WHEN curs1%NOTFOUND;
    dbms_output.put_line(rec.owner||' - '||rec.table_name);
  END LOOP;
  CLOSE curs1;
END;
/


set serveroutput on
execute table_print('V');


