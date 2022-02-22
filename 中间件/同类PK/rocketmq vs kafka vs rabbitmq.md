参考文章

1. [大数据开发hadoop核心的分布式消息系统：Apache Kafka 你知道吗？](https://zhuanlan.zhihu.com/p/68296661)
2. [Kafka、RabbitMQ、RocketMQ等消息中间件的介绍和对比](https://blog.csdn.net/yunfeng482/article/details/72856762)
    - LinkIn 的对比测试
    - 吞吐量(数据写入): kafka > rocketmq > rabbitmq(amqp)
    - RocketMQ思路起源于Kafka，但并不是Kafka的一个Copy，它对消息的可靠传输及事务性做了优化.

MQ系统通用功能: 解耦, 削峰填谷. 其余的像是横向扩展, 顺序保证, 数据冗余, 感觉都不是核心能力...

可靠性: rabbitmq > rocketmq > kafka

## kafka

kafka可支持的并发量极大(千万级), 但是为此牺牲了一部分数据安全性, 所以日志系统, 非核心的数据采集等都用kafka处理.

kafka没有权限认证, 只要知道了kafka集群的地址和topic名称, 就能读写, 可以说十分不安全...rabbitmq就需要创建用户才能用(跟数据库一样)

同等规模的情况下, 比rocketmq吞吐量/并发更高(不过单机规模体现不出kafka的优势)

kafka的功能相较与rocketmq与rabbitmq也比较简单, 最典型的就是消费模式, 只有消费组中的成员均分一种形式. 另外, kafka的消息无法追溯来源, 除非是将来源写入到消息体中.

## rocketmq



## rabbitmq

支持很多种协议(比如amqp等, 这些协议之间的区别类似于tcp和udp, 可以理解为3次握手, 4次握手, 还是不握手, 也可以指定重传机制啥的), 所以非常重量级.

rabbitmq的消费者在取出一条消息并消费完成后, 会发送一条回执, 将该消息在rabbitmq中的状态修改为"已消费"(在取出消息, 在消费过程中, 这条消息在mq中会处于一个"中间状态", 其他消费者是没办法重新获取这条消息的). 

kafka是没有这样的回执机制/消息确认机制的.

## redis

redis也可以实现pub/sub(订阅发布模式一般是多个订阅者, 可以同时获取对同一消息进行处理), 但ta基本只保证数据的实时性, 不保证可靠性, 可能会造成消息丢失. 比如一个订阅者取走了一条消息, 没来得及处理完成, 崩溃/宕机了, 再次启动时, redis是不会重传消息的, 这条消息就相当于丢了.

而且redis pub/sub 不支持消费组机制, 同一个topic的消息, 所有的消费者都会得到, 没法做负载均衡.

