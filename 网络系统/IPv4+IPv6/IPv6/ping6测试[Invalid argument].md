# ping6-测试[Invalid argument]

参考文章

1. [ping6 with "connect: Invalid argument"](https://my.oschina.net/neron/blog/120812)
    - 在 IPv6 地址后加上`%devname`解决(其实`%接口索引值`也是可以的)
2. [Linux ping6 local ipv6 addressInvalid argument，ping6本地ipv6地址出现无效的参数](http://coolnull.com/4429.html)
    - ping本地的ipv6地址时, 需要指定用来发送数据包的网络接口(有点像没有合适路由的时候手动选择出口网卡啊...), 使用`-I`选项指定接口名称.
    - IPv6地址中`FF80`开头的为link-local address, 类似于`192.168.0.0/16`, `169.254.0.0/16`在 IPv4 中的地位.

```console
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:4e:62:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.80.10/24 brd 192.168.80.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe4e:6243/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

```console
## 本地回环地址
$ ping6 ::1
PING ::1(::1) 56 data bytes
64 bytes from ::1: icmp_seq=1 ttl=64 time=0.043 ms
64 bytes from ::1: icmp_seq=2 ttl=64 time=0.081 ms
^C
--- ::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.043/0.062/0.081/0.019 ms
## ens33 局域网地址
$ ping6 fe80::20c:29ff:fe4e:6243
connect: Invalid argument
```

按照参考文章1,2的说法, ping 一个 IPv6 的地址还需要指定走哪个网卡, 看这个样子是 IPv6 不会走路由表一样...

下面两种方式都是正确的.

```console
# %2 也是可以的, 这里的 2 是 ens33 接口的索引值.
# ping6 fe80::20c:29ff:fe4e:6243%2
$ ping6 fe80::20c:29ff:fe4e:6243%ens33
PING fe80::20c:29ff:fe4e:6243%ens33(fe80::20c:29ff:fe4e:6243%ens33) 56 data bytes
64 bytes from fe80::20c:29ff:fe4e:6243%ens33: icmp_seq=1 ttl=64 time=0.146 ms
64 bytes from fe80::20c:29ff:fe4e:6243%ens33: icmp_seq=2 ttl=64 time=0.141 ms
^C
--- fe80::20c:29ff:fe4e:6243%ens33 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.141/0.143/0.146/0.012 ms
```

```console
$ ping6 -I ens33 fe80::20c:29ff:fe4e:6243
PING fe80::20c:29ff:fe4e:6243(fe80::20c:29ff:fe4e:6243) from fe80::20c:29ff:fe4e:6243%ens33 ens33: 56 data bytes
64 bytes from fe80::20c:29ff:fe4e:6243%ens33: icmp_seq=1 ttl=64 time=0.041 ms
64 bytes from fe80::20c:29ff:fe4e:6243%ens33: icmp_seq=2 ttl=64 time=0.066 ms
^C
--- fe80::20c:29ff:fe4e:6243 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.041/0.053/0.066/0.014 ms
```

这只是对于局域网 IPv6 地址来说, 如果是公网地址, 则不需要指定网络接口.
