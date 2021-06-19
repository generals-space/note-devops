参考文章

1. [网卡虚拟化技术 macvlan 详解](https://www.cnblogs.com/gdg87813/p/13355019.html)
    - macvlan 这种技术听起来有点像 VLAN，但它们的实现机制是完全不一样的。macvlan 子接口和原来的主接口是完全独立的，可以单独配置 MAC 地址和 IP 地址，而 VLAN 子接口和主接口共用相同的 MAC 地址。VLAN 用来划分广播域，而 macvlan 共享同一个广播域。
2. [Linux 虚拟网卡技术：Macvlan](https://juejin.cn/post/6844903810851143693)

VMware Nat网络模式

- vm01: 172.16.91.10/24
- vm02: 172.16.91.14/24

网关与DNS地址都是`172.16.91.2`.

## 构建网络拓扑

在vm02上执行如下命令

```bash
# 创建两个 macvlan 子接口
ip link add link ens34 dev macvlan1 type macvlan mode vepa
ip link add link ens34 dev macvlan2 type macvlan mode vepa

# 创建两个 namespace
ip netns add ns01
ip netns add ns02

# 将两个子接口分别挂到两个 namespace 中
ip link set macvlan1 netns ns01
ip link set macvlan2 netns ns02

# 配置 IP 并启用
ip netns exec ns01 ip addr add 172.16.91.101/24 dev macvlan1
ip netns exec ns01 ip link set macvlan1 up

ip netns exec ns02 ip addr add 172.16.91.102/24 dev macvlan2
ip netns exec ns02 ip link set macvlan2 up
```

> 两个macvlan网卡配置的IP地址与物理网络的地址在同一子网.

## 示例1.网络表现

与private模式相比, 几乎没有什么区别, 仍然是相当于直接接入物理网络, 但是ns01与ns02, 宿主机与ns01/ns02之间无法通信.

```
        VMware01                                                 VMware02                 
+-------------------+                          +----------------------------------------+
|                   |                          |         ns01                ns02       |
|                   |                          |  +---------------+   +---------------+ |
|                   |                          |  | 172.16.91.101 |   | 172.16.91.102 | |
|                   |                          |  |    macvlan1   |   |    macvlan2   | |
|                   |                          |  +-------┬-------+   +-------┬-------+ |
|                   |                          |          |                   |         |
|                   |                          |        1 └─────────┬─────────┘ 4       |
|                   |                          |                    |                   |
| +---------------+ |                          |           +--------┴-------+           |
| |172.16.91.10/24| |                          |           |172.16.91.14/24 |           |
| |     ens34     | |                          |           |      ens34     |           |
| +-------┬-------+ |                          |           +--------┬-------+           |
+---------|---------+                          +--------------------|-------------------+
          |          +-----------|----------+                       |                    
          |          |                      |             2         |                    
          └─────────>|    172.16.91.2/24    |<──────────────────────┘                    
                     |        Gateway       |                      3
                     +----------------------+
```


但是按照各个文章对`vepa`的说法, 在这种模式下, ns01和ns02之间理论上是可以通信的, 只不过数据包的路径会有些奇怪, 以ns01->ns02为例, 

1. 数据包会先到达父接口`ens34`
    - `vepa`模式下, 不管目标地址是哪, macvlan接口的所有(二层)流量都会直接发送到父接口.
2. 父接口上可以捕获到来自`ns01`的arp广播包, 用于询问`172.16.91.102`的是哪个, 但是没有回包.


------


但是由于我的测试环境是vmware虚拟机, vswitch不支持`hairpin`, 所以在第2步就卡住了, 在宿主机vm02上抓取物理网卡`ens34`上的arp流量, 发现有如下输出.

```console
$ tcpdump -nve -i ens34 arp
tcpdump: listening on ens34, link-type EN10MB (Ethernet), capture size 262144 bytes
18:10:22.341924 26:10:84:17:90:d2 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.91.102 tell 172.16.91.102, length 28
18:10:23.343292 26:10:84:17:90:d2 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.91.102 tell 172.16.91.102, length 28
```

ns02根本没有回应ns01的arp, 就更没有后面的步骤了.
