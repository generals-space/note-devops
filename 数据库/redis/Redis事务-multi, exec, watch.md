# Redis事务-multi, exec, watch

参考文章

1. [Redis 事务](http://www.runoob.com/redis/redis-transactions.html)

redis事务相关的指令: `multi`, `exec`, `watch(unwatch)`.

Redis 事务可以一次执行多个命令, 并且带有以下几个重要的保证: 

批量操作在发送 EXEC 命令前被放入队列缓存. 

收到 EXEC 命令后进入事务执行, 事务中任意命令执行失败, 其余的命令依然被执行. 

在事务执行过程, 其他客户端提交的命令请求不会插入到事务执行命令序列中. 

一个事务从开始到执行会经历以下三个阶段: 

1. 开始事务. 
2. 命令入队. 
3. 执行事务. 

## 1. multi与exec

`multi`是事务的开始, 之后就可以输入一系列的指令操作了, `exec`则可以正式执行这些操作.

示例如下

```
redis 127.0.0.1:6379> MULTI
OK
redis 127.0.0.1:6379> INCR user_id
QUEUED
redis 127.0.0.1:6379> INCR user_id
QUEUED
redis 127.0.0.1:6379> INCR user_id
QUEUED
redis 127.0.0.1:6379> PING
QUEUED
redis 127.0.0.1:6379> EXEC
1) (integer) 1
2) (integer) 2
3) (integer) 3
4) PONG
```

## 2. 关于watch

`watch`的使用方法十分简单, 无非就是`watch/unwatch 键名1 [键名2 键名3...]`

不过重要的是`watch`监视的key只会影响事务的执行进程.

**如果在事务执行之前被监视的这个(或这些)key被其他命令所改动, 那么事务将被打断.**

### 2.1 监视key, 且事务成功执行

```
redis 127.0.0.1:6379> WATCH lock lock_times
OK
redis 127.0.0.1:6379> MULTI
OK
redis 127.0.0.1:6379> SET lock "huangz"
QUEUED
redis 127.0.0.1:6379> INCR lock_times
QUEUED
redis 127.0.0.1:6379> EXEC
1) OK
2) (integer) 1
```

### 2.2 监视key, 且事务被打断

```
redis 127.0.0.1:6379> WATCH lock lock_times
OK
redis 127.0.0.1:6379> MULTI
OK
redis 127.0.0.1:6379> SET lock "joe"        # 就在这时, 另一个客户端修改了lock_times的值
QUEUED
redis 127.0.0.1:6379> INCR lock_times
QUEUED
redis 127.0.0.1:6379> EXEC                  # 因为lock_times键被修改, joe的事务执行失败
(nil)
```