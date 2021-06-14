# vxlan网络多主机通信

参考文章

1. [[svc]linux上vxlan实战](https://www.cnblogs.com/iiiiher/p/8082779.html)
    - vxlan多播实现多台互通示例(`group 239.1.1.1`)...实践已失败
2. [在 Linux 上配置 VXLAN](https://zhuanlan.zhihu.com/p/53038354)
    - 单对单和多对多两个示例
    - 与参考文章3中的多播示例, 补充了一句`bridge fdb`添加转发表的命令.

## 引言

前一篇文章里, vm1, vm2上的vxlan ip属于同一子网, 不太符合像容器云这样的场景(每个主机划分一个网段, 各拥有多个Pod), 这里就模拟一下容器云的场景.

## 网络环境搭建

环境准备

- vm1: 172.16.91.10/24, vxlan设备地址 10.0.0.2/24
- vm2: 172.16.91.14/24, vxlan设备地址 10.0.1.2/24

vm1

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.0.2/24 dev vxlan0
ip link set vxlan0 up
bridge fdb append to 00:00:00:00:00:00 dst 172.16.91.14 dev vxlan0
```

相应的路由如下

```
10.0.0.0/24 dev vxlan0 proto kernel scope link src 10.0.0.2
```

vm2

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.1.2/24 dev vxlan0
ip link set vxlan0 up
bridge fdb append to 00:00:00:00:00:00 dst 172.16.91.10 dev vxlan0
```

路由如下

```
10.0.1.0/24 dev vxlan0 proto kernel scope link src 10.0.1.2
```

这几个路由根本没办法实现vxlan ip的跨主机通信, 就只能借助fdb转发表了.
