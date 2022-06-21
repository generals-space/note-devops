# logstash-无法解析kafka实例IP变动后的域名地址[dns domain]

参考文章

1. [Kubernetes - Kafka clients are resolving DNS entries only one time](https://issues.apache.org/jira/browse/KAFKA-7755)
    - kafka client 只在启动时做一次域名解析, 之后 kafka 域名指向的 broker 实例 IP 发生变动后, 仍然请求原来的 IP 地址.
    - 这个问题的出现是因为参考文章2中所做的变动
    - 
2. [Kafka clients should try to use multiple DNS resolved IP addresses if the first one fails](https://issues.apache.org/jira/browse/KAFKA-6863)
    - 让 kafka client 支持多域名参数列表.
3. [Logstash is not able to connect to Kafka if Kafka host name is not resolved when Logstash starts](https://github.com/logstash-plugins/logstash-output-kafka/issues/155)
4. [Client Not Following Broker IP Change - Upgrade Kafka Client to 2.1.1](https://github.com/akka/alpakka-kafka/issues/734)


- logstash: 5.5.0
- kafka: 2.11_0.10.1.1

## 问题描述

前提: logstash 订阅了 kafka, 且 kafka 地址为域名形式.

当 kafka 域名指向的 broker 实例 IP 地址发生变动时, logstash 并不能感知到这个变动, 仍然请求原来的 IP 地址(可以抓包确认).

这个问题在传统的虚拟机环境一般不会出现, 因为 broker 实例的 IP 是固定的. 但是在 kubernetes 容器环境下, 则很有可能发生. 

```conf
input {
    kafka {
        bootstrap_servers => "kafka-0.kafka-svc.kafka-ns.svc.cluster.local:9092,kafka-1.kafka-svc.kafka-ns.svc.cluster.local:9092,kafka-2.kafka-svc.kafka-ns.svc.cluster.local:9092"
    }
}
```

`kafka-0`, `kafka-1`, `kafka-2`的pod发生重启时, Pod IP 也会随之变化, 此时 logstash 仍然会从原本的 IP 地址取数据, 造成积压.

------

除了`input{}`, logstash如果在log4j中, 通过remote(UDP)的方式, 以域名形式向另一个logstash实例发送日志, 该域名所指向的 logstash 实例 IP 发生变动时, 也无法感知到...

## 

这个问题在 kafka client 2.1.1+, 2.2.0+ 及以后的版本进行了修复.

logstash 则是在 7.x 进行了修复.
