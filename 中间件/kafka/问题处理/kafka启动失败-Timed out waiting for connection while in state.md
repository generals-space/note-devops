# kafka启动失败-Timed out waiting for connection while in state

参考文章

1. [kafka 集群搭建时遇到Kafka超时错误：Timed out waiting for connection while in state](https://www.cnblogs.com/bayu/articles/14527761.html)
2. [Kafka Zookeeper ZkTimeoutException解决方法](http://blog.sina.com.cn/s/blog_3fe961ae01011o4z.html)

## 问题描述

- kafka: 2.12-2.3.1(单节点)
- zk: 3.4.9(单节点)

kafka在启动时连接zk超时, 报如下错误.

```
[2021-09-09 08:58:53,452] INFO Initiating client connection, connectString=192.168.128.101:2181 sessionTimeout=6000 watcher=kafka.zookeeper.ZooKeeperClient$ZooKeeperClientWatcher$@61df66b6 (org.apache.zookeeper.ZooKeeper)
[2021-09-09 08:58:53,505] INFO [ZooKeeperClient Kafka server] Waiting until connected. (kafka.zookeeper.ZooKeeperClient)
[2021-09-09 08:58:59,508] INFO [ZooKeeperClient Kafka server] Closing. (kafka.zookeeper.ZooKeeperClient)
[2021-09-09 08:59:13,524] INFO Opening socket connection to server 192.168.128.101/192.168.128.101:2181. Will not attempt to authenticate using SASL (unknown error) (org.apache.zookeeper.ClientCnxn)
[2021-09-09 08:59:13,529] INFO Socket connection established to 192.168.128.101/192.168.128.101:2181, initiating session (org.apache.zookeeper.ClientCnxn)
[2021-09-09 08:59:13,533] INFO Session establishment complete on server 192.168.128.101/192.168.128.101:2181, sessionid = 0x17bc5452357012f, negotiated timeout = 6000 (org.apache.zookeeper.ClientCnxn)
[2021-09-09 08:59:13,536] INFO Session: 0x17bc5452357012f closed (org.apache.zookeeper.ZooKeeper)
[2021-09-09 08:59:13,537] INFO EventThread shut down for session: 0x17bc5452357012f (org.apache.zookeeper.ClientCnxn)
[2021-09-09 08:59:13,538] INFO [ZooKeeperClient Kafka server] Closed. (kafka.zookeeper.ZooKeeperClient)
[2021-09-09 08:59:13,540] ERROR Fatal error during KafkaServer startup. Prepare to shutdown (kafka.server.KafkaServer)
kafka.zookeeper.ZooKeeperClientTimeoutException: Timed out waiting for connection while in state: CONNECTING
	at kafka.zookeeper.ZooKeeperClient.$anonfun$waitUntilConnected$3(ZooKeeperClient.scala:258)
	at scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.java:23)
	at kafka.utils.CoreUtils$.inLock(CoreUtils.scala:253)
	at kafka.zookeeper.ZooKeeperClient.waitUntilConnected(ZooKeeperClient.scala:254)
	at kafka.zookeeper.ZooKeeperClient.<init>(ZooKeeperClient.scala:112)
	at kafka.zk.KafkaZkClient$.apply(KafkaZkClient.scala:1826)
	at kafka.server.KafkaServer.createZkClient$1(KafkaServer.scala:364)
	at kafka.server.KafkaServer.initZkClient(KafkaServer.scala:387)
	at kafka.server.KafkaServer.startup(KafkaServer.scala:207)
	at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:38)
	at kafka.Kafka$.main(Kafka.scala:84)
	at kafka.Kafka.main(Kafka.scala)
[2021-09-09 08:59:13,543] INFO shutting down (kafka.server.KafkaServer)
[2021-09-09 08:59:13,549] INFO shut down completed (kafka.server.KafkaServer)
[2021-09-09 08:59:13,549] ERROR Exiting Kafka. (kafka.server.KafkaServerStartable)
[2021-09-09 08:59:13,552] INFO shutting down (kafka.server.KafkaServer)
```

这是zk的日志

```
2021-09-08 12:14:21,718 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@192] - Accepted socket connection from /10.254.0.19:54942
2021-09-08 12:14:21,719 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:ZooKeeperServer@928] - Client attempting to establish new session at /10.254.0.19:54942
2021-09-08 12:14:21,722 [myid:] - INFO  [SyncThread:0:ZooKeeperServer@673] - Established session 0x17bc54523570017 with negotiated timeout 10000 for client /10.254.0.19:54942
2021-09-08 12:14:53,549 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@192] - Accepted socket connection from /10.254.0.19:55054
2021-09-08 12:14:53,551 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:ZooKeeperServer@928] - Client attempting to establish new session at /10.254.0.19:55054
2021-09-08 12:14:53,552 [myid:] - INFO  [SyncThread:0:ZooKeeperServer@673] - Established session 0x17bc54523570018 with negotiated timeout 6000 for client /10.254.0.19:55054
2021-09-08 12:14:53,556 [myid:] - INFO  [ProcessThread(sid:0 cport:2181)::PrepRequestProcessor@487] - Processed session termination for sessionid: 0x17bc54523570018
2021-09-08 12:14:53,558 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@1008] - Closed socket connection for client /10.254.0.19:55054 which had sessionid 0x17bc54523570018
2021-09-08 12:14:53,960 [myid:] - WARN  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@357] - caught end of stream exception
EndOfStreamException: Unable to read additional data from client sessionid 0x17bc54523570017, likely client has closed socket
	at org.apache.zookeeper.server.NIOServerCnxn.doIO(NIOServerCnxn.java:228)
	at org.apache.zookeeper.server.NIOServerCnxnFactory.run(NIOServerCnxnFactory.java:203)
	at java.lang.Thread.run(Thread.java:745)
2021-09-08 12:14:53,961 [myid:] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@1008] - Closed socket connection for client /10.254.0.19:54942 which had sessionid 0x17bc54523570017
2021-09-08 12:15:04,000 [myid:] - INFO  [SessionTracker:ZooKeeperServer@358] - Expiring session 0x17bc54523570017, timeout of 10000ms exceeded
2021-09-08 12:15:04,000 [myid:] - INFO  [ProcessThread(sid:0 cport:2181)::PrepRequestProcessor@487] - Processed session termination for sessionid: 0x17bc54523570017
```

## 解决方案

因为端口是通的, 网络没问题, 我最开始没有往网络方面考虑, 在网上找到的文章都在东拉西扯(比如参考文章1). 也有文章说kafka工程目录`libs`下的zookeeper client客户端与zk版本不一致的, 我也改过, 没用.

后来找到参考文章2, 尝试修改了下kafka的`zookeeper.connection.timeout.ms`配置(原来是6000, 改为10000), 就可以...竟然真的是超时问题.
