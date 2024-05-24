# HAProxy-配置项tcpka与tcp_keepalive_xxx机制

参考文章

1. [haproxy tcp keepalive](https://www.cnblogs.com/zhedan/p/14246958.html)
2. [一次对server服务大量积压异常TCP ESTABLISHED链接的排查笔记](https://segmentfault.com/a/1190000018666124)
    - 想要使用 Linux 的 KeepAlive, 需要程序单独做设置进行开启才行。

haproxy的`timeout`字段可以检测双方的空闲连接, 主动断开.

但是这个东西和 tcp keepalive 是两回事.

```log
[root@ly-xjf-r021702-gyt haproxy]# netstat -anop | grep haprox
tcp        0      0 0.0.0.0:6442            0.0.0.0:*               LISTEN      362334/haproxy       off (0.00/0/0)
tcp        0      0 0.0.0.0:12181           0.0.0.0:*               LISTEN      362334/haproxy       off (0.00/0/0)
tcp        0      0 0.0.0.0:11080           0.0.0.0:*               LISTEN      362334/haproxy       off (0.00/0/0)
tcp        0      0 192.168.30.104:43860    192.168.30.104:6443     ESTABLISHED 362334/haproxy       off (0.00/0/0)
tcp        0      0 192.168.30.104:43950    192.168.30.104:6443     ESTABLISHED 362334/haproxy       off (0.00/0/0)
tcp        0      0 192.168.30.104:43878    192.168.30.104:6443     ESTABLISHED 362334/haproxy       off (0.00/0/0)
```

我配置了 timeout, 但是haproxy建立的连接都未启用 keepalive 机制.

按照参考文章2中所说, 想要使用 Linux 的 KeepAlive, 需要程序单独做设置进行开启才行.

在haproxy中, 可以通过`tcpka`选项完成.

## 详细配置

其实开启 tcp keepalive 的选项有3个: tcpka, clitcpka, srvtcpka.

- clitcpka: 仅在客户端和listener的连接上, 启用SO_KEEPALIVE
- srvtcpka: 仅在haproxy和后端的连接上, 启用SO_KEEPALIVE
- tcpka: 配置在defaults/listen中时, 客户端<->listener, haproxy<->后端的连接都会启用`SO_KEEPALIVE`.
    - 单独配置在`frontend`时, 同`clitcpka`; 单独配置在`backend`时同`srvtcpka`;

配置上此选项后, haproxy建立的连接都启动了 tcp keepalive 机制.

```
tcp        0      0 192.168.30.104:6442     172.18.83.104:60128     ESTABLISHED 362334/haproxy       keepalive (7199.63/0/0)
tcp        0      0 192.168.30.104:6442     172.18.83.104:60122     ESTABLISHED 362334/haproxy       keepalive (7184.31/0/0)
tcp        0      0 192.168.30.104:6442     172.22.132.132:62428    ESTABLISHED 362334/haproxy       keepalive (7184.31/0/0)
```
