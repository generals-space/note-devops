参考文章

1. [网卡虚拟化技术 macvlan 详解](https://www.cnblogs.com/gdg87813/p/13355019.html)
    - macvlan 这种技术听起来有点像 VLAN，但它们的实现机制是完全不一样的。macvlan 子接口和原来的主接口是完全独立的，可以单独配置 MAC 地址和 IP 地址，而 VLAN 子接口和主接口共用相同的 MAC 地址。VLAN 用来划分广播域，而 macvlan 共享同一个广播域。

## 环境准备

VMware Nat网络模式

- vm01: 172.16.91.10/24
- vm02: 172.16.91.14/24

网关与DNS地址都是`172.16.91.2`.

## 示例1.构建网络拓扑

在vm02上执行如下命令

```bash
# 创建两个 macvlan 子接口
ip link add link ens34 dev macvlan1 type macvlan mode private
ip link add link ens34 dev macvlan2 type macvlan mode private

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

1. 在vm01上可以直接ping通`172.16.91.101`和`172.16.91.102`, 反过来也可以.
2. 但是ns01和ns02之间是无法相互ping通的.
3. vm02上也无法直接ping通ns01和ns02.

可以说, 在这个模型下, ns01和ns02就相当于在物理网络中新增了两台主机, 交换机能将ns01和ns02中的macvlan设备当作普通的物理网卡一样对待.

```
        VMware01                                                 VMware02                 
+-------------------+                          +----------------------------------------+
|                   |                          |         ns01                ns02       |
|                   |                          |  +---------------+   +---------------+ |
|                   |                          |  | 172.16.91.101 |   | 172.16.91.102 | |
|                   |                          |  |    macvlan1   |   |    macvlan2   | |
|                   |                          |  +-------┬-------+   +-------┬-------+ |
|                   |                          |          |                   |         |
|                   |                          |          └─────────┬─────────┘         |
|                   |                          |                    |                   |
| +---------------+ |                          |           +--------┴-------+           |
| |172.16.91.10/24| |                          |           |172.16.91.14/24 |           |
| |     ens34     | |                          |           |      ens34     |           |
| +-------┬-------+ |                          |           +--------┬-------+           |
+---------|---------+                          +--------------------|-------------------+
          |          +-----------|----------+                       |                    
          |          |                      |                       |                    
          └─────────>|    172.16.91.2/24    |<──────────────────────┘                    
                     |        Gateway       |
                     +----------------------+
```

注意: vm02上的父接口`ens34`甚至**不需要**开启混杂模式, 就可以接收到目标地址为`ns01`和`ns02`的数据包.
