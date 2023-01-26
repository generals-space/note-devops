# reroute重新分配分片[shard]

参考文章

1. [elasticsearch多磁盘扩容](https://blog.csdn.net/illbehere/article/details/78202973)
    - 负载过高可能会导致个别分片长期处于`UNASSIGNED`状态
2. [Cluster Reroute](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/cluster-reroute.html)

```
POST _cluster/reroute?retry_failed=true
```
