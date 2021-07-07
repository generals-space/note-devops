# logstash pipeline-kafka input from beginning

参考文章

1. [Logstash 5.1.1 kafka input doesn't pick up existing messages on topic](https://stackoverflow.com/questions/42033193/logstash-5-1-1-kafka-input-doesnt-pick-up-existing-messages-on-topic)
    - `auto_offset_reset => earliest`
    - logstash 7.0.0 的配置, 比较详细
2. [Kafka与Logstash的数据采集对接 —— 看图说话，从运行机制到部署](https://www.cnblogs.com/xing901022/p/5738485.html)
    - `reset_beginning => true`
3. [官方文档 Logstash Reference [5.5] » Input plugins » Kafka input plugin](https://www.elastic.co/guide/en/logstash/5.5/plugins-inputs-kafka.html)

kafka的consumer脚本`kafka-console-consumer.sh`, 默认在消费时只获取连接到kafka集群后发送到目标`topic`的消息, 对于在连接到kafka集群之前就已经存在于该`topic`的消息, 则直接忽略. 但是ta同时还提供了一个`--from-beginning`参数, 用于获取该`topic`中所有的消息.

在ELK体系中, 数据流向如下

```
nginx01 -> filebeat01 ─┐
                       ├─> kafka -> logstash -> es
nginx02 -> filebeat02 ─┘
```

`logstash`可以作为kafka的客户端, 在读取数据的时候也会遇到上述场景. logstash 2.4 可以使用如下字段

```conf
reset_beginning => true
```

而logstash 5.x-7.x, 需要改为如下字段

```conf
auto_offset_reset => "earliest"
group_id => "group_id_01"
```

