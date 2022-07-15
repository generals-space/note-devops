# kafka接收filebeat客户端数据报错 - ERROR Closing socket for kafka地址 - filebeat地址 because of error - kafka.network.Processor

参考文章

1. [filebeat使用kafka作为input（filebeat从kafka中读取数据）报错解决](https://blog.csdn.net/qq_41566159/article/details/111247334)

## 问题描述

- filebeat: 6.4.0
- kafka: 2.11-0.10.1.1

filebeat 在向 kafka 发送数据, 但 kafka topic 中始终没有数据与入, filebeat 日志中报如下错误

```
2022-07-01T15:54:15.015+0800    INFO    kafka/log.go:53 kafka message: Initializing new client
2022-07-01T15:54:15.016+0800    INFO    kafka/log.go:53 client/metadata fetching metadata for all topics from broker kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
2022-07-01T15:54:15.018+0800    INFO    kafka/log.go:53 Connected to broker at kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092 (unregistered)
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 client/brokers registered new broker #2 at kafka-ha-zjjlog-2.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 client/brokers registered new broker #1 at kafka-ha-zjjlog-1.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 client/brokers registered new broker #0 at kafka-ha-zjjlog-0.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 kafka message: Successfully initialized new client
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 producer/broker/2 starting up
2022-07-01T15:54:15.021+0800    INFO    kafka/log.go:53 producer/broker/2 state change to [open] on topic_mysql_audit_log/2
2022-07-01T15:54:15.022+0800    INFO    kafka/log.go:53 producer/broker/0 starting up
2022-07-01T15:54:15.022+0800    INFO    kafka/log.go:53 producer/broker/0 state change to [open] on topic_mysql_audit_log/0
2022-07-01T15:54:15.022+0800    INFO    kafka/log.go:53 producer/broker/1 starting up
2022-07-01T15:54:15.022+0800    INFO    kafka/log.go:53 producer/broker/1 state change to [open] on topic_mysql_audit_log/1
2022-07-01T15:54:15.025+0800    INFO    kafka/log.go:53 Connected to broker at kafka-ha-zjjlog-2.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092 (registered as #2)
2022-07-01T15:54:15.025+0800    INFO    kafka/log.go:53 Connected to broker at kafka-ha-zjjlog-1.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092 (registered as #1)
2022-07-01T15:54:15.026+0800    INFO    kafka/log.go:53 Connected to broker at kafka-ha-zjjlog-0.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092 (registered as #0)
2022-07-01T15:54:15.028+0800    INFO    kafka/log.go:53 producer/broker/0 state change to [closing] because EOF
2022-07-01T15:54:15.028+0800    INFO    kafka/log.go:53 producer/broker/2 state change to [closing] because EOF
2022-07-01T15:54:15.028+0800    INFO    kafka/log.go:53 producer/broker/1 state change to [closing] because EOF
2022-07-01T15:54:15.028+0800    INFO    kafka/log.go:53 Closed connection to broker kafka-ha-zjjlog-0.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
2022-07-01T15:54:15.028+0800    INFO    kafka/log.go:53 Closed connection to broker kafka-ha-zjjlog-2.kafka-ha-zjjlog-svc.zjjpt-kafka.svc.cluster.local:9092
```

与此同时, kafka中也有报错如下

```
[2022-07-01 15:51:12,259] ERROR Closing socket for 172.19.95.64:9092-172.19.84.85:46938 because of error (kafka.network.Processor)
org.apache.kafka.common.errors.InvalidRequestException: Error getting request for apiKey: 0 and apiVersion: 3
Caused by: java.lang.IllegalArgumentException: Invalid version for API key 0: 3
        at org.apache.kafka.common.protocol.ProtoUtils.schemaFor(ProtoUtils.java:31)
        at org.apache.kafka.common.protocol.ProtoUtils.requestSchema(ProtoUtils.java:44)
        ...省略
        at kafka.network.Processor.run(SocketServer.scala:417)
        at java.lang.Thread.run(Thread.java:748)
```

其中, "172.19.95.64"为当前 kafka broker 的地址, "172.19.84.85"则为 filebeat 的地址.

## 解决方法

按照参考文章1中的说法, filebeat 与 kafka 的版本不符, 后尝试将 filebeat 降级至 6.3.2, 就可以了.
