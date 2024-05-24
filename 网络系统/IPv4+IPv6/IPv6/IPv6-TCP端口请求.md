# IPv6-TCP端口请求

参考文章

1. [IPv6地址在URL上的格式](https://www.cnblogs.com/hdtianfu/p/3159556.html)

IPv4

nc可以同时监听 IPv4/IPv6 的端口, 不会冲突. 不过 IPv4 的全局地址是 `0.0.0.0`, 而 IPv6 的全局地址为 `::0`. 对应的, IPv4 的回环地址为 `127.0.0.1`, IPv6 的回环地址为`::1`.

以下是使用 nc 同时监听 IPv4/IPv6 下 80 端口的实验, 并分别使用 IPv4/IPv6 进行连接.

![服务端](https://gitee.com/generals-space/gitimg/raw/master/E0D10C8C6CD57F5A731EA99872BFA1CA.png)

![客户端](https://gitee.com/generals-space/gitimg/raw/master/326F55AD522684846C8FD792CC9723A7.png)

其他的工具, 像`telnet`, `curl`等, 用法也基本没差, 本质上都是交给内核协议栈去完成的事.

```log
$ ping www.google.com
PING www.google.com(ord30s25-in-x04.1e100.net (2607:f8b0:4009:80e::2004)) 56 data bytes
64 bytes from ord30s25-in-x04.1e100.net (2607:f8b0:4009:80e::2004): icmp_seq=1 ttl=42 time=16.9 ms
64 bytes from ord30s25-in-x04.1e100.net (2607:f8b0:4009:80e::2004): icmp_seq=2 ttl=42 time=16.10 ms
^C
--- www.google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 16.886/16.933/16.980/0.047 ms
```

```log
$ telnet 2607:f8b0:4009:80e::2004 80
Trying 2607:f8b0:4009:80e::2004...
Connected to 2607:f8b0:4009:80e::2004.
Escape character is '^]'.
```

不过 curl 有点问题

```log
$ curl https://2607:f8b0:4009:811::2004:443
curl: (3) IPv6 numerical address used in URL without brackets
```

上面的URL中, 无法分清 IPv6 和端口号, 所以 IPv6 在用于 URL 时需要按照指定格式来写.

