# Postgres系统表-pg_stat_activity

参考文章

1. [PostgreSQL系统表 pg_stat_activity](https://blog.csdn.net/luojinbai/article/details/44586917)

```sql
postgres=# select version();
                                                             version
----------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 11.1 (Debian 11.1-1.pgdg90+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 6.3.0-18+deb9u1) 6.3.0 20170516, 64-bit
(1 row)
```

使用`\d+ pg_stat_activity`可以查看`pg_stat_activity`的详细信息(不用选择任何数据库), 你会发现`pg_stat_activity`是一个视图. ta联合查询了`pg_stat_get_activity`表, 并根据`pg_database`和`pg_authid`表进行`join..on`进行过滤.

1. `pg_database`: 存储在postgres里面的所有的数据库名称.

2. `pg_authid`: 存储postgres的登录账号, 有一些系统用户.

> `pg_stat_activity`的官方解释: 每一行都表示一个系统进程，显示与当前会话的活动进程的一些信息，比如当前回话的状态和查询等。

## 1. 字段解释

- `datid`: `oid`类型, 

- `datname`: `name`类型(我擦, `name`也是种类型...???), 客户端连接入的数据库名(不管是使用程序还是psql都需要指定库名).

- `pid`: `integer`类型, 处理此连接的系统进程pid.

- `usename`: `name`类型, 客户端连接入使用的用户名.

- `application_name`: 建立连接的程序名称, psql连接的值为psql, 用程序连接的值貌似为空.

- `client_addr`: `inet`(IP)类型, 接入的客户地址(IP).

- `client_port`: `integer`类型, 发起连接的客户端所使用的端口.

- `backend_start`: `timestamp`类型, 当前进程的开始时间, 也即客户端建立连接的时间.

- `xact_start`: `timestamp`类型, 当前进程正在执行的, 事务的开始时间.

- `query_start`: `timestamp`类型, 当前执行sql的开始时间.

- `state`: `text`类型, 当前进程状态.

    - `active`：表示当前用户正在执行查询等操作.
    - `idle`：表示当前用户空闲。
    - `idle in transaction`:表示当前用户在事务中。
    - `idle in transaction (aborted)`： 表示当前用户在事务中，但是已经发生错误。
    - 
- `query`: `text`类型, 此连接正在执行的sql语句.

## 2. 应用技巧

...有了上面的理论基础, 那么查询某个数据库或是全部的连接数就不是问题了.

再来一个常用语句, 查询最大连接数

```sql
show max_connections;
```
