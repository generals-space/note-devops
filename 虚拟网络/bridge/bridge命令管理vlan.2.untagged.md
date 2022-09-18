# bridge命令管理vlan(二)-untagged

参考文章

1. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces – IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - 系列文章第4章, 对bridge设备的vlan设置规则有详细介绍, 本章并没有提供代码示例.

untagged 只在数据包从本端口发出的时候在有意义, ta本身并不影响 bridge 的转发行为.

## 1. 部署实验网络

```
ip netns add netns1
ip netns add netns2
ip link add veth1 type veth peer name veth2
ip link set veth1 netns netns1
ip link set veth2 netns netns2
ip netns exec netns2 ip link add veth21 type veth peer name veth22
```

启动

```
ip netns exec netns1 ip link set veth1 up
ip netns exec netns2 ip link set veth2 up
ip netns exec netns2 ip link set veth21 up
ip netns exec netns2 ip link set veth22 up
ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth1
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth22
```

在`netns2`中创建, 配置`bridge`, 并将`veth2`与`veth21`接入.

```bash
ip netns exec netns2 ip link add mybr2 type bridge
ip netns exec netns2 ip link set mybr2 up
ip netns exec netns2 ip link set veth2 master mybr2
ip netns exec netns2 ip link set veth21 master mybr2
ip netns exec netns2 ip link set dev mybr2 type bridge vlan_filtering 1
```

此时网络拓扑如下

```
+-------------+-----------------------------------------------------------+
|   netns1    |                            netns2                         |
| 10.1.1.1/24 |                                               10.1.1.2/24 |
|  +-------+  |  +-------+       +-------+       +--------+   +--------+  |
|  | veth1 |  |  | veth2 | <---> | mybr2 | <---> | veth21 |   | veth22 |  |
|  +---↑---+  |  +---↑---+       +-------+       +----↑---+   +----↑---+  |
|      └-------------┘                                └------------┘      |
+-------------+-----------------------------------------------------------+
```

## 2. 初始表现

最初的vlan配置如下

```console
$ ip netns exec netns2 bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
veth21	 1 PVID Egress Untagged
mybr2	 1 PVID Egress Untagged
```

从`netns1`中`ping 10.1.1.2`.

```bash
ip netns exec netns1 ping 10.1.1.2
```

没什么特殊情况.

在`netns2`中抓包如下

```console
$ ip netns exec netns2 tcpdump -nve -i veth21
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
16:39:13.991751 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 47386, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3195, seq 1, length 64
16:39:13.991810 d2:0a:94:45:85:bf > 6e:c1:18:37:93:79, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 59851, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 3195, seq 1, length 64
```

注意: 这里到达`veth21`的数据包中并没有`vlan tag`.

## 3. 移除vlan条目中的`Egress Untagged`标记

接下来, 我们尝试移除`bridge`中`veth21`条目的`Egress Untagged`标记, 比较一下有何不同.

由于`bridge vlan`子命令没有`update/replace/modifiy`这种更新命令, 只能先删除原来的条目再新建.

```bash
ip netns exec netns2 bridge vlan del dev veth21 vid 1
ip netns exec netns2 bridge vlan add dev veth21 vid 1 pvid
```

此时的vlan配置如下

```console
$ ip netns exec netns2 bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
veth21	 1 PVID
mybr2	 1 PVID Egress Untagged
```

再ping(此时已经ping不通了...), 再抓包.

```console
$ ip netns exec netns2 tcpdump -nve -i veth21
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
04:26:19.551616 32:21:c9:c2:d8:69 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
04:26:20.566593 32:21:c9:c2:d8:69 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
```

与前面抓包示例相比, 这次`veth21`上有了`vlan tag`. 这也说明了`Egress Untagged`的作用: 可以把流入的数据包中`vlan tag`移除后再流出, 这样出去的数据包中就不带有`vlan tag`了.

由于`veth`设备类似于物理网线, 对任何数据都会透传, 所以在`veth22`上抓包也可以看到`vlan tag`.

```console
$ ip netns exec netns2 tcpdump -nve -i veth22
tcpdump: listening on veth22, link-type EN10MB (Ethernet), capture size 262144 bytes
04:29:08.519472 32:21:c9:c2:d8:69 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
04:29:09.527871 32:21:c9:c2:d8:69 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
```

只不过由于`veth22`无法处理带有`vlan tag`的数据, 所以没有响应.


```
+-------------+-----------------------------------------------------------+
|   netns1    |                            netns2                         |
|             |                                                           |
|             |                            vlan 1        vlan 1           |
|             |                             --->          --->            |
| 10.1.1.1/24 |                                               10.1.1.2/24 |
|  +-------+  |  +-------+       +-------+       +--------+   +--------+  |
|  | veth1 |  |  | veth2 | <---> | mybr2 | <---> | veth21 |   | veth22 |  |
|  +---↑---+  |  +---↑---+       +-------+       +----↑---+   +----↑---+  |
|      └─────────────┘                                └────────────┘      |
+-------------+-----------------------------------------------------------+
```

------

想恢复, 同样需要先删除, 再新建, 只要新建命令中添加上`untagged`标记即可.

```bash
ip netns exec netns2 bridge vlan del dev veth21 vid 1
ip netns exec netns2 bridge vlan add dev veth21 vid 1 pvid untagged
```

现在ping操作又重新正常了.
