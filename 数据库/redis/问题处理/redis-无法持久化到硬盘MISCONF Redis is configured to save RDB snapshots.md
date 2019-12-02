# redis-无法持久化到硬盘MISCONF Redis is configured to save RDB snapshots

参考文件

1. [强制关闭Redis快照导致不能持久化](http://www.cnblogs.com/anny-1980/p/4582674.html)

## 问题描述

Redis被配置为保存数据库快照, 但它目前不能持久化到硬盘. 用来修改集合数据的命令不能用. 请查看Redis日志的详细错误信息. 

```
(error) MISCONF Redis is configured to save RDB snapshots, but is currently not able to persist on disk. Commands that may modify the data set are disabled. Please check Redis logs for details about the error.
```

## 原因分析

强制关闭Redis快照导致不能持久化. 

## 解决方法

`redis-cli`下运行`config set stop-writes-on-bgsave-error no`命令后, 关闭配置文件中`stop-writes-on-bgsave-error`项解决该问题. 

```
$ /usr/local/redis/src/redis-cli
127.0.0.1:6379> config set stop-writes-on-bgsave-error no
OK
127.0.0.1:6379> lpush myColour "red"
(integer) 1
```
