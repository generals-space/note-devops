# kafka压测方案

参考文章

1. [Kafka压力测试(写入MQ消息压测和消费MQ消息压测）](https://blog.csdn.net/laofashi2015/article/details/81111466)

kafka: 2.12-2.3.1

## 生产

```
./bin/kafka-producer-perf-test.sh --topic test --num-records 100000 --record-size 1000 --throughput 2000 --producer-props bootstrap.servers=127.0.0.1:9092
```

- `--topic`: topic名称, 本例为`test`
- `--num-records`: 总共需要发送的消息数, 本例为`100000`
- `--record-size`: 每条消息的字节数, 本例为1000
- `--throughput`: 每秒钟发送的消息数量, 本例为2000
- `--producer-props bootstrap.servers=127.0.0.1:9092`: (发送端的配置信息, 本次测试取集群服务器中的一台作为发送端,可在kafka的config目录(以该项目为例: /usr/local/kafka/config), 查看`server.properties`中配置的`zookeeper.connect`的值, 默认端口: 9092)

按照消息总量(100000)/每秒钟发送的消息数量(2000), 上面的命令会在5秒钟左右执行完毕.

## 消费

```
./bin/kafka-consumer-perf-test.sh --broker-list 127.0.0.1:9092 --topic test --fetch-size 1048576 --messages 100000 --threads 1
```

- `--zookeeper`: 指定zookeeper的链接信息, 本例为`127.0.0.1:2181`
- `--topic`: 指定topic的名称, 本例为`test`, 与上面生产者配置相同
- `--fetch-size`: 指定每次fetch的数据的大小, 本例为1048576, 也就是1M
- `--messages`: 总共要消费的消息个数, 本例为100000
