# dbsize查看集群中key的数量

参考文章

1. [Redis如何查看其Key数目（redis查看key数目）](https://www.dbs724.com/336157.html)

redis-cli info | grep keys

redis-cli dbsize

上面两种的输出是一样的.

需要注意的是, 如果是 cluster 类型, 每个 node 上的 key 数量是不相同的, 整个集群的 key 数量需要汇总所有 master 节点中的 key 数量.
