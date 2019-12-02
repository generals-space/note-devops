# Postgres系统函数

最简单的, `version()`, 看看使用方法.

```sql
postgres=# select version();
                                                             version
----------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 11.1 (Debian 11.1-1.pgdg90+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 6.3.0-18+deb9u1) 6.3.0 20170516, 64-bit
(1 row)
```

`pg_backend_pid()`: 得到当前连接(可以是psql连接, 也可以是程序建立的连接)相关的`pid`, 可以使用此`pid`值查询`pg_stag_activity`表.

`pg_terminate_backend(pid)`: 接受一个连接处理进程的pid值, 强制kill. 注意常规应用中`select pg_terminate_backend(pid) from (select pid from pg_stat_activity where datname = 'kanjula') as a;`中的用法, 可以批量杀死多个连接进程.
