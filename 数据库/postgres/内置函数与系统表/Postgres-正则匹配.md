# Postgres-正则匹配

参考文章

1. [PostgreSQL 判断字符串包含的几种方法](https://blog.csdn.net/luojinbai/article/details/45461837)

语法: `'目标字符串' ~ '正则模式'`, 返回值为布尔类型.

如下

```sql
skycmdb=# select 'abcd' ~ '^ab';
 ?column?
----------
 t
(1 row)

skycmdb=# select 'abcd' ~ '^ab$';
 ?column?
----------
 f
(1 row)

skycmdb=# select 'ab' ~ '^ab$';
 ?column?
----------
 t
(1 row)
```

同`like`关键字一样, 也可以用在`where`子句中. 如下两句sql作用相同.

```sql
skycmdb=# select count(id) from domain where integral_domain ~ '51mrp.com';
 count
-------
   238
(1 row)

skycmdb=# select count(id) from domain where integral_domain like '%51mrp.com%';
 count
-------
   238
(1 row)
skycmdb=#
```