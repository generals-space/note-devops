# kafka启动失败-The Cluster ID xxx doesn't match stored clusterId Some(yyy) in meta.properties

参考文章

1. [Kafka Broker doesn't find cluster id and creates new one after docker restart](https://stackoverflow.com/questions/59592518/kafka-broker-doesnt-find-cluster-id-and-creates-new-one-after-docker-restart)
2. [Kafka启动失败异常-InconsistentClusterIdException](https://www.cnblogs.com/liuys635/p/17132020.html)
    - 删除数据
3. [The Cluster ID Zc7nlyfTQ5qPbhY2d8I_3A doesn't match stored clusterId So 原创](https://blog.51cto.com/u_16558404/9601200)

- zk: 3.4.10
- kafka: 2.8.1

## 问题描述

zk集群因为某种原因需要暂停一段时间, 在此期间 kafka 会不断尝试重连 zk.

zk集群恢复后, kafka 仍在尝试重连, 日志会报如下错误.

```log
[2024-06-21 11:14:57,586] INFO Opening socket connection to server test-01-svc.zjjpt-zk.svc.cluster.local/172.23.47.15:2181. Will not attempt to authenticate using SASL (unknown error) (org.apache.zookeeper.ClientCnxn)
[2024-06-21 11:14:57,587] INFO Socket error occurred: test-01-svc.zjjpt-zk.svc.cluster.local/172.23.47.15:2181: Connection refused (org.apache.zookeeper.ClientCnxn)
[2024-06-21 11:14:59,308] INFO Opening socket connection to server test-01-svc.zjjpt-zk.svc.cluster.local/172.23.47.14:2181. Will not attempt to authenticate using SASL (unknown error) (org.apache.zookeeper.ClientCnxn)
[2024-06-21 11:14:59,309] INFO Socket error occurred: test-01-svc.zjjpt-zk.svc.cluster.local/172.23.47.14:2181: Connection refused (org.apache.zookeeper.ClientCnxn)
[2024-06-21 11:14:59,320] WARN [ReplicaFetcher replicaId=1, leaderId=0, fetcherId=0] Connection to node 0 (/172.23.47.13:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2024-06-21 11:14:59,320] INFO [ReplicaFetcher replicaId=1, leaderId=0, fetcherId=0] Error sending fetch request (sessionId=685089226, epoch=INITIAL) to node 0: (org.apache.kafka.clients.FetchSessionHandler)
java.io.IOException: Connection to 172.23.47.13:9092 (id: 0 rack: null) failed.
        at org.apache.kafka.clients.NetworkClientUtils.awaitReady(NetworkClientUtils.java:71)
        ## 省略...
        at kafka.utils.ShutdownableThread.run(ShutdownableThread.scala:96)
```

此时需要手动重启一下 kafka 的每个节点, 否则ta们仍然感知不到 zk 其实已经恢复了.

但是重启后, kafka 却启动失败了.

```log
[2024-06-21 15:58:43,303] ERROR Fatal error during KafkaServer startup. Prepare to shutdown (kafka.server.KafkaServer)
kafka.common.InconsistentClusterIdException: The Cluster ID xxx doesn't match stored clusterId Some(yyy) in meta.properties. The broker is trying to join the wrong cluster. Configured zookeeper.connect may be wrong.
        at kafka.server.KafkaServer.startup(KafkaServer.scala:220)
        at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:44)
        at kafka.Kafka$.main(Kafka.scala:84)
        at kafka.Kafka.main(Kafka.scala)
[2024-06-21 15:58:43,303] INFO shutting down (kafka.server.KafkaServer)
```

按照参考文章中的说法, 我用调试手段先停止 kafka 服务并进入容器终端, 查看`config/server.properties`中`log.dirs`配置的目录下, `meta.properties`中的内容, 发现为`cluster.id=yyy`.

而进入对应的zk中`get /cluster/id`的内容, 发现是`xxx`, 两者不一致, 发生冲突了.

原因目前还不清楚, 参考文章中也都没有解释.

## 解决方法

手动修改 zk 中的`/cluster/id`的值, 然后重启 kafka 实例, 这样数据还在.

按照参考文章3中所说, 也可以修改`meta.properties`中的`cluster.id`值, 不过我没尝试...kafka实例太多, 一个个改太麻烦了...

或者下次暂停 zk 之前, 可以先暂停 kafka?
