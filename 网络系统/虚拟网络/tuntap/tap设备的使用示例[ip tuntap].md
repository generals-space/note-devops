
先创建tap网络设备`tap0`.

```console
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

启动此设备, 启动后会自动添加到其相应网段的路由.

```
$ ip addr add 10.18.0.2/24 dev tap0
$ ip route ls
default via 192.168.7.1 dev ens32 proto static metric 100
10.18.0.0/24 dev tap0 proto kernel scope link src 10.18.0.2
192.168.7.0/24 dev ens32 proto kernel scope link src 192.168.7.13 metric 100
192.169.0.0/24 dev docker0 proto kernel scope link src 192.169.0.1
```

此时使用`tcpdump -i tap0`进行抓包, 然后在另一个终端ping`10.18.0.3`, 即`tap0`设备所在网络的另一个地址, 理论上应该会经过该设备转发出去, 但是`tcpdump`部分没有看到任何输出, 这一点与C语言的程序示例表现不同, 也许是因为设备另一端没有接收方, 所以信息被阻塞了?
