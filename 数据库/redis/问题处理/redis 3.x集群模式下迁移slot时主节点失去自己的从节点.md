# redis 3.x集群模式下迁移slot时主节点失去自己的从节点

参考文章

1. [[Cluster inconsistency] slave migrates when all slots moved to new master but doesn't migrate back](https://github.com/redis/redis/issues/3043)
    - 完全一致

redis: 3.2.6

## 问题描述

3主3从的 cluster 集群, 拓扑大概如下

1. A(主) -> A1(从) slot: 0-5460
2. B(主) -> B1(从) slot: 5461-10922
3. C(主) -> C1(从) slot: 10923-16383

在一次迁移操作中, 将主节点B上的 slot **全部**转移到节点A. 

完成之后通过`cluster nodes`发现, 主节点B的`replicates`为0, 就是说ta没有从节点了. 而`A`拥有两个从节点, 多了一个`B1`...

查看从节点`B1`的日志, 有如下输出.

```
## 检测到配置发生了变化
24:S 24 Feb 19:10:00.714 # Configuration change detected. Reconfiguring myself as a replica of c168a573d5aa2c90526cf82d1e8d66ed424a728a
24:S 24 Feb 19:10:00.714 # Connection with master lost.
24:S 24 Feb 19:10:00.714 * Caching the disconnected master state.
24:S 24 Feb 19:10:00.714 * Discarding previously cached master state.
## 新建连接到了主节点 A
24:S 24 Feb 19:10:01.114 * Connecting to MASTER 172.22.253.118:6379
24:S 24 Feb 19:10:01.114 * MASTER<->SLAVE sync started
24:S 24 Feb 19:10:01.114 * Nonblocking connect for SYNC fired the event.
24:S 24 Feb 19:10:01.115 * Master replied to PING, replication can continue...
24:S 24 Feb 19:10:01.115 * Partial resync hronization not possible(no cached master)
24:S 24 Feb 19:10:01.116 * Full resync from master: 31348b440079409799468d0009b6e59fa582f4f5:14421
24:S 24 Feb 19:10:01.215 * MASTER<->SLAVE sync: receiving 76  bytes from master
24:S 24 Feb 19:10:01.215 * MASTER<->SLAVE sync: Flushing old data
24:S 24 Feb 19:10:01.215 * MASTER<->SLAVE sync: Loading DB in memory
24:S 24 Feb 19:10:01.215 * MASTER<->SLAVE sync: Finished with success
```

------

按照参考文章1所说, 算是 redis 3.x 的一个bug, 因为主节点B没有slot了, 那么从节点也就没有必要追随ta...

不过答主提出的两个解决文案我都还没看懂, 目前只能手动在转移之前备份一个主从关系, 转移之后恢复一下...

答主之后还说已经修复了这个问题, 但是没有说版本号, 所以我也不知道具体是哪个版本不会出这个问题. 我试验了一下, 版本 5.0.8 也出现了这个问题...
