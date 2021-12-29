# logstash-无法解析kafka实例IP变动后的地址

参考文章

1. [Kubernetes - Kafka clients are resolving DNS entries only one time](https://issues.apache.org/jira/browse/KAFKA-7755)
2. [Logstash is not able to connect to Kafka if Kafka host name is not resolved when Logstash starts](https://github.com/logstash-plugins/logstash-output-kafka/issues/155)
3. [Client Not Following Broker IP Change - Upgrade Kafka Client to 2.1.1](https://github.com/akka/alpakka-kafka/issues/734)


- logstash: 5.5.0
- kafka: 2.11_0.10.1.1

