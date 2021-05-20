# kafka认识部署及使用

参考文章

1. [Kafka的简单部署与学习](https://blog.csdn.net/SartinL/article/details/108846275)
2. [kafka HA（高可用搭建）](https://blog.csdn.net/weixin_42267009/article/details/80411215)

## topic 操作

创建 topic

```
bin/kafka-topics.sh --create --zookeeper $ZK_ADDR --replication-factor 1 --partitions 1 --topic test
```

> `ZK_ADDR`格式可以为: `192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181`

查看已经存在的 topic 列表

```
bin/kafka-topics.sh --list --zookeeper $ZK_ADDR
```

删除 topic

```
bin/kafka-topics.sh --delete --zookeeper $ZK_ADDR --topic test
```

topic 详情

```
bin/kafka-topics.sh --describe --zookeeper $ZK_ADDR --topic test
```

## 消息

生产

```
bin/kafka-console-producer.sh --broker-list 127.0.0.1:9092 --topic test
```

消费

```
bin/kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic test --from-beginning
```

## FAQ

如果在调用`kafka-topics.sh`脚本时, 出现如下错误

```
Error: Exception thrown by the agent : java.rmi.server.ExportException: Port already in use: 9988; nested exception is:
        java.net.BindException: Address already in use (Bind failed)
```

可能是由于环境变量中存在`JMX_PORT`, 将此变量置为空或可解决.

```
export JMX_PORT=
```
