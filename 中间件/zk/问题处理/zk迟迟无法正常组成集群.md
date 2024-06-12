# zk迟迟无法正常组成集群

## 场景描述

zk: 3.4.9*3, kube环境容器化部署

3个节点都已启动, 配置文件没有问题, 网络也没有问题, 进入容器后, 相互之间都可以telnet通彼此的端口, 但是`bin/zkCli.sh`无法进入交互式命令行.

```log
[root@test-baicy-7-0 zookeeper-3.4.9]# ./bin/zkCli.sh
Connecting to localhost:2181
...省略
serverlog || 2021-11-09 16:44:58,772 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main:ZooKeeper@438] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@68de145
Welcome to ZooKeeper!
serverlog || 2021-11-09 16:44:58,846 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1032] - Opening socket connection to server localhost/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
JLine support is enabled
serverlog || 2021-11-09 16:44:59,039 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@876] - Socket connection established to localhost/127.0.0.1:2181, initiating session
serverlog || 2021-11-09 16:44:59,045 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1158] - Unable to read additional data from server sessionid 0x0, likely server has closed socket, closing socket connection and attempting reconnect
[zk: localhost:2181(CONNECTING) 0] ls serverlog || 2021-11-09 16:45:00,875 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1032] - Opening socket connection to server localhost/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
serverlog || 2021-11-09 16:45:00,876 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@876] - Socket connection established to localhost/127.0.0.1:2181, initiating session
serverlog || 2021-11-09 16:45:00,877 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1158] - Unable to read additional data from server sessionid 0x0, likely server has closed socket, closing socket connection and attempting reconnect
/
serverlog || 2021-11-09 16:45:02,301 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1032] - Opening socket connection to server localhost/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
serverlog || 2021-11-09 16:45:02,302 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@876] - Socket connection established to localhost/127.0.0.1:2181, initiating session
serverlog || 2021-11-09 16:45:02,303 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:] [main-SendThread(localhost:2181):ClientCnxn$SendThread@1158] - Unable to read additional data from server sessionid 0x0, likely server has closed socket, closing socket connection and attempting reconnect
Exception in thread "main" org.apache.zookeeper.KeeperException$ConnectionLossException: KeeperErrorCode = ConnectionLoss for /
        at org.apache.zookeeper.KeeperException.create(KeeperException.java:99)
        at org.apache.zookeeper.KeeperException.create(KeeperException.java:51)
        at org.apache.zookeeper.ZooKeeper.getChildren(ZooKeeper.java:1532)
        at org.apache.zookeeper.ZooKeeper.getChildren(ZooKeeper.java:1560)
        at org.apache.zookeeper.ZooKeeperMain.processZKCmd(ZooKeeperMain.java:731)
        at org.apache.zookeeper.ZooKeeperMain.processCmd(ZooKeeperMain.java:599)
        at org.apache.zookeeper.ZooKeeperMain.executeLine(ZooKeeperMain.java:371)
        at org.apache.zookeeper.ZooKeeperMain.run(ZooKeeperMain.java:331)
        at org.apache.zookeeper.ZooKeeperMain.main(ZooKeeperMain.java:290)
```

看起来根本没有组成集群.

查看pod-0的日志如下

```log
serverlog || 2021-11-09 17:19:34,347 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@192] - Accepted socket connection from /127.0.0.1:54564
serverlog || 2021-11-09 17:19:34,354 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:ZooKeeperServer@928] - Client attempting to establish new session at /127.0.0.1:54564
serverlog || 2021-11-09 17:19:34,360 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [CommitProcessor:0:ZooKeeperServer@673] - Established session 0x7d03ef84ff0001 with negotiated timeout 30000 for client /127.0.0.1:54564
serverlog || 2021-11-09 17:19:37,169 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@192] - Accepted socket connection from /192.168.34.30:53030
serverlog || 2021-11-09 17:19:37,170 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@827] - Processing ruok command from /192.168.34.30:53030
serverlog || 2021-11-09 17:19:37,170 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [Thread-225:NIOServerCnxn@1008] - Closed socket connection for client /192.168.34.30:53030 (no session established for client)
serverlog || 2021-11-09 17:19:42,168 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@192] - Accepted socket connection from /192.168.34.30:53058
serverlog || 2021-11-09 17:19:42,168 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@827] - Processing ruok command from /192.168.34.30:53058
serverlog || 2021-11-09 17:19:42,169 || test-baicy-7 || test-baicy-7-0 || INFO || [myid:0] [Thread-226:NIOServerCnxn@1008] - Closed socket connection for client /192.168.34.30:53058 (no session established for client)
```

一直是这几句重复打印.

## 排查思路

当时有一个kafka集群配置了这个zk集群的地址, 但是其中只有2个是该zk集群的IP, 另外一个是另一个zk集群的IP(其实是一个无效地址)...

当我把这个kafka集群删掉之后, 这个zk集群就可以正常访问了...

当该zk集群正常启动后, 再把原来的kafka集群启动起来, kafka竟然能正常运行了...

仅提供一个思路, 记录一下.
