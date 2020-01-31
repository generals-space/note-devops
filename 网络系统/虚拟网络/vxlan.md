参考文章

1. [什么是 VxLAN？](https://segmentfault.com/a/1190000019662412)
    - 系列文章1
    - 对vxlan的概念及工作流程解释得非常清晰, 且对vlan与vxlan各自的擅长的场景做了比较.
2. [Linux 下实践 VxLAN](https://segmentfault.com/a/1190000019905778)
    - 系列文章2
    - 第一个点对点示例很清晰, 但是第二个docker容器示例不太具有一般性.
    - 第二个示例中由于`remote`选项的使用, 无法实现多物理机场景入网.
3. [[svc]linux上vxlan实战](https://www.cnblogs.com/iiiiher/p/8082779.html)
    - vxlan多播实现多台互通示例(`239.1.1.1`)

vxlan将 L2 的以太网帧（Ethernet frames）封装成 L4 的 UDP 数据报（datagrams），然后在 L3 的网络中传输.

一台物理机上可能存在多个虚拟机, ta们同时存在于vxlan网络中, 物理机上会存在一个`vtep`设备, 叫做 VxLAN 隧道端点(VxLAN Tunnel Endpoint)，是 VxLAN 协议中将对原始数据包进行封装和解封装的设备. 按照参考文章2中所说, 使用`ip link`添加的vxlan设备就被称为`vtep`.

vxlan中的`vni`类似于vlan网络中的vlan id, 就是叫法不同而已.

参考文章2中在使用`ip link`添加vxlan类型的网络接口时的`dstport`参数为udp包发送的目标端口值.

------

环境

vm1: 172.16.91.128, vxlan地址 10.0.0.1
vm2: 172.16.91.129, vxlan地址 10.0.0.2

vm1

```console
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.0.1/24 dev vxlan0
ip link set vxlan0 up
```

vm2

```console
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.0.2/24 dev vxlan0
ip link set vxlan0 up
```

> 注意关闭双方防火墙.

`ip link add`创建vxlan设备时, `id`参数即`VNI`.

------

创建vxlan设备并启动后, 可以查看到udp端口的开放状态, 之后vxlan通过udp包封装后就是通过这个端口通信的.

```console
$ ss -anp | grep 4789                                              Wed Jan 29 01:58:07 2020
udp    UNCONN     0	 0         *:4789                  *:*
```

