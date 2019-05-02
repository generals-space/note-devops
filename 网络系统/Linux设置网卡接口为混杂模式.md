# Linux设置网卡接口为混杂模式

参考文章

1. [通过MacVLAN实现Docker跨宿主机互联](http://www.10tiao.com/html/357/201704/2247485101/1.html)

设置混杂模式可以通过`ip`或`ifconfig`指令实现。

## 通过ip指令

设置enp0s5为混杂模式

```
$ ip link set enp0s5  promisc on
```

取消enp0s5的混杂模式

```
$ ip link set enp0s5  promisc off
```

## 通过ifconfig指令

设置enp0s5为混杂模式

```
$ ifconfig enp0s5 promisc
```

取消enp0s5的混杂模式

```
$ ifconfig enp0s5 -promisc
```

验证网卡混杂模式是否设置成功

```
$ ifconfig enp0s5
enp0s5    Link encap:Ethernet  HWaddr 00:1c:42:97:53:2a
          inet addr:192.168.2.210  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::21c:42ff:fe97:532a/64 Scope:Link
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:1059321 errors:0 dropped:145 overruns:0 frame:0
          TX packets:15030 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:785317867 (785.3 MB)  TX bytes:1039141 (1.0 MB)
```

其中`UP BROADCAST RUNNING PROMISC MULTICAST`的PROMISC说明网卡enp0s5已经设置成混杂模式(主要还是`PROMISC`标识).