# Postgresql-Schema概念理解

参考文章

1. [postgresql中schema概念](http://www.codeweblog.com/postgresql%E4%B8%ADschema%E6%A6%82%E5%BF%B5/)

## 1. 概念理解

按照范围来看, database > schema > table > column, 可以说schema是库与表之间新增的一层.

schema有点像编程语言中命名空间的概念. 命名空间一般是由于项目工程庞大, 用来划分模块的. 不同命名空间的相同名称的类, 方法不会相互冲突, 并且可以通过指定命名空间的完整路径引用其他模块的方法. 

pg里的schema也差不多就是干这个用的, 同一个库内无法同时存在多个schema, 但是可以通`schema名.表名`的方式写SQL, 引用还是比较方便的. 也可以通过为不同的schema设置不同的权限完成更细粒度的控制.

> 比如要设计一个复杂系统.由众多模块构成,有时候模块间又需要有独立性.各模块存放单独的数据库显然是不合适的.

> 这时候使用schema来分类各模块间的对象,再对用户进行适当的权限控制.这样逻辑也非常清晰.

...当然, 没看太懂, 这种使用场景我还没想到实际可以用的.

下面来看看schema的增删改查等基本用法.

## 

`\dn`: 可查看**当前数据库**拥有的schema列表.

实验环境

```
postgres=# create database db_1;
CREATE DATABASE
postgres=# create user user_1 password '123456';
CREATE ROLE
postgres=# \c db_1
You are now connected to database "db_1" as user "postgres".
db_1=# \dn
  List of schemas
  Name  |  Owner   
--------+----------
 public | postgres
(1 row)

```

### 创建schema

```
db_1=# create schema schema_1;
CREATE SCHEMA
db_1=# \dn
   List of schemas
   Name   |  Owner   
----------+----------
 public   | postgres
 schema_1 | postgres
(2 rows)


```

### 在schema下创建表

```
db_1=# create table schema_1.table_1(id int);
CREATE TABLE
```

默认的搜索路径是`public`, 所以我们无法查看到创建在自定义`schema`空间下的表.

```
db_1=# \dt
No relations found.
```

但是我们可以通过指定`schema名.表名`进行操作.

```
db_1=# insert into schema_1.table_1 values(1);
INSERT 0 1
db_1=# select * from schema_1.table_1;
 id 
----
  1
(1 row)

```

### 删除schema

如果schema下有对象, 会删除失败, 如果需要一起删除,需要带上`cascade(级联)`关键字.有点像使用`rm -r`删除目录一样.

```
db_1=# drop schema schema_1;
ERROR:  cannot drop schema schema_1 because other objects depend on it
DETAIL:  table schema_1.table_1 depends on schema schema_1
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
db_1=# drop schema schema_1 cascade;
NOTICE:  drop cascades to table schema_1.table_1
DROP SCHEMA

```

### 创建指定属主的schema

默认谁创建的schema, owner就是谁, 当然也可以在创建时指定或是事后修改. 属主用户/角色需要事先存在.

```
db_1=# create schema schema_1 authorization user_1;
CREATE SCHEMA
db_1=# \dn
   List of schemas
   Name   |  Owner   
----------+----------
 public   | postgres
 schema_1 | user_1                      ## 拥有者为user_1
(2 rows)

```

在创建时不显式指定schema名称会以目标属主为名创建.

```
db_1=# create schema authorization user_1;
CREATE SCHEMA
db_1=# \dn
   List of schemas
   Name   |  Owner   
----------+----------
 public   | postgres
 schema_1 | user_1
 user_1   | user_1                      ## 与目标属主同名的schema
(3 rows)
```

不同用户的schema下的数据不能互通, 所以需要把schema修改为同一用户(在数据表导入时可能会用到), 同样可以使用`alter`命令完成这些操作, 通过`\h`命令查看详情.

### schema 的搜索路径(Search Path)

搜索路径, 有点类似于shell里的`pwd`, 也有点像python中的`sys.path`, 其实就是上下文的意思, 它是pg的一个内置变量. 

```
db_1=# show search_path;
  search_path   
----------------
 "$user",public
(1 row)
```

比如`\dt`默认显示的是名为`public`的schema下的表, 我们创建自定义的`schema`为`schema_1`并在其下创建了表`table_1`时, `\dt`是看不到它的.

使用`set search_path = schema_1`, 那么`\dt`就默认显示`schema_1`下的所有表了.

```sql
db_1=# create schema schema_1;
CREATE SCHEMA
db_1=# create table schema_1.table_1(id int);
CREATE TABLE
db_1=# \dt
No relations found.
db_1=# set search_path = 'schema_1';
SET
db_1=# \dt
           List of relations
  Schema  |  Name   | Type  |  Owner   
----------+---------+-------+----------
 schema_1 | table_1 | table | postgres
(1 row)
```

但这这样设置的搜索路径只是会话级别的, 下次使用`psql`重连时依然是默认的public, 而且应用程序在连接时也会报错说目标表不存在.

```
(psycopg2.ProgrammingError) relation "xxx" does not exist
```

解决办法是在当前库下执行如下命令

```sql
table_1=> alter user postgres set search_path = schema_1;
```