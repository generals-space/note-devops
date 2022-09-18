# bridge+veth vlan组合实验

参考文章

1. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces – IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - 系列文章第4章, 对bridge设备的vlan设置规则有详细介绍, 本章并没有提供代码示例.

## 1. 部署实验网络

```bash
ip netns add netns1
ip netns add netns2

ip link add veth1 type veth peer name veth2
ip link set veth1 netns netns1
ip link set veth2 netns netns2
ip netns exec netns2 ip link add veth21 type veth peer name veth22
```

启动

```bash
ip netns exec netns1 ip link set veth1 up
ip netns exec netns2 ip link set veth2 up
ip netns exec netns2 ip link set veth21 up
ip netns exec netns2 ip link set veth22 up

ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth1
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth22
```

在`netns2`中创建并配置`bridge`设备, 并将`veth2`与`veth21`接入.

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


## 2. step 2

先删除原来的vlan条目(`1`貌似是保留id).

```bash
ip netns exec netns2 bridge vlan del dev veth2 vid 1
ip netns exec netns2 bridge vlan del dev veth21 vid 1
## ip netns exec netns2 bridge vlan del dev mybr2 vid 1
## RTNETLINK answers: Operation not supported
ip netns exec netns2 bridge vlan del dev mybr2 vid 1 self
```

> 注意: **删除`bridge`设备本身的条目时要加`self`标记, 否则会出错.**

再新建vlan

```bash
ip netns exec netns2 bridge vlan add dev veth2 vid 100 pvid
ip netns exec netns2 bridge vlan add dev veth21 vid 100 pvid
```

此时的vlan配置如下

```console
$ ip netns exec netns2 bridge vlan show
port	vlan ids
veth2	100 PVID
veth21	100 PVID
mybr2	None
```

再ping(此时已经ping不通了...), 再抓包.

**veth21**

```console
$ ip netns exec netns2 tcpdump -nve -i veth21

tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
16:45:43.119577 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 51916, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3882, seq 1, length 64
16:45:44.119056 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 52612, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3882, seq 2, length 64
```

**veth22**

```console
$ ip netns exec netns2 tcpdump -nve -i veth22

tcpdump: listening on veth22, link-type EN10MB (Ethernet), capture size 262144 bytes
20:55:49.781741 0e:8d:57:8a:22:58 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
20:55:50.783975 0e:8d:57:8a:22:58 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
```

你会发现从`bridge`出来后, 在`mybr2 -> veth21`的包有vlan的标记, 正好是100. 而且在`veth21`应该就被丢弃了, 因为包没有到`veth22`.

## 3. 分析

我们知道在`veth2`接入`bridge`的`tag`为100的接口, 那么`bridge`就会将`veth2`的请求转发给其他`tag`也为100的接口. 默认情况下, 包转发出来的时候bridge会将`tag`移除, 以免影响其最终目的地.

现在没有移除`vlan tag`, 而`veth21`和`veth22`没有能够接收带有`vlan tag`的包的能力, 所以无法回应.

------

上文中的实验, 由于`bridge`的两个接口`veth2`, `veth21`没有`Egress Untagged`标记, 导致出口的数据包中仍然携带着vlan tag. 而`veth2`和`veth21`都没有能力接收, 只能丢弃.

那么, 怎么解决呢? 尝试做如下挣扎...

扔掉`veth21`和`veth22`, 在`veth21`上创建`vlan`子接口看看能不能通吧.

```bash 
ip netns exec netns2 ip link add link veth2 name veth2.1 type vlan id 1
ip netns exec netns2 ip link set veth2.1 up
ip netns exec netns2 ip link set veth2 nomaster
ip netns exec netns2 ip link set veth2.1 master mybr2

ip netns exec netns2 ip link add link veth21 name veth21.1 type vlan id 1
ip netns exec netns2 ip link set veth21.1 up
ip netns exec netns2 ip link set veth21 nomaster
ip netns exec netns2 ip link set veth21.1 master mybr2
```

```
+-------------+------------------------------------------------------------------------------------------------+
|   netns1    |                                      netns2                                                    |
| 10.1.1.1/24 |                   vlan id 1                         vlan id 1                      10.1.1.2/24 |
|  +-------+  |  +-------+       +---------+       +-------+       +----------+       +--------+   +--------+  |
|  | veth1 |  |  | veth2 | <---> | veth2.1 | <---> | mybr2 | <---> | veth21.1 | <---> | veth21 |   | veth22 |  |
|  +---↑---+  |  +---↑---+       +---------+       +-------+       +----------+       +----↑---+   +----↑---+  |
|      └-------------┘                                                                     └------------┘      |
+-------------+------------------------------------------------------------------------------------------------+
```


...`netns1`再次ping失败, 但是包能走到`veth22.1`, 而且我想并没有被丢弃, 只是没法按照原路返回.

``` 
$ ip netns exec netns2 tcpdump -vvv -n -i veth2.1 -e
tcpdump: listening on veth22.1, link-type EN10MB (Ethernet), capture size 262144 bytes
21:26:58.250184 0e:8d:57:8a:22:58 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
21:26:58.250231 32:95:61:9d:ed:53 > 0e:8d:57:8a:22:58, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.2 is-at 32:95:61:9d:ed:53, length 28
21:26:59.251950 0e:8d:57:8a:22:58 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
21:26:59.251986 32:95:61:9d:ed:53 > 0e:8d:57:8a:22:58, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.2 is-at 32:95:61:9d:ed:53, length 28
```

因为虽然在netns2这一端可以接受vlan id为1的包, 但是原路返回时, 从mybr2 -> veth2, 由于veth2也没有处理带vlan id的包的能力, 所以就跪了.

当然也可以尝试在veth2上再加一对veth pair, 然后分别创建vlan子接口, 但是太麻烦了, 这里就不实验了.
