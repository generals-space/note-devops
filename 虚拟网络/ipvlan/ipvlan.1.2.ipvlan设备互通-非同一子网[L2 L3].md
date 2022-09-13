# ipvlan.1.2.ipvlan设备互通-非同一子网[L2 L3]

参考文章

1. [Macvlan 和 IPvlan](https://www.cnblogs.com/menkeyi/p/11374023.html)
    - IPvlan分为两种工作模式: L2/L3

上一篇文章对ipvlan的介绍就已经很清楚了, 本文是为了更明确地认识ipvlan的特性.

## 环境准备

VMware Nat网络模式

- vm01: 172.16.91.10/24
- vm02: 172.16.91.14/24

网关与DNS地址都是`172.16.91.2`.

## L2 vs L3 - Round 2(非同一子网)

### L2

在vm02上执行如下命令, 创建两个ipvlan设备, 并分别放入2个ns中.

```bash
ip link add link ens34 ipvlan1 type ipvlan mode l2
ip link add link ens34 ipvlan2 type ipvlan mode l2

## 创建ns
ip net add ns01
ip net add ns02

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns ns01
ip link set ipvlan2 netns ns02

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec ns01 ip addr add 192.168.2.10/24 dev ipvlan1
ip net exec ns02 ip addr add 192.168.3.10/24 dev ipvlan2
ip net exec ns01 ip link set ipvlan1 up
ip net exec ns02 ip link set ipvlan2 up
```

```
ip link add link ens34 ipvlan0 type ipvlan mode l2
ip addr add 192.168.4.10/32 dev ipvlan0
ip link set ipvlan0 up
```

网络拓扑如下

```
        VMware01                                                 VMware02                 
+-------------------+              +-------------------------------------------------------------------+
|                   |              |         ns01                                          ns02        |
|                   |              |  +----------------+   +-----------------+     +----------------+  |
|                   |              |  |192.168.2.10/24 |   | 192.168.4.10/24 |     | 192.168.3.10/24|  |
|                   |              |  |    ipvlan1     |   |     ipvlan0     |     |     ipvlan2    |  |
|                   |              |  +-------┬--------+   +--------┬--------+     +--------┬-------+  |
|                   |              |          |                     |                       |          |
|                   |              |      +---|---------------------|-----------------------|---+      |
|                   |              |      |   |          Network    |    Stack              |   |      |
|                   |              |      +---|---------------------|-----------------------|---+      |
|                   |              |      |   |         L3          |            L3         |   |      |
|                   |              |      +---|---------------------|-----------------------|---+      |
|                   |              |      |   └         L2          ┴            L2         ┘   |      |
|                   |              |      +---|---------------------|-----------------------|---+      |
|                   |              |          |                     |                       |          |
|                   |              |          └─────────────────────┼───────────────────────┘          |
|                   |              |                                |                                  |
| +---------------+ |              |                       +--------┴--------+                         |
| |172.16.91.10/24| |              |                       | 172.16.91.14/24 |                         |
| |     ens34     | |              |                       |      ens34      |                         |
| +-------┬-------+ |              |                       +--------┬--------+                         |
+---------|---------+              +--------------------------------|----------------------------------+
          |          +-----------|----------+                       |                    
          |          |                      |                       |                    
          └─────────>|    172.16.91.2/24    |<──────────────────────┘                    
                     |        Gateway       |
                     +----------------------+
```

注意, L2的ipvlan在网络协议栈的L2层连通, 但是ta们并不是直接连接在一个bridge设备上, 协议栈L2并没有义务为每个ipvlan设备创建转发表. 

所以ipvlan设备之间如果不属于同一子网, 是没办法像2层直连的机器一样直接通信的. `ns01`中ping`ns02`时, 会显示`connect: 网络不可达`, 需要额外设置路由.

```bash
## 设置默认路由
ip net exec ns01 ip route add default dev ipvlan1
ip net exec ns02 ip route add default dev ipvlan2
```

此时的网络连通表现如下

- [x] ns01 <-------> ns02
- [ ] ns01/ns02 <--> vm01(`172.16.91.10`)
- [ ] ns01/ns02 <--> Gateway(`172.16.91.2`)
- [ ] ns01/ns02 <--> vm02.ipvlan0(`192.168.4.10`)
- [ ] ns01/ns02 ---> vm02.ens34(`172.16.91.14`)

继续添加路由

```
ip r add 192.168.2.10 dev ipvlan0
ip r add 192.168.3.10 dev ipvlan0
```

网络连通表现如下

- [x] ns01 <-------> ns02
- [ ] ns01/ns02 <--> vm01(`172.16.91.10`)
- [ ] ns01/ns02 <--> Gateway(`172.16.91.2`)
- [x] ns01/ns02 <--> vm02.ipvlan0(`192.168.4.10`)
- [ ] ns01/ns02 ---> vm02.ens34(`172.16.91.14`)

------

最开始不明白为什么这次ns01/ns02无法ping通vm01和网关了, 直到完成ipvlan的ns与宿主机通信实验, 想起来修改`rp_filter`配置

```
echo 2 > /proc/sys/net/ipv4/conf/ens34/rp_filter
```

网络连通表现如下

- [x] ns01 <-------> ns02
- [ ] ns01/ns02 <--> vm01(`172.16.91.10`)
- [x] ns01/ns02 <--> Gateway(`172.16.91.2`)
- [x] ns01/ns02 <--> vm02.ipvlan0(`192.168.4.10`)
- [ ] ns01/ns02 ---> vm02.ens34(`172.16.91.14`)

至于为什么ns01/ns02仍然未能与vm01相互通信, 那是因为vm01上没有配置到`192.168.2.0/24`和`192.168.3.0/24`网段的路由, icmp request包到了vm01也没法响应...

## L3

L3的实验命令与实验表现与上面的示例没有区别, 本文主要是为了弄明白, 为什么L2的ipvlan在不同网段的IP配置下, 还需要配置路由才能相互ping通...上文已经给出解释了.

首先将网络重置, 然后执行如下命令

```bash
ip link add link ens34 ipvlan1 type ipvlan mode l3
ip link add link ens34 ipvlan2 type ipvlan mode l3

## 创建ns
ip net add ns01
ip net add ns02

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns ns01
ip link set ipvlan2 netns ns02

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec ns01 ip addr add 192.168.2.10/24 dev ipvlan1
ip net exec ns02 ip addr add 192.168.3.10/24 dev ipvlan2
ip net exec ns01 ip link set ipvlan1 up
ip net exec ns02 ip link set ipvlan2 up
```

```
ip link add link ens34 ipvlan0 type ipvlan mode l3
ip addr add 192.168.4.10/24 dev ipvlan0
ip link set ipvlan0 up
```
