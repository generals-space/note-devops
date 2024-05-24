# vxlan网络多主机通信

参考文章

1. [什么是 VxLAN？](https://segmentfault.com/a/1190000019662412)
    - 系列文章1
    - 对vxlan的概念及工作流程解释得非常清晰, 且对vlan与vxlan各自的擅长的场景做了比较.
2. [Linux 下实践 VxLAN](https://segmentfault.com/a/1190000019905778)
    - 系列文章2
    - 第一个点对点示例很清晰, 但是第二个docker容器示例不太具有一般性.
    - 第二个示例中由于`remote`选项的使用, 属于单对单通信, 无法实现多物理机场景入网.
3. [[svc]linux上vxlan实战](https://www.cnblogs.com/iiiiher/p/8082779.html)
    - vxlan多播实现多台互通示例(`group 239.1.1.1`)...实践已失败
4. [在 Linux 上配置 VXLAN](https://zhuanlan.zhihu.com/p/53038354)
    - 单对单和多对多两个示例
    - 与参考文章3中的多播示例, 补充了一句`bridge fdb`添加转发表的命令.

## 引言

> `VxLAN`将`L2`的以太网帧(Ethernet frames)封装成 L4 的 UDP 数据报(datagrams), 然后在`L3`的网络中传输.

一台物理机上可能存在多个虚拟机, ta们同时存在于`VxLAN`网络中, 物理机上会存在一个`vtep`设备, 叫做**VxLAN 隧道端点(VxLAN Tunnel Endpoint)**, 是`VxLAN`协议中将对原始数据包进行封装和解封装的设备. 按照参考文章2中所说, 使用`ip link`添加的`vxlan`设备就被称为`vtep`.

`VxLAN`中的`vni`类似于vlan网络中的`vlan id`, 就是叫法不同而已. `ip link add`创建`vxlan`设备时, `id`参数即`VNI`.

参考文章2中在使用`ip link`添加`vxlan`类型的网络接口时的`dstport`参数为`udp`包发送的目标端口值.

## 网络环境搭建

环境准备

- vm1: 172.16.91.128/24, vxlan设备地址 10.0.0.1/24
- vm2: 172.16.91.129/24, vxlan设备地址 10.0.0.2/24

vm1

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.0.1/24 dev vxlan0
ip link set vxlan0 up
```

vm2

```bash
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev eth0
ip addr add 10.0.0.2/24 dev vxlan0
ip link set vxlan0 up
```

> 注意关闭双方防火墙.

> `239.1.1.1`就是多播IP.

创建`vxlan`设备并启动后, 会新增一条到`10.0.0.0/24`的路由, 并且可以查看到`udp`端口的开放状态, 之后`vxlan`通过`udp`包封装后就是通过这个端口通信的.

```log
$ ip r
...省略
10.0.0.0/24 dev vxlan0 proto kernel scope link src 10.0.0.1
...省略
$ netstat -nlp | grep 4789
udp        0      0 0.0.0.0:4789            0.0.0.0:*                           -
```

网络拓扑如下

```
+---------------------------+                      +---------------------------+
|   10.0.0.1/24             |                      |             10.0.0.2/24   |
|  +------------+           |                      |           +------------+  |
|  |   vxlan0   |           |                      |           |   vxlan0   |  |
|  +-----┬------+           |                      |           +------┬-----+  |
|        |      +--------+  |                      |  +--------+      |        |
|        └─────>|  eht0  |  |                      |  |  eht0  |<─────┘        |
|               +----┬---+  |                      |  +----┬---+               |
|  172.16.91.128/24  |      |                      |       |  172.16.91.129/24 |
+--------------------|------+                      +-------|-------------------+
                     |        +------------------+         |                             
                     └───────>|  172.16.91.1/24  |<────────┘                             
                              +------------------+
                                    网关/路由器
```

目标地址为`10.0.0.2/24`数据包从`10.0.0.1/24`发出, 进入路由, 经由`vxlan0`设备处理, 封装为UDP包, 以广播包形式流入`eht0`然后发出, 响应包则是单播消息.

如下, 从vm1中`ping 10.0.0.2`, 不过此时是ping不通的. 

```log
$ tcpdump -nve -i eth0 udp

17:12:05.831569 00:0c:29:28:37:29 > 01:00:5e:01:01:01, ethertype IPv4 (0x0800), length 92: (tos 0x0, ttl 1, id 24985, offset 0, flags [none], proto UDP (17), length 78)
    172.16.91.128.36642 > 239.1.1.1.4789: VXLAN, flags [I] (0x08), vni 42
e6:0d:35:61:51:0f > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.0.2 tell 10.0.0.1, length 28

17:12:05.832339 00:0c:29:f1:2e:03 > 00:0c:29:28:37:29, ethertype IPv4 (0x0800), length 92: (tos 0x0, ttl 64, id 4409, offset 0, flags [none], proto UDP (17), length 78)
    172.16.91.129.47666 > 172.16.91.128.4789: VXLAN, flags [I] (0x08), vni 42
36:64:80:a2:4a:31 > e6:0d:35:61:51:0f, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.0.0.2 is-at 36:64:80:a2:4a:31, length 28
```

> 在vm1上抓包, 协议类型选择`icmp`时无法捕获数据, 需要捕获`udp`包.

## bridge fdb 添加转发表

要组成同一个 vxlan 网络, VTEP 就必须能感知到彼此的存在. 上面`ping`不通, 是因为数据包根本没路由能到vm2.

参考文章4给出了在二层让主机互通的方法, 就是通过添加转发表来完成, 在 vm1 和 vm2 上分别执行如下命令:

vm1: `bridge fdb append to 00:00:00:00:00:00 dst 172.16.91.129 dev vxlan0`

vm2: `bridge fdb append to 00:00:00:00:00:00 dst 172.16.91.128 dev vxlan0`

~~看起来像是让到达vxlan0的数据包, 都可以通过二层广播包广播出去.~~

`fdb`表项是让`vxlan0`的`ARP`报文能够到达目标机器上, 从而获取 MAC地址, 才能完成接下来的通信.

现在就可以ping通了, 可以使用`tcpdump`再查看一番.

不过话又说回来了, 这要是组成一个100节点的网络, 每台机器都要维护99个fdb转发表了, 所以真实的场景应该不是这种形式的.

------

上述场景是每台物理机上只创建一个vxlan设备的场景, flannel那种基于 vxlan 的网络模型是怎样的? 毕竟一台主机上有那么多容器呢, 共用同一个vxlan设备???
