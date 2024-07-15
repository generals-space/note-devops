# Kafka多集群共用ZK集群方案

## 1、Zookeeper在Kafka集群中的用途

Kafka使用Zookeeper集群来管理元数据、实现分区的领导者选举、协调消费者组以及管理消费者组的偏移量. Zookeeper提供了分布式协调和一致性服务, 帮助Kafka实现高可用性、数据一致性和故障恢复能力, 使得Kafka集群能够可靠地处理大规模的消息流. 

## 2、Kafka如何配置Zookeeper地址

在Kafka集群的`server.properties`中配置`zookeeper.connect`为ZK地址.

```ini
zookeeper.connect=192.168.0.1:9092
```

因Kafka默认在ZK根目录`/`下新增集群相关数据, 如果多套Kafka集群共用一套ZK集群时, 会出现数据冲突的报错. 

## 3、解决方案

为解决数据冲突的问题, 需要在配置`zookeeper.connect`地址时, 增加特有的数据路径来进行区分存储路径. 

```ini
zookeeper.connect=192.168.0.1:9092/kafkacluster01
```

## 4、优缺点

优点:

多套Kafka共用一套ZK时, 可节省ZK资源投入, 减少服务器开支. 

缺点:

1. 当ZK集群故障时, 会影响多套Kafka集群使用, 故障影响范围广；
2. ZK数据管理起来较为复杂, 且后续ZK云化迁移腾挪麻烦. 
