# es集群脑裂的处理与避免

参考文章

1. [Non-failed nodes do not form a quorum – Elasticsearch Error How To Solve Related Issues](https://opster.com/es-errors/non-failed-nodes-do-not-form-a-quorum/)
    - ES 日志中报这种错误可能的几种情况: 
        1. 索引分片设置得太少; 索引字段太多(类似于redis的 bigkey)
        2. Master node not discovered; 脑裂
2. [ES 7.2.0 Master fails to join cluster](https://discuss.elastic.co/t/es-7-2-0-master-fails-to-join-cluster/191605)
3. [Bootstrapping a cluster](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-bootstrap-cluster.html#modules-discovery-bootstrap-cluster-joining)
    - 7.x 多节点集群需要配置`cluster.initial_master_nodes`
4. [Elasticsearch之集群脑裂](https://www.cnblogs.com/zlslch/p/6477312.html)
    - 7.x
5. [ElasticSearch集群脑裂现象](https://www.cnblogs.com/linlf03/p/13337872.html)
    - `discovery.zen.minimum_master_nodes = (N/2 + 1)`, `N`为集群内 master 节点的数量, 半数以上节点同意选举, 节点方可能成为master
    - 7.x 已经移除`discovery.zen.minimum_master_nodes`配置

ES: 7.5.1

ES集群节点几乎全部宕机, 某些集群出现了脑裂现象.

## ES 的防脑裂机制

参考文章4, 5 介绍了避免 ES 脑裂情况出现的配置方法. 

7.x 以前, 可以通过`discovery.zen.minimum_master_nodes = (N/2 + 1)`指定半数以上 master 节点同意选举, 节点方可能成为 master 主节点. `N`并不代表所有的ES节点数, 而是 master 类型的节点数.

7.x 时, 防止脑裂的机制交由 ES 自身管理, `discovery.zen.minimum_master_nodes`属性已经被移除. 

但是我的场景就是 7.x 的集群

参考文章2提到, 7.x 集群要避免脑裂现象, 需要配置`cluster.initial_master_nodes`, 但是我已经配置了.

足以见得 ES 的防脑裂机制并不完善...

## 场景描述

master * 3 + data * 1, (其中 master 也拥有 data 角色), master-0 与 data-0 的 local cluster uuid 一致, 所以着手将 master-1/2 的节点停掉, 然后把数据删了(节点毁了一半, 几乎没法修复了, 这里只是做的试验).

但是发现最终 master-1/2 并没有加入到 master-0 的集群里, 而是自行组成了双节点的集群...这下好了, 各占一半.

访问 master-0 中节点的 api 时, 会报如下错误

```
{
    "error" : {
        "root_cause" : [
            {
                "type" : "master_not_discovered_exception",
                "reason" : null
            }
        ],
        "type" : "master_not_discovered_exception",
        "reason" : null
    },
    "status" : 503
}
```

没救了

## 总结

修复脑裂集群目前总结了2点:

1. 在各节点日志中, 查找`local cluster uuid`的 hash 值, 相同的表示处于同一集群. 确认多数节点, 停止其余节点, 删除数据后重新启动, 让这些节点重新加入到占多数的集群里.
2. 在停止少数节点时, 优先操作 master 类型的节点, 因为 master 不存储数据, 重启时也会很快.

但就像上面的场景一样, master-0 和 data-0 属于同一集群, master-1/2 各自独立, 结果重建后这俩组成集群了, master-0 反而一直无法访问.

所以我觉得同时应该确保多数节点的集群中, 存在一个可访问的 master 才行...
