create or replace function generater(n integer) return varchar is
    res  varchar(1000);
begin
    for i in 1..n loop
        res := res ||'*';
    end loop;
    return res;
end;
/
CREATE OR REPLACE PROCEDURE print_histogram(p_owner VARCHAR, p_table VARCHAR, p_col VARCHAR) IS
    v_sql varchar(300):='select '||p_col||', count(*) val , length('||p_col||') len from '||p_owner||'.'||p_table|| 
    ' where '||p_col||' is not null group by '||p_col||' order by '||p_col;
    v_max_len integer:=0;
    tmplen integer;
    tmpcol varchar(100);
    tmpval varchar(100);
    TYPE cursor_type IS REF CURSOR;
    c1 cursor_type; 
    numofcol integer :=0;
    toolong EXCEPTION;
    minval integer:=200;
    res varchar(1000);
BEGIN
    open c1 for v_sql ;  
    LOOP
        FETCH c1 INTO tmpcol,tmpval,tmplen;
        numofcol := numofcol + 1;
        if (tmplen > v_max_len) then
            v_max_len := tmplen;
        end if;
        
        if(tmpval < minval) then
            minval := tmpval;
        end if;
        EXIT WHEN c1%NOTFOUND;
  END LOOP;
  close c1;  
  if (numofcol > 100 or numofcol = 0) then
    raise toolong;
  end if;
    
    open c1 for v_sql ;  
    LOOP
        FETCH c1 INTO tmpcol,tmpval,tmplen;
        res := '';
        dbms_output.put(rpad(tmpcol, v_max_len)||' --> ');
        
        for i in 1..(tmpval/minval) loop
            res := res || '*';
        end loop;
        dbms_output.put_line(res);

        EXIT WHEN c1%NOTFOUND;
  END LOOP;
  close c1;  

EXCEPTION
    when toolong then
        dbms_output.put_line('Few or too many distinct values in column');
    when others then
        dbms_output.put_line('Non-existing table or column');
END;
/
set serveroutput on;
CALL print_histogram('nikovits','customers','cust_income_level');
CALL print_histogram('nikovits','calls_v','call_date');
CALL print_histogram('nikovits','customers','cust_year_of_birth');
alter session set nls_date_format='yyyy.mm.dd';
CALL print_histogram('nikovits','supply','sdate');

CALL print_histogram('nikovits','xxx','xxx');

CALL print_histogram('nikovits','test2','yr');



create table PLAN_TABLE (
        statement_id       varchar2(30),
        plan_id            number,
        timestamp          date,
        remarks            varchar2(4000),
        operation          varchar2(30),
        options            varchar2(255),
        object_node        varchar2(128),
        object_owner       varchar2(30),
        object_name        varchar2(30),
        object_alias       varchar2(65),
        object_instance    numeric,
        object_type        varchar2(30),
        optimizer          varchar2(255),
        search_columns     number,
        id                 numeric,
        parent_id          numeric,
        depth              numeric,
        position           numeric,
        cost               numeric,
        cardinality        numeric,
        bytes              numeric,
        other_tag          varchar2(255),
        partition_start    varchar2(255),
        partition_stop     varchar2(255),
        partition_id       numeric,
        other              long,
        distribution       varchar2(30),
        cpu_cost           numeric,
        io_cost            numeric,
        temp_space         numeric,
        access_predicates  varchar2(4000),
        filter_predicates  varchar2(4000),
        projection         varchar2(4000),
        time               numeric,
        qblock_name        varchar2(30),
        other_xml          clob
);



EXPLAIN PLAN SET statement_id='test2'
for
select  /*+ no_index(s) no_index(p) no_index(pj) use_merge(s p pj) */ sum(s.amount)amount from NIKOVITS.supply s , NIKOVITS.product p  , NIKOVITS.project pj 
                    where s.prod_id = p.prod_id and  s.proj_id =pj.proj_id and p.color = 'fekete' and pj.address = 'Szeged' ;
                
EXPLAIN PLAN SET statement_id='test1'
for
select  /*+ no_index(s) no_index(p) index(pj)  use_nl(p s pj) */ sum(s.amount)amount from NIKOVITS.supply s , NIKOVITS.product p  , NIKOVITS.project pj 
                    where s.prod_id = p.prod_id and  s.proj_id =pj.proj_id and p.color = 'fekete' and pj.address = 'Szeged' ;
                

SELECT LPAD(' ', 2*(level-1))||operation||' + '||options||' + '
  ||object_owner||nvl2(object_owner,'.','')||object_name xplan
FROM plan_table
START WITH id = 0 AND statement_id = 'test2'                 
CONNECT BY PRIOR id = parent_id AND statement_id = 'test2'   
ORDER SIBLINGS BY position;



