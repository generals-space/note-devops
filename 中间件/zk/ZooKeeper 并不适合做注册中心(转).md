# ZooKeeper 并不适合做注册中心

## zookeeper 的 CP 模型不适合注册中心

zookeeper 是一个非常优秀的项目，非常成熟，被大量的团队使用，但对于服务发现来讲，zookeeper 真的是一个错误的方案。

在 CAP 模型中，zookeeper 是 CP，意味着面对网络分区时，为了保持一致性，他是不可用的。

> general: "网络分区"通俗点说就是因为 zookeeper 集群中的某个节点因为网络问题出现脑裂的情况.

因为 zookeeper 是一个分布式协调系统，如果使用最终一致性（AP）的话，将是一个糟糕的设计，他的核心算法是 Zab，所有设计都是为了一致性。

对于协调系统，这是非常正确的，但是对于服务发现，可用性是第一位的，例如发生了短暂的网络分区时，即使拿到的信息是有瑕疵的、旧的，也好过完全不可用。

zookeeper 为协调服务所做的一致性保障，用在服务发现场景是错误的。

注册中心本质上的功能就是一个查询函数：

```java
ServiceList = F(service-name)
```

以 service-name 为查询参数，得到对应的可用的服务端点列表 endpoints(ip:port)。

我们假设不同的客户端得到的服务列表数据是不一致的，看看有什么后果。

![](https://gitee.com/generals-space/gitimg/raw/master/2024/5ba062682cd12ae4a2d7434b4c8a59a4.webp)

一个 serviceB 部署了 10 个实例，都注册到了注册中心。

现在有 2 个服务调用者 service1 和 service2，从注册中心获取 serviceB 的服务列表，但取得的数据不一致。

```ini
s1 = { ip1,ip2 ... ip9 }
s2 = { ip2,ip3 ... ip10 }
```

这个不一致带来的影响是什么？

就是**serviceB 各个实例的流量不均衡**。

![](https://gitee.com/generals-space/gitimg/raw/master/2024/9826e733613742a60b533d981df51d20.webp)

ip1 和 ip10 的流量是单份的，ip2-ip9 流量是双份的。

这个不均衡有什么严重影响吗？并没有，完全可以接受，而且，又不会一直这样。

所以，注册中心使用最终一致性模型（AP）完全可以的。

------

现在我们看一下 CP 带来的不可用的影响。

![](https://gitee.com/generals-space/gitimg/raw/master/2024/8be2a1129a0f457aea6d9b0fd3b1ade9.webp)

3个机房部署 5 个 ZK 节点。

现在机房3出现网络分区了，形成了孤岛。

发生网络分区时，各个区都会开始选举 leader，那么节点数少的那个分区将会停止运行，也就是 ZK5 不可用了。

这时，serviceA 就访问不了机房1和机房2的 serviceB 了，而且连自己所在机房的 serviceB 也访问不了了。

不能访问其他机房还可以理解，不能访问自己机房的服务就理解不了了，本机房内部的网络好好的，不能因为你注册中心有问题就不能访问了吧。

因为注册中心为了保障数据一致性而放弃了可用性，导致同机房服务之间无法调用，这个是接受不了的。

所以，注册中心的可用性比数据强一致性更加重要，所以注册中心应该是偏向 AP，而不是 CP。

以上表述的是 zookeeper 的 CP 模型并不适合注册中心的需求场景。

> general: zk的每个节点都配置了`server.x`这种列表, 指向了集群中的所有节点, 底层可能有确保所有节点在线才能提供服务的限制.
>
> 尤其是发生脑裂的实例, 所在网络区域作为少数派, 无法选举成为leader, `zkCli.sh`终端都进不去.

## zookeeper 的性能不适合注册中心

在大规模服务集群场景中，zookeeper 的性能也是瓶颈。

zookeeper 所有的写操作都是 leader 处理的，在大规模服务注册写请求时，压力巨大，而且 leader 是单点，无法水平扩展。

还有所有服务于 zookeeper 的长连接也是很重的负担。

zookeeper 对每一个写请求，都会写一个事务日志，同时会定期将内存数据镜像dump到磁盘，保持数据一致性和持久性。

这个动作会降低性能，而且对于注册中心来讲，是不需要的。

## 小结

从 CP 模型上来讲，zookeeper 并不适合注册中心高可用的需要。

从性能上来讲，zookeeper 也无法满足注册中心大规模且频繁注册写的场景。

你可能会问，zookeeper 既然这么多问题，他咋不改呢？

其实，这并不算是 zookeeper 的问题，是人家本来就不适合做注册中心，非要用他的话，肯定一堆问题。

zookeeper 的特长是做分布式协调服务，例如 kafka、hbase、flink、hadoop 等大项目都在用 zookeeper，用的挺好的，因为是用对了地方。

例如可以看下：[kafka 中 zookeeper 具体是做什么的？](https://mp.weixin.qq.com/s?__biz=MzkwODMzOTY1NA==&mid=2247498719&idx=1&sn=0fc0a82f831c2b15a6aa3082c15bf1a7)

你有什么看法，欢迎留言交流。

参考资料：

http://jm.taobao.org/2018/06/13/%E5%81%9A%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0%EF%BC%9F/

https://medium.com/knerd/eureka-why-you-shouldnt-use-zookeeper-for-service-discovery-4932c5c7e764
