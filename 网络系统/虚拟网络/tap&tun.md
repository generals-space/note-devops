# tap&tun

参考文章

1. [详解云计算网络底层技术——虚拟网络设备 tap/tun 原理解析](https://www.cnblogs.com/bakari/p/10450711.html)
    - tap/tun的概念与区别
2. [Linux 网络工具详解之 ip tuntap 和 tunctl 创建 tap/tun 设备](https://www.cnblogs.com/bakari/p/10449664.html)
    - `ip tuntap`创建tap和tun设备的操作方式(还有`tunctl`这个命令, 不再建议使用)
3. [利用 Linux tap/tun 虚拟设备写一个 ICMP echo 程序](https://www.cnblogs.com/bakari/p/10474600.html)
    - 以上三篇属于同一作者
4. [Linux内核网络设备——tun、tap设备](http://blog.nsfocus.net/linux-tun-tap/)
    - tcp/ip协议栈分层和netdevice子系统, ASCII模型图, 比较详细
    - C语言测试代码...不过是图片版的
5. [Linux虚拟网络设备之tun/tap](https://segmentfault.com/a/1190000009249039)
    - 同样是ASCII模型图
    - C语言测试代码
6. [Linux的TUN/TAP编程](http://blog.chinaunix.net/uid-317451-id-92474.html)
    - `lsmod | grep tun`查看是否加载tun驱动

参考文章3, 4, 5都有用C语言模拟`tun`设备的示例. 简单来说就是

1. 打开一个字符设备, 注册为`tun`类型, 监听;
2. 使用`ip`命令赋予IP(与宿主机不在同一网段, 一般是一个不存在的网络, 如10.18.0.2/24)并启动(启动后自动注册路由);
3. ping这个IP所在网段的其他IP(比如10.18.0.3), 当然是ping不通的, 但是使用`tcpdump`监听这个`tun`设备, 可以看到ping的请求包(没有响应包).

但是使用`ip`命令无法打印ping请求包...

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

为其设置IP

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

此时已经可以ping通过此地址, 但还没有路由信息.

启动此设备后可以自动添加路由.

```
$ ip addr add 10.18.0.2/24 dev tap0
$ ip route ls
default via 192.168.7.1 dev ens32 proto static metric 100
10.18.0.0/24 dev tap0 proto kernel scope link src 10.18.0.2
192.168.7.0/24 dev ens32 proto kernel scope link src 192.168.7.13 metric 100
192.169.0.0/24 dev docker0 proto kernel scope link src 192.169.0.1
```

此时使用`tcpdump -i tap0`, 在另一个终端ping`10.18.0.3`, 即tap0设备所在网络的另一个地址, 理论上应该会经过该设备转发出去, 但是`tcpdump`部分没有看到任何输出, 这一点与C语言的程序示例表现不同, 也许是因为设备另一端没有接收方, 所以信息被阻塞了?
