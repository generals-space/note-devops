参考文章

1. [ZooKeeper 并不适合做注册中心](https://mp.weixin.qq.com/s?__biz=MzkwODMzOTY1NA==&mid=2247498727&idx=1&sn=dbdf1d6e670257a78e3f0feb57afb464)
    - 在 CAP 模型中，zookeeper 是 CP，意味着面对网络分区时，为了保持一致性，他是不可用的。
    - zookeeper 的核心算法是 Zab，所有设计都是为了一致性。
    - 作为分布式协调系统，CP这是非常正确的，但是对于服务发现，可用性是第一位的。
    - 注册中心的可用性比数据强一致性更加重要，所以注册中心应该是偏向 AP，而不是 CP。
    - zookeeper 既然这么多问题，他咋不改呢？
2. [走马观花云原生技术（4）：强一致性分布式存储etcd](https://cloud.tencent.com/developer/article/2168077)
    - etcd是CP实现，它保证一致性与分区容错性，一定程度上牺牲了可用性。

CAP模型: Consistency(一致性), Availability(可用性), Partition Tolerance(分区容错性)

网络分区: 通俗点说就是因为 zookeeper 集群中的某个节点因为网络问题出现脑裂的情况...

## Zookeeper

核心算法是 zab

zk的每个节点都配置了`server.x`这种列表, 指向了集群中的所有节点, 底层可能有确保所有节点在线才能提供服务的限制.

尤其是发生脑裂的实例, 所在网络区域作为少数派, 无法选举成为leader, `zkCli.sh`终端都进不去.

## etcd 

基于 Raft 共识算法
