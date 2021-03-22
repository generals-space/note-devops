# kafka认识部署及使用

参考文章

1. [Kafka的简单部署与学习](https://blog.csdn.net/SartinL/article/details/108846275)

kafka 依赖 zk, 且一个zk实例(或是集群)只能对一个kafka集群提供服务, 相当于绑定的关系.

`kafka/config/server.properties`中, `broker.id`字段全局唯一, 每个kafka实例都不能相同, 否则启动会报错.

```
ERROR Error while creating ephemeral at /brokers/ids/1, node already exists
```

## 使用方法

### topic 操作

创建 topic

```
bin/kafka-topics.sh --create --zookeeper 192.168.100.11:2181 --replication-factor 1 --partitions 1 --topic test
```

查看已经存在的 topic

```
bin/kafka-topics.sh --list --zookeeper 192.168.100.11:2181
```

删除 topic

```
bin/kafka-topics.sh --delete --zookeeper 192.168.100.11:2181 --topic test
```

### 

生产

```
bin/kafka-console-producer.sh --broker-list 192.168.100.11:9092 --topic test
```

消费

```
bin/kafka-console-consumer.sh --bootstrap-server 192.168.100.11:9092 --topic test --from-beginning
```
