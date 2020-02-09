# bridge测试.1.同主机单bridge多netns连通实验

网络拓扑如下

```
+----------------+                                                 +----------------+
|     netns01    |                                                 |     netns02    |
|   +--------+   |   +--------+       +-------+       +--------+   |   +--------+   |
|   | veth11 | <---> | veth12 | <---> | mybr0 | <---> | veth22 | <---> | veth21 |   |
|   +--------+   |   +--------+       +-------+       +--------+   |   +--------+   |
|   10.1.1.1/24  |                                                 |   10.1.1.2/24  |
+----------------+                                                 +----------------+
```

命令如下

```
ip netns add netns1
ip netns add netns2

ip link add mybr0 type bridge
ip link add veth11 type veth peer name veth12
ip link add veth21 type veth peer name veth22
ip link set veth11 netns netns1
ip link set veth21 netns netns2

ip link set mybr0 up
ip link set veth12 up
ip link set veth22 up
ip netns exec netns1 ip link set veth11 up
ip netns exec netns2 ip link set veth21 up

ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth11
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth21

ip link set veth12 master mybr0
ip link set veth22 master mybr0
```

实验

```
$ ip netns exec netns1 ping -c 2 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
64 bytes from 10.1.1.2: icmp_seq=1 ttl=64 time=0.060 ms
64 bytes from 10.1.1.2: icmp_seq=2 ttl=64 time=0.051 ms

--- 10.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.051/0.055/0.060/0.008 ms
```

> 各设备(veth, bridge)都需要启动, 否则无法连通. 对于一个已经拥有IP地址的设备, 启动时会自动添加对应的路由.

