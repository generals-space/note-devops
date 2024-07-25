参考文章

1. [ZooKeeper 并不适合做注册中心](https://mp.weixin.qq.com/s?__biz=MzkwODMzOTY1NA==&mid=2247498727&idx=1&sn=dbdf1d6e670257a78e3f0feb57afb464)
    - 在 CAP 模型中，zookeeper 是 CP，意味着面对网络分区时，为了保持一致性，他是不可用的。
    - zookeeper 的核心算法是 Zab，所有设计都是为了一致性。
    - 作为分布式协调系统，CP这是非常正确的，但是对于服务发现，可用性是第一位的。
    - 注册中心的可用性比数据强一致性更加重要，所以注册中心应该是偏向 AP，而不是 CP。
    - zookeeper 既然这么多问题，他咋不改呢？
2. [走马观花云原生技术（4）：强一致性分布式存储etcd](https://cloud.tencent.com/developer/article/2168077)
    - etcd是CP实现，它保证一致性与分区容错性，一定程度上牺牲了可用性。
3. [Kubernetes 为什么选择ETCD做存储？](https://juejin.cn/post/7341669201010130981)
    - 为什么用 ETCD 作为存储
    - 为什么不用 Mysql 和 Postgres SQL 这种关系型数据库？
        - 因为 Kubernetes 不需要做复杂查询，它们致力于优化的方向并用不到。
    - 那既然 kv 存储的数据为什么Redis 不行？
        - Redis是一直高可用的存储，它更多保证的是最终一致性，但是在集群整体状态的一致性上它没办法做保证。
4. [为什么k8s选择etcd](https://devops.gitlab.cn/archives/28626)
    - Consul在服务发现和健康检查方面表现出色，但在一致性和可靠性方面略逊一筹。

CAP模型: Consistency(一致性), Availability(可用性), Partition Tolerance(分区容错性)

网络分区: 通俗点说就是因为 zookeeper 集群中的某个节点因为网络问题出现脑裂的情况...

## Zookeeper

核心算法是 zab

zk的每个节点都配置了`server.x`这种列表, 指向了集群中的所有节点, 底层可能有确保所有节点在线才能提供服务的限制.

尤其是发生脑裂的实例, 所在网络区域作为少数派, 无法选举成为leader, `zkCli.sh`终端都进不去.

## etcd 

基于 Raft 共识算法
