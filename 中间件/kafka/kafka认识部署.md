# kafka认识部署及使用

参考文章

1. [Kafka的简单部署与学习](https://blog.csdn.net/SartinL/article/details/108846275)
2. [kafka 集群_Kafka高可用集群部署与配置指南](https://blog.csdn.net/weixin_39633437/article/details/111262524)

kafka 依赖 zk, 且一个zk实例(或是集群)只能对一个kafka集群提供服务, 相当于绑定的关系.

`kafka/config/server.properties`中, `broker.id`字段全局唯一, 每个kafka实例都不能相同, 否则启动会报错.

```
ERROR Error while creating ephemeral at /brokers/ids/1, node already exists
```
