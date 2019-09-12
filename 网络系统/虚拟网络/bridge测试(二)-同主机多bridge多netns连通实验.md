# bridge测试(二)-同主机多bridge多netns连通实验

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - veth 设备连接两个 netns
    - bridge 设备连接多个 netns

```console
ip link add br0 type bridge
ip link set dev br0 up
ip addr add 10.1.1.1/24 dev br0
## 网络命令空间 net0
ip netns add net0
ip link add type veth
ip link set dev veth1 netns net0

ip netns exec net0 ip link set dev veth1 name eth0
ip netns exec net0 ip addr add 10.1.1.2/24 dev eth0
## 注意即使这里启动了 eth0 接口, 自动添加了到 10.1.1.0/24 的路由
## 所以可以直接ping通对端 bridge 10.1.1.1
ip netns exec net0 ip link set dev eth0 up
ip netns exec net0 ip route add default via 10.1.1.1 dev eth0

ip link set dev veth0 master br0
ip link set dev veth0 up
```

```console
ip link add br1 type bridge
ip link set dev br1 up
ip addr add 20.1.1.1/24 dev br1

ip netns add net1
ip link add type veth
ip link set dev veth1 netns net1

ip netns exec net1 ip link set dev veth1 name eth0
ip netns exec net1 ip addr add 20.1.1.2/24 dev eth0
ip netns exec net1 ip link set dev eth0 up
ip netns exec net1 ip route add default via 20.1.1.1 dev eth0

ip link set dev veth0 master br1
ip link set dev veth0 up
```

未完成