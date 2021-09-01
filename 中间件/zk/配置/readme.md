参考文章

1. [zookeeper集群应对万级并发的调优](https://blog.csdn.net/lifetragedy/article/details/116641678)
2. [ZooKeeper客户端连接数过多](https://blog.csdn.net/zlfprogram/article/details/74066792)
    - `maxClientCnxns`单个客户端与单台服务器之间的连接数的限制, 是ip级别的, 默认是60, 如果设置为0, 那么表明不作任何限制. 
    - 请注意这个限制的使用范围, 仅仅是单台客户端机器与单台ZK服务器之间的连接数限制, 不是针对指定客户端IP, 也不是ZK集群的连接数限制, 也不是单台ZK对所有客户端的连接数限制. 
3. [ZooKeeper的配置文件优化性能（转）](https://www.cnblogs.com/EasonJim/p/7488834.html)
    - 非常详细!
4. [ZooKeeper | ZooKeeper ensemble configuration](http://www.mtitek.com/tutorials/zookeeper/installation_cluster_notes.php)
    - `server.X`后的参数竟然可以那么丰富...
5. [zookeeper 之 zoo.cfg 配置](https://www.cnblogs.com/zhangzhonghui/articles/12550931.html)

`zoo.cfg`中

```
clientPort=2181
server.0=zk-ha-test-busi-kafka-0.zk-ha-test-busi-kafka-svc.zjjpt-zk.svc.cs-hua.hpc:2888:3888
```

2181是对外提供服务的端口.

2888是集群内部进行数据同步的端口, 只有Master才会开启, follower只要连接ta就可以了;

3888是集群选举需要的端口, 所有节点都需要开启.
