# kafka模型架构[Partition分区 Replica副本]

参考文章

1. [kafka partition分配_震惊了！原来这才是 Kafka！（多图+深入）](https://blog.csdn.net/weixin_42310891/article/details/112264408)
    - 全面
2. [「Kafka深度解析」快速入门](https://www.jianshu.com/p/da1222dd0d32)
    - kafka特性
    - kafka核心概念
3. [Java工程师的进阶之路 Kafka篇（一）](https://www.jianshu.com/p/cbf684893574)
    - 消息系统存在必要性: 解耦, 冗余, 扩展性, 灵活性&峰值处理能力, 可恢复性, 顺序保证, 缓冲, 异步通信
    - ~~名词概念的解释并不是很清晰~~
    - 设计思想(很不错)
    - 应用场景(不错)
    - Push 模式 vs Pull 模式(非常不错!)
4. [kafka partition（分区）与 group](https://www.cnblogs.com/liuwei6/p/6900686.html)
    - 对于传统的message queue而言, 一般会删除已经被消费的消息, 而Kafka集群会保留所有的消息, 无论其被消费与否. 
    - 当然, 因为磁盘限制, 不可能永久保留所有数据（实际上也没必要）, 因此Kafka提供两种策略删除旧数据. 一是基于时间, 二是基于Partition文件大小. 
    - Kafka读取特定消息的时间复杂度为O(1), 即与文件大小无关, 所以这里删除过期文件与提高Kafka性能无关. 选择怎样的删除策略只与磁盘以及具体的需求有关

## 基本架构

消息系统中按`topic`进行发布订阅是比较常见的解决方案, 这里不再解释`topic`的概念.

除了`topic`, kafka中还有`partition(分区)`, `replica(副本)`以及消费组等术语, 可见参考文章3...但是这些看一遍基本是没法看懂的(比如我).

### partition(分区)

首先`topic`逻辑对象为一个(有序)队列, 一般的场景就是, 生产者向队列尾部添加消息, 消费者从队列头获取消息.

如果单个`topic`的队列过长, 数据过多, 单个主机可能无法承受, 为了实现高可用及横向扩展能力, 会将`topic`数据进行**分区**. 

假设一个`topic`的全部内容为: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], 在一个3节点的kafka集群中, 可能会将些`topic`划分为3个分区, 每台主机拥有1个分区.

- topic0-partition0: [1, 3, 7, 10]
- topic0-partition1: [2, 5, 9, 12, 13]
- topic0-partition2: [4, 6, 8, 11]

这样, 一个kafka集群就可以容纳3倍于单台主机单个kafka实例的数据量, 实现了横向扩展.

### replica(副本)

上面只是实现了了横向扩展, 如果其中某个kafka实例所在主机异常宕机, 那么上面的分区就会丢失. 为了实现高可用, kafka可以为每个分区创建n个副本.

```


```



partition数量 最好与 broker 实例数量保持一致???

partition 拥有多个 replica 副本, 这些副本中可以包含 leader 和 follower.

消费到哪里(offset)是由consumer自己保存的???

