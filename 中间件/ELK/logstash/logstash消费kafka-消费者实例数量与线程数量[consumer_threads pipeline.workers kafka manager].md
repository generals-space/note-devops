# logstash消费kafka-消费者实例数量与线程数量[consumer_threads pipeline.workers]

参考文章

1. [logstash消费kafka-消费者实例](https://blog.csdn.net/nyyjs/article/details/72771905)

1. logstash实例数量
2. logstash-input-kafka: `consumer_threads`
3. logstash启动参数: -w, --pipeline.workers

kafka topic 是有分区(partition)的, 且每个消费者在ta加入消费组的时候, 就与一个特定的 partition 绑定了.

