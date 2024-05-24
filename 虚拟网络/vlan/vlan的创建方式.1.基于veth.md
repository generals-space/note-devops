# vlan的创建方式.2.基于veth

参考文章

1. [KVM + LinuxBridge 的网络虚拟化解决方案实践](http://www.ishenping.com/ArtInfo/1779722.html)
    - 在讲解linux虚拟设备的时候加入了协议栈的角色, 让人理解起来更容易.
    - veth设备不只是网线, 毕竟ta可以拥有IP, 只有在其将连接协议栈的部分断开后才表现的完全是网线的作用.

网上教程大都是基于`eth0`或是`bond`设备创建vlan, 并且用于接入`bridge`作子网划分的.

后来发现还能从`veth`设备的一端创建`vlan`设备, 简直刷新了我的认知, 不知道映射到真实的物理设备能是哪种情况.

## 1. 部署实验网络

在宿主机上创建两个`netns`, 以及一对`veth pair`, 将ta们连接起来.

```bash
ip netns add netns1
ip netns add netns2

ip link add veth11 type veth peer name veth21
ip link set veth11 netns netns1
ip link set veth21 netns netns2

ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth11
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth21
ip netns exec netns1 ip link set veth11 up
ip netns exec netns2 ip link set veth21 up
```

此时的网络拓扑如下:

```
+----------------+----------------+
|     netns1     |    netns2      |
|  10.1.1.1/24   |   10.1.1.2/24  |
|   +--------+   |   +--------+   |
|   | veth11 |   |   | veth21 |   |
|   +----↑---+   |   +----↑---+   |
|        └────────────────┘       |
+----------------+----------------+
```

此时两边互ping, 都是通的.

`netns1`中`ping 10.1.1.2`, `netns2`中抓包如下

```log
$ tcpdump -nve -i veth21
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:34:40.850978 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 11111, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 23100, seq 1, length 64
14:34:40.851041 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 7653, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 23100, seq 1, length 64
```

## 2. 在veth设备的一端创建vlan子设备

`netns1`中执行

```bash
ip link add link veth11 name veth11.100 type vlan id 100
ip link set veth11.100 up
ip addr del 10.1.1.1/24 dev veth11
ip addr add 10.1.1.1/24 dev veth11.100
```

将IP地址从`veth11`转移到`veth11.100`会使路由记录变更, 之后的ping请求就会从`veth11.100`接口发出.

```log
## 转移前
$ ip route
10.1.1.0/24 dev veth11 proto kernel scope link src 10.1.1.1
## 转移后
$ ip route
10.1.1.0/24 dev veth11.100 proto kernel scope link src 10.1.1.1
```

此时的网络拓扑如下:

```
+--------------------------------------+----------------+
|                           netns1     |    netns2      |
|     10.1.1.1/24                      |    10.1.1.2/24 |
|   +------------+        +--------+   |   +--------+   |
|   | veth11.100 | <----> | veth11 |   |   | veth21 |   |
|   +------------+  vlan  +----↑---+   |   +----↑---+   |
|                              └────────────────┘       |
+--------------------------------------+----------------+
```

`netns1`中再次`ping 10.1.1.2`, 此时是不通的, 在`netns2`中抓包显示如下

```log
$ tcpdump -nve -i veth21
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:37:39.436320 da:5d:0b:47:12:27 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
14:37:40.437900 da:5d:0b:47:12:27 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
```

输出中可以看到`vlan`字段, 正是创建`veth11.100`时指定的值. 这表示数据包在`veth11.100 -> veth11`的线路中流动时, 会携带前者的`vlan tag`. 另外, 由于不通, 抓包记录中是没有回应的.

这说明`veth21`虽然接收到了, 但并没有能力处理带有`vlan tag`的数据包.

**但是反过来却是不同的**

从`netns2`中`ping 10.1.1.1`, 也ping不通, 在`netns1`接口上抓包显示如下

```log
$ tcpdump -nve -i veth11
tcpdump: listening on veth11, link-type EN10MB (Ethernet), capture size 262144 bytes
02:10:55.744054 c6:f8:f3:12:9c:3f > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.1 tell 10.1.1.2, length 28
02:10:56.750594 c6:f8:f3:12:9c:3f > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.1 tell 10.1.1.2, length 28
$ tcpdump -nve -i veth11.100
tcpdump: listening on veth11.100, link-type EN10MB (Ethernet), capture size 262144 bytes
## ...无输出
```

可以看到, `veth11`接口中有数据, 但是并没有传递到`veth11.100`接口, 说明**无`vlan tag`的数据包在`veth11 -> veth11.100`流通中是被阻断的**.

## 3. 在veth设备的另一端也创建vlan

接下来的我们尝试一下在`netns2`中也添加类似的`veth vlan`子接口.

`netns2`中执行

```bash
ip netns exec netns2 ip link add link veth21 name veth21.100 type vlan id 100
ip netns exec netns2 ip link set veth21.100 up
ip netns exec netns2 ip addr del 10.1.1.2/24 dev veth21
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth21.100
```

此时的网络拓扑如下:

```
+--------------------------------------+--------------------------------------+
|                           netns1     |    netns2                            |
|     10.1.1.1/24                      |                      10.1.1.2/24     |
|   +------------+        +--------+   |   +--------+        +------------+   |
|   | veth11.100 | <----> | veth11 |   |   | veth21 | <----> | veth21.100 |   |
|   +------------+  vlan  +----↑---+   |   +----↑---+  vlan  +------------+   |
|                              └────────────────┘                             |
+--------------------------------------+--------------------------------------+
```

从`netns1`中`ping 10.1.1.2`, 这次成功了. 

在`netns2`中抓包显示如下

```log
$ tcpdump -nve -i veth21
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
14:47:36.699011 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 63742, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24391, seq 1, length 64
14:47:36.699167 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 65521, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24391, seq 1, length 64
```

```log
$ tcpdump -nve -i veth21.100
tcpdump: listening on veth21.100, link-type EN10MB (Ethernet), capture size 262144 bytes
14:48:29.714843 da:5d:0b:47:12:27 > c2:24:af:08:82:15, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 30752, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 24475, seq 1, length 64
14:48:29.714930 c2:24:af:08:82:15 > da:5d:0b:47:12:27, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 17745, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 24475, seq 1, length 64
```

## 4. 创建另一个vlan

```
+--------------------------------------+----------------------------------------+
|                           netns1     |    netns2              10.1.1.2/24     |
|                                      |                  100 +-------------+   |
|     10.1.1.1/24                      |                ┌─────┤  veth2.100  |   |
|   +------------+        +--------+   |   +--------+   |     +-------------+   |
|   | veth11.100 | <----> | veth11 |   |   | veth21 ├───┤                       |
|   +------------+  vlan  +----↑---+   |   +----↑---+   |     +-------------+   |
|                              └────────────────┘       └─────┤  veth2.200  |   |
|                                      |                  200 +-------------+   |
+--------------------------------------+----------------------------------------+
```

```
+--------------------------------------+----------------------------------------+
|                           netns1     |    netns2        100 +-------------+   |
|     10.1.1.1/24                      |                ┌─────┤  veth2.100  |   |
|   +------------+        +--------+   |   +--------+   |     +-------------+   |
|   | veth11.100 | <----> | veth11 |   |   | veth21 ├───┤                       |
|   +------------+  vlan  +----↑---+   |   +----↑---+   |     +-------------+   |
|                              └────────────────┘       └─────┤  veth2.200  |   |
|                                      |                  200 +-------------+   |
|                                      |                        10.1.1.12/24    |
+--------------------------------------+----------------------------------------+
```


这说明`veth vlan`的收发双方所属的vlan也要相同才能进行通信.

## 5. 总结

1. 由于两个`netns`间的通信包都是带有`vlan tag`的, 所以可以得出, 包的起点是`veth11.100`和`veth21.100`. 
2. 实际连接两个`netns`的仍然是`veth pair`.
3. 将IP从`veth pair`上转移到`veth vlan`设备是为了路由能从`veth11.100`或`veth21.100`上发出.
4. 无`vlan tag`的数据包在`veth11 -> veth11.100`流通中是被阻断的.
5. `veth vlan`也需要匹配才能被回应, 否则ping不通.

**可以说`veth vlan`是用于为数据包添加`vlan tag`, 并且接收指定`vlan tag`的设备, 而`veth`本身则像是物理网线, 只进行数据透传, 不做任何修改.**
