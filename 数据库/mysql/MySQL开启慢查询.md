# MySQL开启慢查询

## 1. 

根据网上的资料, 开启慢查询有两种方式:

(1) /etc/my.cnf的[mysqld]段中添加
```
log-slow-queries=mysql_slow.log #日志路径, 可以是绝对路径
long_query_time=3 #慢查询的最小时间, 超过这个时间的操作将被记录
```
(2) 在mysql命令行中设置系统变量;

使用第一种方式时, 重启mysql无法成功启动, 不确定时mysql的版本问题还是选项名称问题(把破折号'-'改成下划线'_'依然不行); 所以本文使用的是第二种;

## 2. 查看是否已经开启慢查询

MySQL版本为: Version: 5.6.26 (MySQL Community Server (GPL))

```sql
mysql> show variables like '%query%';
+------------------------------+-----------------------------------+
| Variable_name                | Value                             |
+------------------------------+-----------------------------------+
| binlog_rows_query_log_events | OFF                               |
| ft_query_expansion_limit     | 20                                |
| have_query_cache             | YES                               |
| long_query_time              | 10.000000                         |
| query_alloc_block_size       | 8192                              |
| query_cache_limit            | 1048576                           |
| query_cache_min_res_unit     | 4096                              |
| query_cache_size             | 1048576                           |
| query_cache_type             | OFF                               |
| query_cache_wlock_invalidate | OFF                               |
| query_prealloc_size          | 8192                              |
| slow_query_log               | OFF                               |
| slow_query_log_file          | /var/lib/mysql/localhost-slow.log |
+------------------------------+-----------------------------------+
13 rows in set (0.00 sec)
```

`slow_query_log = OFF`则说明未开启.

## 3. 开启慢查询

```sql
set global log_slow_queries = on;                               # 开启慢日志
set [session|global]  long_query_time = 3.0               # 设置慢查询最短时间, 可精确到毫秒
```

暂时无法设置日志位置, 报错如下:

```sql
mysql> set global slow_query_log_file = /var/log/mysql_slow.log;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '/var/log/mysql_slow.log' at line 1
```

PS: 这种方式开启慢查询后无需重启, 可直接在`slow_query_log_file`路径下看到慢查询日志文件生成.


## 3. 日志清理

```
show master logs;
PURGE MASTER LOGS TO 'mysql-bin.010';
```