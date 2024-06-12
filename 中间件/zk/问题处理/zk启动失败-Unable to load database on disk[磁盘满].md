# zk启动失败-Unable to load database on disk[磁盘满]

参考文章

1. [Zookeeper启动提示：Unable to load database on disk](http://blog.itpub.net/69985104/viewspace-2727944/)
    - 实践有效.

## 问题描述

Zookeeper所在节点磁盘满了，导致当前节点Zookeeper宕机，然后当释放磁盘后，启动Zookeeper时显示Zookeeper无法启动，报错信息如下：

```log
2020-09-03 20:03:30,999 ERROR org.apache.zookeeper.server.quorum.QuorumPeer: Unable to load database on disk
java.io.EOFException
...
2020-09-03 20:03:31,012 ERROR org.apache.zookeeper.server.quorum.QuorumPeerMain: Unexpected exception, exiting abnormally
java.lang.RuntimeException: Unable to run quorum server
...
Caused by: java.io.EOFException
...
```

## 问题原因

可能是Zookeeper中注册的信息错误导致的；

## 解决方法

备份 version-2目录，清空Zookeeper目录下的version-2，然后重启Zookeeper生效；

```log
[root@datanode07 ~]# cd /var/lib/zookeeper/
[root@datanode07 zookeeper]# cp -r version-2 version-2-bak
[root@datanode07 zookeeper]#
[root@datanode07 zookeeper]# rm -rf version-2/*
[root@datanode07 zookeeper]# ll
total 8
-rw-r--r-- 1 zookeeper zookeeper    2 Sep  4 12:04 myid
drwxr-xr-x 2 zookeeper zookeeper    6 Sep  4 12:05 version-2
drwxr-xr-x 2 root      root      4096 Sep  4 12:05 version-2-bak
```

------

如果该节点还是无法启动, 则查看zookeeper的log目录, 该目录下也存在一个`version-2`目录, 删除这个目录再重启一次.
