# MySQL差备与日志清理

差异备份需要开启mysql的二进制日志功能, mysql默认开启, 查看`/etc/my.cnf`配置文件, 在`[mysql]`块下是否存在`log-bin`字段. 

如果不存在, 添加如下行

```
log-bin=/var/lib/mysql/sql_bak
```

重启mysql服务生效.

我们可以通过如下方式查看

```
mysql> show master logs;
+----------------+-----------+
| Log_name       | File_size |
+----------------+-----------+
| sql_bak.000001 |       106 |
+----------------+-----------+
1 row in set (0.00 sec)

```

实际上每一行都是一个日志文件, 就在`log-bin`所指向的目录中, 如`/var/lib/mysql`.

```
[root@iZwz90idvmfkldrshita0vZ mysql]# ll
total 20500
-rw-rw---- 1 mysql mysql 10485760 Sep 27 15:06 ibdata1
-rw-rw---- 1 mysql mysql  5242880 Sep 27 15:08 ib_logfile0
-rw-rw---- 1 mysql mysql  5242880 Jun 17 11:22 ib_logfile1
drwx------ 2 mysql mysql     4096 Jun 17 11:22 mysql
srwxrwxrwx 1 mysql mysql        0 Sep 27 15:08 mysql.sock
-rw-rw---- 1 mysql mysql      106 Sep 27 15:08 sql_bak.000001
-rw-rw---- 1 mysql mysql       30 Sep 27 15:08 sql_bak.index
drwx------ 2 mysql mysql     4096 Jun 17 11:22 test
```

关于这个日志的清理, 可以直接在文件系统中用`rm`删除, 但更规范的操作是在mysql命令行下使用如下命令删除. 如

```
mysql> purge master logs to 'sql_bak.010';
```

删除指定日志文件**之前**的日志文件.