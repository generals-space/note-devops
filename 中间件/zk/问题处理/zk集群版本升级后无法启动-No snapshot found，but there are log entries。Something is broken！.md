# zk集群版本升级后无法启动-No snapshot found，but there are log entries。Something is broken！

参考文章

1. [ZooKeeper 3.4 to 3.5.x upgrade: "No snapshot found, but there are log entries. Something is broken!"](https://lists.apache.org/thread/7pyh7dgn57m8gc1q2ds2xsfz7tbwfo7t)
2. [Zookeeper 3.5.7 not creating snapshot](https://issues.apache.org/jira/browse/ZOOKEEPER-3781)
3. [How to deal with missing snapshot after ZooKeeper upgrade](https://sleeplessbeastie.eu/2021/08/09/how-to-deal-with-missing-snapshot-after-zookeeper-upgrade/)

## 问题描述

升级前: 3.4.10
升级后: 3.6.3

升级后, 实例启动报错(不管是滚动升级还是快速升级, 不管是先重启 follower 还是 leader, 都报错).

```log
[2021-08-03 22:24:07,002] ERROR Unable to load database on disk (org.apache.zookeeper.server.quorum.QuorumPeer)
java.io.IOException: No snapshot found, but there are log entries. Something is broken!
        at org.apache.zookeeper.server.persistence.FileTxnSnapLog.restore(FileTxnSnapLog.java:240)
        at org.apache.zookeeper.server.ZKDatabase.loadDataBase(ZKDatabase.java:240)
        at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:904)
        at org.apache.zookeeper.server.quorum.QuorumPeer.start(QuorumPeer.java:890)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.runFromConfig(QuorumPeerMain.java:205)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:123)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:82)
[2021-08-03 22:24:07,004] ERROR Unexpected exception, exiting abnormally (org.apache.zookeeper.server.quorum.QuorumPeerMain)
java.lang.RuntimeException: Unable to run quorum server
        at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:941)
        at org.apache.zookeeper.server.quorum.QuorumPeer.start(QuorumPeer.java:890)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.runFromConfig(QuorumPeerMain.java:205)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:123)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:82)
Caused by: java.io.IOException: No snapshot found, but there are log entries. Something is broken!
        at org.apache.zookeeper.server.persistence.FileTxnSnapLog.restore(FileTxnSnapLog.java:240)
        at org.apache.zookeeper.server.ZKDatabase.loadDataBase(ZKDatabase.java:240)
        at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:904)
        ... 4 more
```

另外, 为了测试升级后数据未丢失, 升级前尝试在集群中写入了部分数据, 然后发现, 偶尔一些节点在升级后可以启动.

进到存放数据的`version-2`目录下查看, 有如下输出

```log
[root@localhost version-2]# ll
total 12
-rw-r--r-- 1 root root   1 Jun 12 11:00 acceptedEpoch
-rw-r--r-- 1 root root   1 Jun 12 11:00 currentEpoch
-rw-r--r-- 1 paas paas 908 Jun 12 10:54 snapshot.200000002
```

其余启动失败的实例中, 数据目录下是没有`snapshot.200000002`文件的, 看来这就是根本原因了.

## 解决方案

按照官方文档来说, 这似乎是一个bug, 一些数据量较小的集群可能没有 snapshot 文件生成, 而新版本在启动时必须判断 snapshot 文件是否存在.

后面修复了这个问题, 在只要在配置文件中添加一行`snapshot.trust.empty=true`, 不再检查 snapshot 文件即可.
