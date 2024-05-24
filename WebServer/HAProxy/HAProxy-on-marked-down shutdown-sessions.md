# HAProxy-on-marked-down shutdown-sessions

参考文章

1. [问题排查：haproxy tcp 长连接没有 failover](http://blog.cipherc.com/2019/11/10/%E9%97%AE%E9%A2%98%E6%8E%92%E6%9F%A5%EF%BC%9Ahaproxy-tcp-%E9%95%BF%E8%BF%9E%E6%8E%A5%E6%B2%A1%E6%9C%89-failover/)
2. [Haproxy continue to route sessions to a backend marked as down](https://stackoverflow.com/questions/27550531/haproxy-continue-to-route-sessions-to-a-backend-marked-as-down)

问题排查：haproxy tcp 长连接没有 failover

## 现象

客户端 192.168.1.35:1234 和 haproxy 监听的 192.168.1.100:81 端口建立长连接；

haproxy 有两个后端，192.168.1.38:81、192.168.1.29:81，
因为工作在非透明模式，假设这个长连接，是和 192.168.1.29:81 建立的。

客户端长连接建立后，在 haproxy 上能看到两个 keepalive 连接：

```
# netstat -anpto | grep "\:81" | grep keepalive
tcp        0      0 192.168.1.100:42554     192.168.1.29:81         ESTABLISHED 9943/haproxy     keepalive (30.28/0/0)
tcp        0      0 192.168.1.39:81         192.168.1.35:43620      ESTABLISHED 9943/haproxy     keepalive (30.28/0/0)
```

这时，可以在 haproxy 上加一个 iptables 规则：

```
iptables -A OUTPUT -d 192.168.1.29 -m tcp -p tcp --dport 81 -j DROP
```

来模拟后端宕机的情况。

当 192.168.1.29:81 断开时，haproxy 能快速地检测到后端宕机，并修改状态：

```log
root@i-hv6jj9ay:~# /usr/local/bin/lb-collect 'show status'
lbb-0vo2fiec|UP
lbb-811tmjow|UP
lbb-v8y2j191|UP 1/2
root@i-hv6jj9ay:~# /usr/local/bin/lb-collect 'show status'
lbb-0vo2fiec|UP
lbb-811tmjow|UP
lbb-v8y2j191|DOWN
root@i-hv6jj9ay:~#
```

但这个客户端的长连接没有正常断开，并且hang住了。

也就是说，haproxy 没有对这种长连接的场景做 failover。

## 分析

haproxy 的长连接配置，有个隧道超时时间设置，

这个参数，表示长连接的两端，空闲多久后，会被认为是连接已中断。所以也不能改太小。

### timeout tunnel

```
The tunnel timeout applies when a bidirectional connection is established
between a client and a server, and the connection remains inactive in both
directions. This timeout supersedes both the client and server timeouts once
the connection becomes a tunnel. In TCP, this timeout is used as soon as no
analyser remains attached to either connection (eg: tcp content rules are
accepted). In HTTP, this timeout is used when a connection is upgraded (eg:
when switching to the WebSocket protocol, or forwarding a CONNECT request
to a proxy), or after the first response when no keepalive/close option is
specified.

Since this timeout is usually used in conjunction with long-lived connections,
it usually is a good idea to also set “timeout client-fin” to handle the
situation where a client suddenly disappears from the net and does not
acknowledge a close, or sends a shutdown and does not acknowledge pending
data anymore. This can happen in lossy networks where firewalls are present,
and is detected by the presence of large amounts of sessions in a FIN_WAIT
state.
```

### on-marked-down

Modify what occurs when a server is marked down.

Currently one action is available:

```
shutdown-sessions: Shutdown peer sessions. When this setting is enabled,
all connections to the server are immediately terminated when the server
goes down. It might be used if the health check detects more complex cases
than a simple connection status, and long timeouts would cause the service
to remain unresponsive for too long a time. For instance, a health check
might detect that a database is stuck and that there’s no chance to reuse
existing connections anymore. Connections killed this way are logged with
a ‘D’ termination code (for “Down”).
```

这个参数，默认是disabled的。

测试发现，对于一个keepalive的长连接，如果backend能够在宕机后的一定时间（也就是tunnel timeout）内及时恢复，那么这个长连接是还能够继续的。

所以这个参数，默认没有配置成enabled。

## 解决

配置 default-server on-marked-down shutdown-sessions，

```
default-server on-marked-down shutdown-sessions
server  lbb-811tmjow 192.168.1.29:81 check inter 200 fall 1 rise 1 weight 1
server  lbb-v8y2j191 192.168.1.38:81 check inter 200 fall 1 rise 1 weight 1
```

或者是配置在某个特定的`server`里，

```
# default-server on-marked-down shutdown-sessions
server  lbb-811tmjow 192.168.1.29:81 check inter 200 fall 1 rise 1 weight 1
server  lbb-v8y2j191 192.168.1.38:81 check inter 200 fall 1 rise 1 weight 1 on-marked-down shutdown-sessions
```

来确保当一个后端下线时，与这个后端相关的连接都会直接断掉。

## 参考

[on-marked-down](https://cbonte.github.io/haproxy-dconv/1.6/configuration.html#5.2-on-marked-down)

[Tcp keepalive connection not failover](https://discourse.haproxy.org/t/tcp-keepalive-connection-not-failover/4486/3)
