参考文章

1. [mysql查看当前实时连接数](https://www.cnblogs.com/jimmyshan-study/p/11013662.html)
2. [总结MySQL修改最大连接数的两个方式](https://www.cnblogs.com/justuntil/p/8809249.html)
    - 可以通过命令行修改, 也可以通过配置文件修改.

`SHOW VARIABLES LIKE '%max_connections%';`: 查看当前最大连接数设置
`SHOW STATUS LIKE '%Connection%';`: 查看当前连接汇总状况

```
## SHOW FULL PROCESSLIST; 好像和`SHOW PROCESSLIST`差不多, 没什么区别.
mysql> SHOW PROCESSLIST;
+-----+------+-------------------------------------------------------------+---------------+---------+------+----------+------------------+
| Id  | User | Host                                                        | db            | Command | Time | State    | Info             |
+-----+------+-------------------------------------------------------------+---------------+---------+------+----------+------------------+
|   6 | root | 172-22-0-230.java-grpc.sdwan.svc.cluster.local:42134        | sdwan_grpc    | Sleep   | 2092 |          | NULL             |
|   7 | root | 172-22-0-232.jhipster-gateway.sdwan.svc.cluster.local:35204 | sdwan_gateway | Sleep   | 2092 |          | NULL             |
```

User: 表示连接时的认证用户
Host: 连接的来源地址
db: 正在使用的数据库

```
mysql> show status like 'Threads%';
+-------------------+-------+  
| Variable_name     | Value |  
+-------------------+-------+  
| Threads_cached    | 58    |  
| Threads_connected | 57    |   ###   
| Threads_created   | 3676  |  
| Threads_running   | 4     |   ###   
+-------------------+-------+  

```

`Threads_connected`: 这个数值指的是打开的连接数, 但会有很多连接处于空闲休眠的状态.
`Threads_running`: 这个数值指的是激活的连接数, 这个数值一般远低于connected数值.

`Threads_connected` 跟 `show processlist`结果相同, 表示当前连接数. 准确的来说, `Threads_running`是代表当前并发数.
