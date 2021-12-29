# kafka启动异常-A broker is already registered on the path[zookeeper zk]

## 场景描述

3节点的kafka集群, 其中一个节点发生了重启, 但是启动失败, 日志中有如下异常.

```
[2021-12-18 12:19:55,347] FATAL Fatal error during KafkaServerStartable startup. Prepare to shutdown (kafka.server.KafkaServerStartable)
java.lang.RuntimeException: A broker is already registered on the path /brokers/ids/1. This probably indicates that you either have configured a brokerid that is already in use, or else you have shutdown this broker and restarted it faster than the zookeeper timeout so it appears to be re-registering.
        at kafka.utils.ZkUtils.registerBrokerInZk(ZkUtils.scala:393)
        at kafka.utils.ZkUtils.registerBrokerInZk(ZkUtils.scala:379)
        at kafka.server.KafkaHealthcheck.register(KafkaHealthcheck.scala:70)
        at kafka.server.KafkaHealthcheck.startup(KafkaHealthcheck.scala:51)
        at kafka.server.KafkaServer.startup(KafkaServer.scala:270)
        at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:39)
        at kafka.Kafka$.main(Kafka.scala:67)
        at kafka.Kafka.main(Kafka.scala)
```

这个异常说明, 该kafka实例id已经在zk中存在了, 发生了冲突.

进入相应的zk集群的命令行查看, 发现`/brokers/ids/`目录下, 存在3个节点, 发生重启的实例还好好的在呢...

## 处理方案

经排查, 发现zk集群虽然正常服务, 但是之前某个节点所在主机出现过一次磁盘占用100%的问题, 清理过后恢复正常. 

于是决定重启zk集群, 重启完成后, 再次查看`/brokers/ids/`目录, 发现发生重启的kafka实例已经没有了, 于是再次启动该kafka实例, 成功.
