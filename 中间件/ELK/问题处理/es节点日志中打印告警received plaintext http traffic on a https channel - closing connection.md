# es节点日志中打印告警received plaintext http traffic on a https channel - closing connection

参考文章

1. [SSLHandshakeException causing connections to fail](https://www.elastic.co/guide/en/x-pack/5.4/security-troubleshooting.html#_sslhandshakeexception_causing_connections_to_fail)

es版本: 7.5.1

es所有pod中都有如下输出, 间隔30s.

```
WARN: received plaintext http traffic on a https channel, closing connection
```

集群索引可读可写, 状态正常.

经测试, 使用curl请求9311集群内部通信端口时, 就会输出上述日志, 其实是把https当作http用了, 需要确认连接客户端的地址配置.
