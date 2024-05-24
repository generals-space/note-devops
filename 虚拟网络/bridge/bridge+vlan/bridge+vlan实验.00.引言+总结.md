# bridge+vlan实验.00.引言+总结

参考文章

1. [《每天5分钟玩转 OpenStack》教程目录](https://www.jianshu.com/p/4c06dff6cea8)
    - 系列教程目录
2. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces]()
    - [I](https://linux-blog.anracom.com/2017/10/30/fun-with-veth-devices-in-unnamed-linux-network-namespaces-i/)
        - lxc, cgroup, namespace等技术引言
    - [II](https://linux-blog.anracom.com/2017/11/12/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-ii/)
        - 实验索引(一共8个)
    - [III](https://linux-blog.anracom.com/2017/11/14/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iii/)
        - 使用bridge+veth连接两个netns
    - [IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
        - 在veth设备的一端创建vlan子接口时, 是否另一端也必须使用vlan子接口?
        - 什么情况下可以只在veth设备一端使用vlan子接口?
        - `veth`和`veth vlan`哪种可以用来连接到bridge设备? 如果都可以, 会有什么不同?
    - [V](https://linux-blog.anracom.com/2017/11/21/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-v/)
    - [VI](https://linux-blog.anracom.com/2017/11/28/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vi/)
    - [VII](https://linux-blog.anracom.com/2017/12/30/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vii/)
    - [VIII](https://linux-blog.anracom.com/2018/01/05/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-viii/)
    - 这一系列的文章从内容上来说非常棒, 但作者好像是个德国人, 英文句法看得人一脸萌b, 很多错别字, 阅读障碍相当不小...
    - 从veth设备创建vlan子设备(`ip link add link veth1 name veth1.100 type vlan id 100`)

为了介绍 bridge vlan 的作用及使用方法, 我们构思了一场这样的实验.

首先从一个没有 vlan 的虚拟网络说起.

## 实验网络初始化

```bash
ip netns add ns01
ip netns add ns02
ip netns add ns03

ip link add veth11 type veth peer name veth31
ip link add veth22 type veth peer name veth32

ip link set veth11 netns ns01
ip link set veth22 netns ns02
ip link set veth31 netns ns03
ip link set veth32 netns ns03

ip netns exec ns01 ip addr add 10.1.1.3/24 dev veth11
ip netns exec ns02 ip addr add 10.1.1.4/24 dev veth22
ip netns exec ns01 ip link set veth11 up
ip netns exec ns02 ip link set veth22 up
ip netns exec ns03 ip link set veth31 up
ip netns exec ns03 ip link set veth32 up
```

在`ns03`中创建并配置`bridge`, 并将`veth31`与`veth32`接入.

```bash
ip netns exec ns03 ip link add mybr0 type bridge
ip netns exec ns03 ip link set mybr0 up
ip netns exec ns03 ip link set veth31 master mybr0
ip netns exec ns03 ip link set veth32 master mybr0
```

此时网络拓扑如下

```
+-------------+-------------------------------------------------------+
|    ns01     |                   ns03                  |    ns02     |
| 10.1.1.3/24 |                                         | 10.1.1.4/24 |
|  +-------+  |  +-------+     +-------+     +-------+  |  +-------+  |
|  | veth11|  |  |veth31 | <-> | mybr0 | <-> | veth32|  |  | veth22|  |
|  +---↑---+  |  +---↑---+     +-------+     +---↑---+  |  +---↑---+  |
|      └─────────────┘                           └─────────────┘      |
+-------------+-----------------------------------------+-------------+
```

在`ns01`和`ns02`中相互是可以ping通的.

bridge(网桥, 交换机) 是一个二层设备, 接入同一 bridge 的 veth 设备, 只要IP为同一网段, 那么在进行 ping 操作时, 会直接发 arp 包确认后直接发请求, 不需要经过路由, 所以也不需要设置网关.

由于上面两个设备IP为同一网段, 所以即使在没有网关(不一定非得是`10.1.1.1/24`, 不过此场景中并未指定)的情况下, 光靠`arp`二层包就可以都完成通信.

所以, 我们之后的操作, 都沿用这样的网络结构.

接下来我们创建vlan设备, 尝试阻隔ta们之间的二层包.

## vlan 的影响

首先打开 bridge 的 vlan 过滤功能

```
ip netns exec ns03 ip link set dev mybr0 type bridge vlan_filtering 1
```

此时bridge中的vlan配置如下

```log
$ bridge vlan show
port	vlan ids
veth31	 1 PVID Egress Untagged
veth32	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

`ns01`和`ns02`仍然是可以相互ping通的.


------

然后在通信方的一端, 创建vlan设备.

```
ip netns exec ns01 ip addr del 10.1.1.3/24 dev veth11
ip netns exec ns01 ip r flush dev veth11

ip netns exec ns01 ip link add link veth11 name veth11.100 type vlan id 100
ip netns exec ns01 ip addr add 10.1.1.3/24 dev veth11.100
ip netns exec ns01 ip link set veth11.100 up
```

此时双方已经ping不通了, 网络拓扑如下

从 ns01 中 ping 10.1.1.4, 发出的数据包将带有值为 100 的 vlan tag, 在 mybr0 上没有抓到 arp 包, 说明数据包根本没流入 bridge.

数据包流向: veth11 -> veth31 -🚫> mybr0 -> veth32 -> veth22

## bridge vlan 接口行为表现

如上述所见, `bridge vlan show`的结果中包含了3种标记: `1(vlan id)`, `PVID`, `Egress Untagged`. ta们会影响bridge对数据包接收与流出, 接下来我们将研究这3种标记的作用.

首先说结论

| Ingress      | Egress         |
| :----------- | :------------- |
| vid 100      |                |
| vid 100 pvid | untagged       |
| vid 200      | vid 100 tagged |
| vid 200 pvid | vid 200 tagged |


pvid 只在数据包流入的时候才有意义, 并不影响数据包流出时的行为;

untagged 也是类似的, 只在数据包从本端口发出的时候才有意义, ta本身并不影响 bridge 的转发行为.

**关于数据流出的行为表现**

能够流入一个开启 vlan 功能的 bridge, 数据包必定携带了 vlan tag(不管是本来就有, 还是被后来被pvid打的).

那么 bridge 也一定会根据这个 vlan id 值进行转发.

### 01. 数据流入 package -> none

无法流入, 所有类型的数据包都会被丢弃, 没有意义.

### 02. 数据流入 package -> vid 100

假设数据包流入的bridge的端口配置为`vid 100`, 不带有`pvid`标记, 那么根据流入数据的不同, 可能会有如下情况:

1. 不带 vlan tag 的数据包, 会被 bridge 设备丢弃;
2. 带有 vlan tag 且 id 不为 100 (与该 bridge 端口不匹配)的数据包, 也会被 bridge 设备丢弃;
3. 只有带有 vlan tag, 且 id 为 100 数据包, 才会被 bridge 接收;

### 03. 数据流入 package -> vid 100 pvid

1. 不带 vlan tag 的数据包, 会被接收, 且 bridge 会给数据包打上 vid 100 的 tag(之后会按照此 vid 进行转发);
2. 数据包带有 vlan tag, 但 id 不为 100, 则会被丢弃;
3. 数据包带有 vlan tag, 且 id 为 100, 则会被接收并转发;

### 04. 数据流出 none -> package

任何类型的数据包都不会从 none 标记的接口发出, 同样没有意义.

### 05. 数据流出 vid 100 -> package 

1. 只有 vlan tag 为 100 的数据包, 才会由此接口发出, 且流出的数据包还会携带 vlan tag;

### 06. 数据流出 vid 100 untagged -> package

1. 只有 vlan tag 为 100 的数据包, 才会由此接口发出, 且流出的数据包已经不再携带 vlan tag;

