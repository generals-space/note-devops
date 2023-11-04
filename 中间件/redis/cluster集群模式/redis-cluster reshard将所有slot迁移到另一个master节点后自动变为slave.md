# redis-cluster reshard将所有slot迁移到另一个master节点后自动变为slave

参考文章

1. [[Cluster inconsistency] slave migrates when all slots moved to new master but doesn't migrate back](https://github.com/redis/redis/issues/3043)
    - v3.2 版本首次出现
2. [[Cluster inconsistency] Master enslaves to another master sometimes, if all slots moved away](https://github.com/redis/redis/issues/3083)
3. [Redis cluster rebalance fails when trying to shard away from large number of nodes](https://github.com/redis/redis/issues/4592)
4. [Add cluster-allow-replica-migration option.](https://github.com/redis/redis/pull/5285)
    - 解决方案
5. [redis.conf 7.0 配置和原理全解，生产王者必备](https://cloud.tencent.com/developer/article/2205116)
    - `cluster-allow-replica-migration no`禁用自动迁移功能

redis: v6.2.12

## 问题描述

`reshard`指令, 将某个 master 节点上的 slot 转移到另一个 master 节点.

```
redis-cli --cluster reshard %s:%d --cluster-from %s --cluster-to %s --cluster-slots %d --cluster-yes --cluster-timeout 1500 --cluster-pipeline 100 --cluster-replace
```

- `--cluster-from`: 源 master 的 nodeId
- `--cluster-to`: 目标 master 的 nodeId
- `--cluster-slots`: 要迁移的数量

当`--cluster-slots`为源 master 上所有的 slot 总量时(即要将源 master 上所有的 slot 转移到目标 master), 迁移完成后, 源 master 会变成目标 master 节点的 slave 节点, 而且原本源 master 的 slave 节点也会成员目标 master 的 slave 节点...

在某些场景下, 这会让情形变得很麻烦.

比如原本为三主三从, 现在需要扩容成五主五从, 本来打算先把所有 slot 先集中到0节点(如果原本0节点是从节点, 则要先进行主从切换, 变成主节点), 然后用 rebalance 再把 slot 平分为5份. 

这会简化很多操作, 如果手动扩容则要计算每个节点向新增的两个 master 节点一点一点迁移, 如果只保证 slot 数量上的平均还好说, 但是这样的话各节点上的 slot 会变得不连续, 后续在维护时 slot 分布会变得越来越散乱.

但是如果 reshard 到0节点后主从关系随之迁移的话还要再手动梳理一遍...

## 解决方案

该问题首次出现在 v3.2 版本, 解决方法要修改配置文件中的`cluster-allow-replica-migration`字段, 默认为`yes`, 修改为为`no`禁用自动迁移功能.

注意: 该配置需要在集群中所有节点都进行修改.
