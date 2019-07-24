# tap&tun

参考文章

1. [详解云计算网络底层技术——虚拟网络设备 tap/tun 原理解析](https://www.cnblogs.com/bakari/p/10450711.html)
    - tap/tun的概念与区别
2. [Linux 网络工具详解之 ip tuntap 和 tunctl 创建 tap/tun 设备](https://www.cnblogs.com/bakari/p/10449664.html)
    - `ip tuntap`创建tap和tun设备的操作方式(还有`tunctl`这个命令, 不再建议使用)
3. [利用 Linux tap/tun 虚拟设备写一个 ICMP echo 程序](https://www.cnblogs.com/bakari/p/10474600.html)
    - 以上三篇属于同一作者

先创建tap网络设备tap0.

```
$ ip tuntap add dev tap0 mod tap
$ ip addr ls
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:50:56:ac:33:5e brd ff:ff:ff:ff:ff:ff
    inet 192.168.7.13/24 brd 192.168.7.255 scope global ens32
       valid_lft forever preferred_lft forever
9: tap0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 86:43:50:4b:b0:cc brd ff:ff:ff:ff:ff:ff
```

> 注意: tap0的link类型也是ether.

为其设置IP和路由

```
$ ip addr add 10.18.0.1/24 dev tap0
$ ip addr ls
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:50:56:ac:33:5e brd ff:ff:ff:ff:ff:ff
    inet 192.168.7.13/24 brd 192.168.7.255 scope global ens32
       valid_lft forever preferred_lft forever
9: tap0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 86:43:50:4b:b0:cc brd ff:ff:ff:ff:ff:ff
    inet 10.18.0.1/24 scope global tap0
       valid_lft forever preferred_lft forever
```

此时已经可以ping通过此地址.

