# es集群状态为yellow-Unassigned Replica

参考文章

1. [磁盘空间引起ES集群shard unassigned的处理过程](https://www.jianshu.com/p/443cf6ce87d5)
    - 查找原因的过程
    - cluster allocation explain接口的使用
2. [Indices stuck after recovery from backup](https://discuss.elastic.co/t/indices-stuck-after-recovery-from-backup/189843/6)
    - explain 接口的`primary`参数设置为`false`
3. [如何在Elasticsearch中解析未分配的分片（unassigned shards）](https://www.cnblogs.com/yfb918/p/10475083.html)
    - Elasticsearch中解析未分配的各个原因解析
        - 1. 故意分配碎片分配
        - 2. 分片太多, 节点不够
        - 3. 加入一个新的节点, 需要重新启用分片分配
        - 4. 集群中不在存在分片数据
        - 5. 节点磁盘空间不足
4. [ES 官方文档 Cluster Allocation Explain API](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/cluster-allocation-explain.html)

## 场景描述

在做实验的时候, 发现es集群的状态一直为 yellow 

![](https://gitee.com/generals-space/gitimg/raw/master/6038842ed1dd06c083aed878d2ca5c69.png)

点击`Indices`进去发现索引全都是 yellow, 然后选择一个 nginx-log 的索引, 底部出现`Unassigned Replica`

![](https://gitee.com/generals-space/gitimg/raw/master/ab75ee6b8bbe832f6e0114f220057eb3.png)

此时我的集群配置是 master * 3 + data * 1.

```json
GET /_cat/indices/nginx-log-2020.09.16?format=json&pretty
```

```json
[
  {
    "health": "yellow",
    "status": "open",
    "index": "nginx-log-2020.09.16",
    "uuid": "J69-9Ne3Tqu7lHcr4BJXpw",
    "pri": "5",
    "rep": "1",
    "docs.count": "10",
    "docs.deleted": "0",
    "store.size": "101.4kb",
    "pri.store.size": "101.4kb"
  }
]
```

其中`pri`字段表示 primary 主分片的数量, 这与上图中底部深绿色`Primary`的数量相符.

## 问题分析

按照参考文章1中提到的 explain 接口的使用方法, 在 dev tools 中做如下请求

```json
GET /_cluster/allocation/explain
{
    "index": "nginx-log-2020.09.16",
    "shard": 0,
    "primary": true
}
```

得到的响应如下

```json
{
  "index": "nginx-log-2020.09.16",
  "shard": 0,
  "primary": true,
  "current_state": "started",
  "current_node": {
    "id": "yXG397hOQsSPHj4deXD3Qw",
    "name": "esc-data-0",
    "transport_address": "172.20.0.4:9300",
    "attributes": {
      "ml.enabled": "true"
    },
    "weight_ranking": 1
  },
  "can_remain_on_current_node": "yes",
  "can_rebalance_cluster": "no",
  "can_rebalance_cluster_decisions": [
    {
      "decider": "rebalance_only_when_active",
      "decision": "NO",
      "explanation": "rebalancing is not allowed until all replicas in the cluster are active"
    },
    {
      "decider": "cluster_rebalance",
      "decision": "NO",
      "explanation": "the cluster has unassigned shards and cluster setting [cluster.routing.allocation.allow_rebalance] is set to [indices_all_active]"
    }
  ],
  "can_rebalance_to_other_node": "no",
  "rebalance_explanation": "rebalancing is not allowed"
}
```

我本来是按照上面的`explanation`来寻找解决方法的, 但是偶然找到了参考文章2, 人家说想看一下`explain`请求时, `primary`设置为`false`, 即想看副本而不是主分片的情况. 于是我又重新请求了一次.

```json
GET /_cluster/allocation/explain
{
    "index": "nginx-log-2020.09.16",
    "shard": 0,
    "primary": false
}
```

响应如下

```json
{
  "index": "nginx-log-2020.09.16",
  "shard": 0,
  "primary": false,
  "current_state": "unassigned",
  "unassigned_info": {
    "reason": "CLUSTER_RECOVERED",
    "at": "2020-10-05T03:01:05.929Z",
    "last_allocation_status": "no_attempt"
  },
  "can_allocate": "no",
  "allocate_explanation": "cannot allocate because allocation is not permitted to any of the nodes",
  "node_allocation_decisions": [
    {
      "node_id": "yXG397hOQsSPHj4deXD3Qw",
      "node_name": "esc-data-0",
      "transport_address": "172.20.0.2:9300",
      "node_attributes": {
        "ml.enabled": "true"
      },
      "node_decision": "no",
      "deciders": [
        {
          "decider": "same_shard",
          "decision": "NO",
          "explanation": "the shard cannot be allocated to the same node on which a copy of the shard already exists [[nginx-log-2020.09.16][0], node[yXG397hOQsSPHj4deXD3Qw], [P], s[STARTED], a[id=1u0_jvoUTJW9YyjSZwWy0g]]"
        }
      ]
    }
  ]
}
```

看起来是分片副本不能和主分片存储在同一个节点上, 由此我找到了参考文章3, 在这篇文章中提到"主节点不会将主分片分配给与其副本相同的节点，也不会将同一分片的两个副本分配给同一节点。如果没有足够的节点来相应地分配分片，则分片可能会停留在未分配状态。".

这个问题有两个解决方法, 一个是增加节点数量, 一个是减少分片的副本数量, 这里先尝试第2种.

## 修改索引的副本值

首先查看一下当前的副本数量(其实上面图中也已经有了, 每个分片都有一个副本备份)

```
GET /nginx-log-2020.09.16/_settings
```

响应如下

```json
{
  "nginx-log-2020.09.16": {
    "settings": {
      "index": {
        "creation_date": "1601458128656",
        "number_of_shards": "5",
        "number_of_replicas": "1",
        "uuid": "J69-9Ne3Tqu7lHcr4BJXpw",
        "version": {
          "created": "5050099"
        },
        "provided_name": "nginx-log-2020.09.16"
      }
    }
  }
}
```

现在将副本数量修改为0.

```json
PUT /nginx-log-2020.09.16/_settings
{
  "number_of_replicas": 0
}
```

得到如下响应

```json
{
  "acknowledged": true
}
```

现在这个索引的健康状态变为了 green.

![](https://gitee.com/generals-space/gitimg/raw/master/406c711ac07bb8a719f9d1ae571c0fc3.png)

但这只是一个索引...还有好多个索引都还是 yellow 状态呢.

![](https://gitee.com/generals-space/gitimg/raw/master/3ad2cfa85975b9b57f46b41f6d784dbe.png)

接下来尝试第1种方法 - 增加 data 节点.

## 增加 data 节点.

这个就比较简单了, 就是等的时间有点长.

![](https://gitee.com/generals-space/gitimg/raw/master/14366b426ce9116982ea0d981c06e968.png)

------

解决!
