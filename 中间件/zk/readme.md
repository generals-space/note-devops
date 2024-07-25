参考文章

1. [面试官问：ZooKeeper是强一致的吗？怎么实现的？](https://juejin.cn/post/6919737776766189582)

## Zookeeper通过ZAB保证分布式事务的最终一致性。

ZAB全称Zookeeper Atomic Broadcast（ZAB，Zookeeper原子消息广播协议）

ZAB是一种专门为Zookeeper设计的一种支持 崩溃恢复 的 原子广播协议 ，是Zookeeper保证数据一致性的核心算法。ZAB借鉴了Paxos算法，但它不是通用的一致性算法，是特别为Zookeeper设计的。

基于ZAB协议，Zookeeper实现了⼀种主备模式的系统架构来保持集群中各副本之间的数据的⼀致性，表现形式就是使⽤⼀个单⼀的主进程（Leader服务器）来接收并处理客户端的所有事务请求（写请求），并采⽤ZAB的原⼦⼴播协议，将服务器数据的状态变更为事务 Proposal的形式⼴播到所有的Follower进程中。
