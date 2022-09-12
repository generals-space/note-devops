# Linux单网卡多IP配置(非虚拟IP)

参考文章

1. [关于linux Centos 7一个网卡配置多个IP的方法](https://www.cnblogs.com/5201351/p/4937953.html)

单网卡多IP, 不是`eth0:1`这种形式, 而是如下这样的.

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:3f:64:dd brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.211/24 brd 192.168.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.0.212/24 brd 192.168.0.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.0.213/24 brd 192.168.0.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe3f:64dd/64 scope link
       valid_lft forever preferred_lft forever
```

使用`ip addr add 192.168.0.211/24 dev eth0`可以向指定网络接口添加多个IP地址, 但本文的重点是, 如何把这样的配置写到网络配置文件, 使之重启不失效.

参考文章1中给出了示例, 实验证明有效

```
IPADDR0=192.168.0.211
IPADDR1=192.168.0.212
IPADDR2=192.168.0.213

NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DEFROUTE=yes
```

> 当然, 只有一个IP时就不用加后缀0, 1, 2了.

多IP并不会影响默认路由, 毕竟是单网卡, 路由条目上根本就没写src字段.

```
default via 192.168.0.1 dev eth0
```