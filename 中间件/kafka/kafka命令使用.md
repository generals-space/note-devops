# kafka认识部署及使用

参考文章

1. [Kafka的简单部署与学习](https://blog.csdn.net/SartinL/article/details/108846275)
2. [kafka HA（高可用搭建）](https://blog.csdn.net/weixin_42267009/article/details/80411215)

## topic 操作

创建 topic

```
bin/kafka-topics.sh --create --zookeeper 192.168.100.11:2181 --replication-factor 1 --partitions 1 --topic test
```

查看已经存在的 topic 列表

```
bin/kafka-topics.sh --list --zookeeper 192.168.100.11:2181
```

删除 topic

```
bin/kafka-topics.sh --delete --zookeeper 192.168.100.11:2181 --topic test
```

```
bin/kafka-topics.sh --describe --zookeeper 192.168.100.11:2181 --topic test
```

## 消息

生产

```
bin/kafka-console-producer.sh --broker-list 192.168.100.11:9092 --topic test
```

消费

```
bin/kafka-console-consumer.sh --bootstrap-server 192.168.100.11:9092 --topic test --from-beginning
```
