
参考文章

1. [redis cluster 学习 实战篇(二)](https://cloud.tencent.com/developer/article/1418503)
2. [[BUG?] redis-cli reshard error in 6.2.4 when cluster-allow-replica-migration is yes](https://github.com/redis/redis/issues/9223)
    - 6.2.4 版本 reshard 命令存在 bug
3. [Fix redis-cli --cluster reshard may report "ERR Please use SETSLOT only with masters"](https://github.com/redis/redis/pull/9239)
4. [Fix redis-cli CLUSTER SETSLOT race conditions](https://github.com/redis/redis/pull/10381)

`redis-cli`的`--cluster`选项应该是旧版本`redis-trib.rb`工具的集成版.

###

```
redis-cli [-a 密码] --cluster del-node host:port nodeid
```

也可以从集群中移除节点, 而且只需要执行一次, 不需要在每个节点上执行.

不过这条命令只是将节点从集群中移除, 集群是不再认识这个节点了, 但这个节点还是记得原集群的, 进入这个节点执行 cluster nodes 还能看到原本的集群拓扑, 如果要使用 add-node 将该节点再加入集群, 则需要将该节点上的集群信息清空, 可以用 cluster reset 完成.

如果目标节点为 slave, 可以直接删除, 如果是 master 则其中不能含有 slot 信息, 否则会移除失败.

而且, 如果是 master 节点被删除后, 属于ta的 slave 仍然会被保留, 只不过ta的 master 信息会变为空.

###

```
redis-cli [-a 密码] --cluster add-node newhost:port oldhost:port
```

> 注意 newhost 与 oldhost 的参数顺序

> oldhost 是集群中的某个节点IP

新加入集群的节点默认是 master 类型.

### 

使用 add-node 添加新节点后, 并没有分配 slot, 如果想要将其他 master 节点上的 slot 平均分到所有 master 上, 可以使用如下命令.

```
redis-cli [-a 密码] --cluster rebalance host:port --cluster-use-empty-masters
```

如果是出于某种原因导致集群中

###

redis-cli [-a 密码] --cluster reshard host:port 

在实际测试中(5主1从), 由于多次操作, 不同master上的 slot 虽然数量是平均划分的, 但很分散(分成很多段), 于是尝试将所有 slot 先汇集到1个节点上, 再用 rebalance 平均划分.

但是使用 reshard 将 16384 个 slot 划分到1个节点上时, 最终会得到如下错误.

```
ERR Please use SETSLOT only with masters
```

