# vlan的创建方式.2.基于veth

参考文章

1. [KVM + LinuxBridge 的网络虚拟化解决方案实践](http://www.ishenping.com/ArtInfo/1779722.html)
    - 在讲解linux虚拟设备的时候加入了协议栈的角色, 让人理解起来更容易.
    - veth设备不只是网线, 毕竟ta可以拥有IP, 只有在其将连接协议栈的部分断开后才表现的完全是网线的作用.
2. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces]()
    - [I](https://linux-blog.anracom.com/2017/10/30/fun-with-veth-devices-in-unnamed-linux-network-namespaces-i/)
    - [II](https://linux-blog.anracom.com/2017/11/12/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-ii/)
    - [III](https://linux-blog.anracom.com/2017/11/14/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iii/)
    - [IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - [V](https://linux-blog.anracom.com/2017/11/21/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-v/)
    - [VI](https://linux-blog.anracom.com/2017/11/28/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vi/)
    - [VII](https://linux-blog.anracom.com/2017/12/30/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vii/)
    - [VIII](https://linux-blog.anracom.com/2018/01/05/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-viii/)
    - 这一系列的文章从内容上来说非常棒, 但作者好像是个德国人, 英文句法看得人一脸萌b, 很多错别字, 阅读障碍相当不小...

网上教程大都是基于`eth0`或是`bond`设备创建vlan, 并且用于接入`bridge`作子网划分的.

只有参考文章2这个系列...md原来还能从veth设备的一端创建vlan, 简直刷新了我的认知, 不知道映射到真实的物理设备能是哪种情况.

## step 1 veth pair连接两个netns

在宿主机上创建两个netns, 以及一对veth pair, 将ta们连接起来.

```console
$ ip netns add veth01
$ ip netns add veth02
$ ip link add veth11 type veth peer name veth21

$ ip link set veth11 netns netns01
$ ip link set veth21 netns netns02

$ ip netns exec veth01 ip addr add 10.1.1.1/24 dev veth11
$ ip netns exec veth01 ip link set veth11 up
$ ip netns exec veth02 ip addr add 10.1.1.2/24 dev veth21
$ ip netns exec veth02 ip link set veth21 up
```

此时两边互ping, 都是通的.

netns01中`ping 10.1.1.2`, netns02中抓包如下

```console
$ tcpdump -vvv -n -i veth21 -e
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:34:40.850978 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 11111, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 23100, seq 1, length 64
14:34:40.851041 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 7653, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 23100, seq 1, length 64
14:34:41.850998 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 11537, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 23100, seq 2, length 64
14:34:41.851056 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 7863, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 23100, seq 2, length 64
14:34:45.851954 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.1 tell 10.1.1.2, length 28
```

```
+----------------------+----------------------+
|     netns01          |          netns02     |
|                      |                      |
|    +--------+        |        +--------+    |
|    | .1.1/24|        |        | .1.2/24|    |
|    +--------+        |        +--------+    |
|    | veth11 |        |        | veth21 |    |
|    +--------+        |        +--------+    |
|         ↑            |             ↑        |
|         +--------------------------+        |
|                      |                      |
+----------------------+----------------------+
```

## step 2 在一端的veth设备创建vlan

netns01中

```console
$ ip link add link veth11 name veth11.100 type vlan id 100
$ ip link set veth11.100 up
$ ip addr del 10.1.1.1/24 dev veth11
$ ip addr add 10.1.1.1/24 dev veth11.100
```

将IP地址从`veth11`转移到`veth11.100`是为了使路由记录变更, 之后的ping请求就会从`veth11.100`接口发出.

```console
## 转移前
$ ip route
10.1.1.0/24 dev veth11 proto kernel scope link src 10.1.1.1
## 转移后
10.1.1.0/24 dev veth11.100 proto kernel scope link src 10.1.1.1
```

netns01中再次`ping 10.1.1.2`, 此时是不通的, 在netns02中抓包显示如下

```console
$ tcpdump -vvv -n -i veth21 -e
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:37:39.436320 da:5d:0b:47:12:27 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
14:37:40.437900 da:5d:0b:47:12:27 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
```

可以看到, `length`字段后多了vlan字段, 正好是创建`veth11.100`时指定的值. 另外, 由于不通, 抓包记录中是没有回应的.

```
+--------------------------------------+------------------------+
|    netns01                           |     netns02            |
|                                      |                        |
|   +------------+                     |   +--------+           |
|   |  .1.1/24   |                     |   | .1.2/24|           |
|   +------------+        +--------+   |   +--------+           |
|   | veth11.100 | <----> | veth11 |   |   | veth21 |           |
|   +------------+  vlan  +--------+   |   +--------+           |
|                              ↑       |        ↑               |
|                              +----------------+               |
|                                      |                        |
+--------------------------------------+------------------------+
```

## step 3 在另一端的veth设备也创建vlan

加了vlan的请求, 理论上需要由bridge设备来处理转发, 接下来的我们尝试一下在netns02中也添加类似的veth vlan子接口.

netns02中

```console
$ ip link add link veth21 name veth21.100 type vlan id 100
$ ip link set veth21.100 up
$ ip addr del 10.1.1.2/24 dev veth21
$ ip addr add 10.1.1.2/24 dev veth21.100
```

从netns01中`ping 10.1.1.2`, 在netns02中抓包显示如下

```console
$ tcpdump -vvv -n -i veth21 -e
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:47:36.699011 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 63742, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24391, seq 1, length 64
14:47:36.699167 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 65521, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24391, seq 1, length 64
14:47:37.698971 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 64413, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24391, seq 2, length 64
14:47:37.699030 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 31, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24391, seq 2, length 64
14:47:41.707946 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.1 tell 10.1.1.2, length
```

```console
$ tcpdump -vvv -n -i veth21.100 -e
tcpdump: listening on veth21.100, link-type EN10MB (Ethernet), capture size 262144 bytes
14:48:29.714843 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 30752, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24475, seq 1, length 64
14:48:29.714930 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 17745, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24475, seq 1, length 64
14:48:30.715026 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 30813, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24475, seq 2, length 64
14:48:30.715090 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 18220, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24475, seq 2, length 64
```

```
+--------------------------------------+--------------------------------------+
|    netns01                           |                           netns02    |
|                                      |                                      |
|   +------------+                     |                     +------------+   |
|   |  .1.1/24   |                     |                     |  .1.2/24   |   |
|   +------------+        +--------+   |   +--------+        +------------+   |
|   | veth11.100 | <----> | veth11 |   |   | veth21 | <----> | veth21.100 |   |
|   +------------+  vlan  +--------+   |   +--------+  vlan  +------------+   |
|                              ↑       |        ↑                             |
|                              +----------------+                             |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
```

------

注意点:

1. 由于两个netns间的通信包都是带有vlan tag的, 所以可以得出, 包的起点是`veth11.100`和`veth21.100`. 
2. 实际连接两个netns的仍然是veth pair.
3. 将IP从veth pair上转移到vlan设备是为了路由能从`veth11.100`或`veth21.100`上发出.
4. veth上的vlan也需要匹配才能被回应, 否则ping不通.

