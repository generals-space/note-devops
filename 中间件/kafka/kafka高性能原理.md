# kafka高性能原理

参考文章

1. [Kafka如何实现高吞吐量 低延迟](https://blog.csdn.net/weixin_39034379/article/details/107176101)
2. [Kafka学习之路 （二）Kafka的架构](https://www.cnblogs.com/qingyunzong/p/9004593.html#_label1)
    - Push 模式 vs Pull 模式(非常不错!)
        - push模式的目标是尽可能以最快速度传递消息，但是这样很容易造成Consumer来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。
        - pull模式则可以根据Consumer的消费能力以适当的速率消费消息。
3. [kafka是如何实现高吞吐量和高性能的](https://segmentfault.com/a/1190000044200307)
    - 磁盘顺序读写，保证了消息的堆积
    - 页缓存(page cache)
    - 零拷贝
    - 分区分段 + 索引
    - 批量压缩：多条消息一起压缩，降低带宽
    - 批量读写
4. [kafka高吞吐、低延时、高性能的实现原理](https://blog.csdn.net/u014494148/article/details/134882943)

为了使得Kafka的吞吐率可以线性提高，物理上把Topic分成一个或多个Partition，**每个Partition在物理上对应一个文件夹**，该文件夹下存储这个Partition的所有消息和索引文件。

创建一个topic时，同时可以指定分区数目，分区数越多，其吞吐量也越大，但是需要的资源也越多，同时也会导致更高的不可用性.

kafka在接收到生产者发送的消息之后，会根据均衡策略将消息存储到**不同的分区**中。因为每条消息都被append到该Partition中，属于顺序写磁盘，因此效率非常高（经验证，顺序写磁盘效率比随机写内存还要高，这是Kafka高吞吐率的一个很重要的保证）。

## 顺序读写

顺序读写要求数据为单文件, 通过游标定位, kafka某个分片的目录下文件列表如下

```log
[root@kafka-test-1 test-topic-0]# 1l -h
total 1.2G
-rw-r--r-- 1 kafka kafka 912K Jul 22 10:41 00000000001020831084.index
-rw-r--r-- 1 kafka kafka 1.0G Jul 22 10:41 00000000001020831084.1og
-rw-r--r-- 1 kafka kafka  62K Jul 22 10:41 00000000001020831084.timeindex
-rw-r--r-- 1 kafka kafka  10M Jul 23 11:38 00000000001025304089.index
-rw-r--n-- 1 kafka kafka 152M Ju1 23 11:39 00000000001025304089.1og
-rw-r--r-- 1 kafka kafka  10M Jul 23 11:39 00000000001025304089.timeindex
```

`00000000001020831084.1og`就是消息数据, 有2个".log"文件是因为第1个数据文件已经达到容量上限(由`log.segment.bytes`设置, 默认为1G), 之后需要被清理了.
