# vxlan网络多主机通信

参考文章

1. [[svc]linux上vxlan实战](https://www.cnblogs.com/iiiiher/p/8082779.html)
    - vxlan多播实现多台互通示例(`group 239.1.1.1`)...实践已失败
2. [在 Linux 上配置 VXLAN](https://zhuanlan.zhihu.com/p/53038354)
    - 单对单和多对多两个示例
    - 与参考文章3中的多播示例, 补充了一句`bridge fdb`添加转发表的命令.

## 引言

前一篇文章里, 需要通过`bridge fdb append`在vxlan设备上添加转发表项, 在二层解决同一网络内vxlan设备无法直接互通的问题.

这里借鉴了flannel的vxlan的网络模型, 通过设置属性为`onlink`的路由, 实现同样的功能.

## 网络环境搭建

环境准备

- vm1: 172.16.91.10/24, vxlan设备地址 192.168.0.0/32
- vm2: 172.16.91.14/24, vxlan设备地址 192.168.1.0/32

vm1

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 192.168.0.0/32 dev vxlan0
ip link set vxlan0 up
```

手动添加路由如下

```
ip r add 192.168.1.0/24 via 192.168.1.0 dev vxlan0 onlink
```

> `onlink`要求内核不检查下一跳地址是否相连, 即在路由时不检查下一跳地址通过dev设备是否可达, 借鉴自flannel的vxlan网络模型.

vm2

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 192.168.1.0/32 dev vxlan0
ip link set vxlan0 up
```

手动添加路由如下

```
ip r add 192.168.0.0/24 via 192.168.0.0 dev vxlan0 onlink
```

然后在vm1上可以ping通`192.168.1.0`.

------

上面两个vxlan设备的IP地址是各自网段的网络号, 直接ping通好像也不是那么有说服力, 可以用如下命令, 在vm1上添加一个虚拟网卡

```
ifconfig eth0:0 192.168.0.10/24 up
```

然后在vm2上ping这个地址, 仍然能ping通, 说明网络模型有效.
