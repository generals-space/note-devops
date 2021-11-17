# HAProxy-timeout client server超时配置

参考文章

1. [HAProxy closes long living TCP connections ignoring TCP keepalive](https://stackoverflow.com/questions/32634980/haproxy-closes-long-living-tcp-connections-ignoring-tcp-keepalive)

常用配置如下

```
defaults
  log     global
  timeout server 600s
  timeout client 600s
  timeout connect 600s
```

`timeout client`定义是客户端与haproxy(`frontend`块)的连接超时时间, `timeout server`则是haproxy与后端`server`的连接超时时间(`backend`块).

区别在于, haproxy的`timeout`是在双方之间没有数据传输的时候开始计时, 超时这个时间就会由haproxy主动断开连接, 需要客户端完成重连. 与linux 的 tcp keepalive 行为差不多.

需要注意的是, 虽然同样是检测空闲连接, 但这个`timeout`是进程级别的, 与linux的 tcp keepalive 不是同一个东西.

前者在双方端口都存在, 且能正常工作时, 也会触发断连. 

后者则是用于, 在对端端口关闭时, 清理本机上的无效连接的.
