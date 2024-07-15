# 搭建Redis集群遇到的问题：Waiting for the cluster to join

参考文章

1. [搭建Redis集群遇到的问题：Waiting for the cluster to join](https://blog.csdn.net/IT_rookie_newbie/article/details/120831949)
2. [云服务器上基于docker搭建redis集群](https://juejin.cn/post/7075602316849577992)
    - cluster-announce-ip

## 场景描述

在阿里云上搭建redis集群, 通过如下命令创建

```
redis-cli -a 12345678 --cluster create --cluster-yes --cluster-replicas 1 \
公网IP:6379 \
公网IP:6380 \
公网IP:6381 \
公网IP:6382 \
公网IP:6383 \
公网IP:6384
```

但是卡在下面这个地方不动了

```log
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
..................................................................................................................................................................................................................................
```

## 集群总线

每个Redis集群中的节点都需要打开两个TCP连接。一个连接用于正常的给Client提供服务，比如6379，还有一个额外的端口（通过在这个端口号上加10000）作为数据端口，例如：redis的端口为6379，那么另外一个需要开通的端口是：6379 + 10000， 即需要开启 16379。16379端口用于集群总线，这是一个用二进制协议的点对点通信信道。这个集群总线（Cluster bus）用于节点的失败侦测、配置更新、故障转移授权，等等。

安全组中只放开了6379-6384, 还需要放开16379-16384.

##

另外, 虽然使用上面的 redis-cli 命令可以组建起集群, 但是可能会出现如下情况

```log
root@6e768c66b989:/data# redis-cli -c -h 47.92.209.167 -p 6380
47.92.209.167:6380> auth 12345678
OK
47.92.209.167:6380> cluster nodes
527989162204a93a54f36d0e23db106ebbe255d2 47.92.209.167:6379@16379 master - 0 1662292529602 1 connected 0-5460
f8b73ddddd09529e105765a41271c4592f789479 172.28.0.8:6380@16380 myself,master - 0 1662292526000 2 connected 5461-10922
53e9464d8a8b5254d384f260d19bc47c7547e278 47.92.209.167:6384@16384 slave f8b73ddddd09529e105765a41271c4592f789479 0 1662292527000 6 connected
5e9a32b82a2a62dfd235f4530228f641335e1ced 47.92.209.167:6382@16382 slave a5d00a74c3631f00ba19d616342643092000dfe3 0 1662292528600 4 connected
993f7c196729ff645b2af54a6cd178f7bd8a6c62 47.92.209.167:6383@16383 slave 527989162204a93a54f36d0e23db106ebbe255d2 0 1662292528000 1 connected
a5d00a74c3631f00ba19d616342643092000dfe3 47.92.209.167:6381@16381 master - 0 1662292528000 3 connected 10923-16383
```

使用"redis-cli -p 端口"进入交互式命令终端, 会发现该端口对应的节点信息中, 仍然存在内网IP"172.28.0.8:6380@16380"

我们需要避免这种情况, 可以通过"--cluster-announce-ip 公网IP"完成.
