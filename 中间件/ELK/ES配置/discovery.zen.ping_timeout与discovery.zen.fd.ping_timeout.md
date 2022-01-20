# discovery.zen.ping_timeout与discovery.zen.fd.ping_timeout

参考文章

1. [Zen Discovery](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-discovery-zen.html)
    - 官方文档
    - `discovery.zen.ping_timeout`默认为`3s`, 
2. [discovery.zen.ping_timeout 参数作用的疑惑和探究](https://elasticsearch.cn/question/4199)
    - `discovery.zen.ping_timeout`参数配置越大，选主的过程越长
    - 答主 kennywu76 非常给力👍🏻

discovery.zen.ping_timeout: 主要是控制master选举过程中，发现其他node存活的超时设置，同时影响选举的耗时(基本上就是定义了选举过程的耗时, 而非超时)

discovery.zen.fd.ping_timeout: 判断结点是否脱离集群, 一般在网络拥堵时可以体现出其作用(使用iptables手动模拟断网也可以). 而在一个节点发生重启时, 由于端口不通(Connection refused), 集群中其他节点会立刻察觉到, 反而用不到这个参数.

