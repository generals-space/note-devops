# bridge测试.2.同主机多bridge多netns连通实验

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - [x] veth 设备连接两个 netns()
    - [x] bridge 设备连接多个 netns
    - [ ] 多主机通过bridge连接各自的 netns

> 参考文章中说这个实验需要`ip_forward=1`, 其实不需要, 因为`ip_forward`是tcp/ip层面的, 我们的bridge连接是链路层东西.

网络拓扑如下

```
+-----------------------------------------------------------------------------+
|                                   netns03                                   |
|     10.1.1.1/24                                              20.1.1.1/24    |
|   +------------+        +--------+       +--------+        +------------+   |
|   |    mybr1   | <----> | veth31 | <---> | veth32 | <----> |    mybr2   |   |
|   +------↑-----+        +--------+       +--------+        +------↑-----+   |
|          |                                                        |         |
|     +----↓---+                                               +----↓---+     |
|     | veth13 |                                               | veth23 |     |
|     +-----↑--+                                               +---↑----+     |
+-----------|------------------------------------------------------|----------+
            |                                                      |           
+-----------|----------+                               +-----------|----------+
|  netns01  |          |                               |           | netns02  |
|      +----↓---+      |                               |      +----↓---+      |
|      | veth11 |      |                               |      | veth22 |      |
|      +--------+      |                               |      +--------+      |
|      10.1.1.2/24     |                               |      20.1.1.2/24     |
+----------------------+                               +----------------------+
```

命令如下

```bash
ip netns add netns1
ip netns add netns2
ip netns add netns3
ip netns exec netns3 ip link add mybr1 type bridge
ip netns exec netns3 ip link add mybr2 type bridge

ip link add veth11 type veth peer name veth13
ip link add veth22 type veth peer name veth23
ip link set veth11 netns netns1
ip link set veth22 netns netns2
ip link set veth13 netns netns3
ip link set veth23 netns netns3

ip netns exec netns1 ip link set veth11 up
ip netns exec netns2 ip link set veth22 up
ip netns exec netns3 ip link set veth13 up
ip netns exec netns3 ip link set veth23 up
ip netns exec netns3 ip link set mybr1 up
ip netns exec netns3 ip link set mybr2 up
ip netns exec netns3 ip link set veth13 master mybr1
ip netns exec netns3 ip link set veth23 master mybr2
ip netns exec netns3 ip link add veth31 type veth peer name veth32
ip netns exec netns3 ip link set veth31 up
ip netns exec netns3 ip link set veth32 up
ip netns exec netns3 ip link set veth31 master mybr1
ip netns exec netns3 ip link set veth32 master mybr2

ip netns exec netns1 ip addr add 10.1.1.2/24 dev veth11
ip netns exec netns2 ip addr add 20.1.1.2/24 dev veth22
ip netns exec netns3 ip addr add 10.1.1.1/24 dev mybr1
ip netns exec netns3 ip addr add 20.1.1.1/24 dev mybr2

ip netns exec netns1 ip route add default via 10.1.1.1 dev veth11
ip netns exec netns2 ip route add default via 20.1.1.1 dev veth22
```

结果验证

```log
$ ip netns exec netns1 ping -c 2 20.1.1.2

PING 20.1.1.2 (20.1.1.2) 56(84) bytes of data.
64 bytes from 20.1.1.2: icmp_seq=1 ttl=63 time=0.171 ms
64 bytes from 20.1.1.2: icmp_seq=2 ttl=63 time=0.178 ms

--- 20.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.171/0.174/0.178/0.013 ms
```

```log
$ ip netns exec netns2 ping -c 2 10.1.1.2

PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
64 bytes from 10.1.1.2: icmp_seq=1 ttl=63 time=0.153 ms
64 bytes from 10.1.1.2: icmp_seq=2 ttl=63 time=0.158 ms

--- 10.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.153/0.155/0.158/0.012 ms
```

由于两个子网通过bridge设备连接在一起, 所以虽然分属不同子网, 但仍可以通过二层直接通信, 不需要经过路由.
