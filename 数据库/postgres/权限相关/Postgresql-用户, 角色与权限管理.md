# Postgresql-用户, 角色与权限管理

参考文章

1. [PostgreSQL学习笔记(九) 用户、角色、权限管理](http://www.jianshu.com/p/b09d0b29faa9)

2. [PostgreSQL 用户和权限管理](http://blog.csdn.net/italyfiori/article/details/43966109)

pg通过`用户`与`角色`两个概念完成权限控制. `角色`相当于`用户组`的概念. 比如我们可以设置`admin`与`user`2个角色, 用户有a, b, c 3个人. 其中a是`admin`, b与c只是普通的`user`, 这样就实现了部分的权限控制.

## 1. 用户与角色基本操作

在`psql`命令行中可以使用如下命令.

```sql
create user 用户名;    ## 创建用户
drop user 用户名;      ## 删除用户

create role 角色名;    ## 创建角色
drop role 角色名;      ## 删除角色
```

对应的, pg在shell命令行里提供了能实现相同功能的`createuser`与`dropuser`命令, 很可惜, 没有`createrole`与`droprole`命令.

> 操作多个角色/用户时, 用逗号隔开

我们可以先创建一个角色A和一个用户a, 然后把A角色赋给a, 于是a就可以拥有A所表示的权限.

```sql
grant 角色名 to 用户名;       ## 为用户添加角色权限
revoke 角色名 from 用户名;    ## 从用户中移除指定角色所表示的权限.
```

```sql
postgres=# create role role_general;
CREATE ROLE
postgres=# create user user_general;            ## mmp, 创建用户结果也显示创建的是角色
CREATE ROLE
postgres=# grant role_general to user_general;
GRANT ROLE
```

在psql命令行中使用`\du`快捷命令可以查看当前数据库存在的所有角色. 默认只有一个作用`Superuser`的`postgres`角色.

```
postgres=# \du
                             List of roles
 Role name |                   Attributes                   | Member of 
-----------+------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication | {}
 role_general | Cannot login                                   | {}
 user_general |                                                | {role_general}

```

...`role_general`与`user_general`都在??? 0.0

因为role与user本质上是同一种对象, 唯一的区别是, 角色对象role没有登录权限. 不信你把一个用户a当成一个角色赋给另一个用户b?

另外, role与user是多对多关系, 一个用户可以拥有多个角色.

## 2. 角色属性

假设我们创建了普通用户角色`test_user`, 我们需要为这个角色赋予一些指定权限. 这种权限分为两种.

一种是类似于登录, 增删角色/用户/数据库这种的系统级别权限.

一种是针对普通数据库的对象的操作权限, 如增删表, 只允许查询, 不允许删除这种粒度的权限.

### 2.1 系统级属性

第一种权限可用列表, 可用`\h create user;`命令查询, 如下

```sql
postgres=# \h create user;
Command:     CREATE USER
Description: define a new database role
Syntax:
CREATE USER name [ [ WITH ] option [ ... ] ]

where option can be:

      SUPERUSER | NOSUPERUSER
    | CREATEDB | NOCREATEDB
    | CREATEROLE | NOCREATEROLE
    | CREATEUSER | NOCREATEUSER
    | INHERIT | NOINHERIT
    | LOGIN | NOLOGIN
    | REPLICATION | NOREPLICATION
    ...省略的应该不算了, 剩下的是指定sysid和密码的
```

赋权操作包括在创建角色时指定, 也可以在后期追加或修改.


#### 2.1.1 创建时指定

```
CREATE ROLE 角色名 WITH 可选权限;
CREATE USER 用户名 WITH 可选权限;
```

示例

```
postgres=# create user user_1 with superuser password '123456';
CREATE ROLE
```

#### 2.1.2 后期修改

```
alter role 角色名/用户名 with 目标权限属性列表
```

目标权限列表不同属性用空格分隔.

示例

```
alter role user_1 with nologin createdb;
ALTER ROLE
```

> 需要注意的是, 这些属性是**成对存在**的, 如果一个角色/用户拥有了`superuser`属性, 当你想要移除它时, 就需要`alter...with nosuperuser`. 否则, 目标权限属性列表中的值总会与原有值**合并**. 如下

```
postgres=# \du
                                   List of roles
  Role name   |                   Attributes                   |     Member of      
--------------+------------------------------------------------+--------------------
 postgres     | Superuser, Create role, Create DB, Replication | {}
 user_1       | Superuser, Create DB, Cannot login             | {}
```

`superuser`属性在alter语句执行后一直存在.

### 2.2 数据级属性

简单来说, 就是指定用户到某数据库的完全控制, 只读, 只写等权限. 同样是用`grant`语句, 其语法为

```sql
GRANT   权限类型 ON [database 库名 | table 表名] TO   角色名/用户名;
REVOKE  权限类型 ON [database 库名 | table 表名] FROM 角色名/用户名;
```

`\h grant`可以查看所有可用的权限类型.

示例:

```
postgres=# create database db_1;
CREATE DATABASE
postgres=# create user user_1 password '123456';
CREATE ROLE
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 db_1      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)
```

赋予用户`user_1`操作库`db_1`的所有权限, 可以通过`\l`的`Access privileges`字段确认.

```
postgres=# grant all on database db_1 to user_1;
GRANT
```

## 总结

`\du`: 可以查看所有已存在的用户/角色, 以及它们拥有的权限属性

`\l`: 可以查看所有数据库及其属主和所有拥有权限的用户配置

选择一个数据库后, `\dt`可以查看所有表的属主和相应用户权限

`select * from information_schema.role_table_grants where grantee = '用户名';` 可以查看指定用户拥有的所有数据库权限
