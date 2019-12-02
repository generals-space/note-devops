

```sql
create table tbl_array(id serial primary key, items varchar[]);
insert into tbl_array(items) values('{abc, def}');
INSERT 0 1
select * from tbl_array;
 id |     items     
----+---------------
  1 | {abc,def}
(1 rows)
select * from tbl_array where items @> '{abc}';
 id |     items     
----+---------------
  1 | {abc,def}
(1 rows)
```

```sql
select * from tbl_array where items @> '{abc}';
 id |     items     
----+---------------
  1 | {abc,def}
(1 rows)
update tbl_array set items = array_replace(items, '{abc}', '{cba}') where items @> '{abc}';
```

以上`replace`语句在9.5中执行正常, 但在9.2版本中会出问题. 可以简单测试一下.

`9.5`

```
 select array_replace(ARRAY['abc', 'def'], 'abc', '123');
 array_replace 
---------------
 {123,def}
(1 row)
```

`9.2`

```sql
select array_replace(ARRAY['abc', 'def'], 'abc', '123');
ERROR:  function array_replace(text[], unknown, unknown) does not exist
LINE 1: select array_replace(ARRAY['abc', 'def'], 'abc', '123');
               ^
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
```