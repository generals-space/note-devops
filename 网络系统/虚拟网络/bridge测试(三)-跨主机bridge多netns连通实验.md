# bridge测试(三)-跨主机bridge多netns连通实验

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - [x] veth 设备连接两个 netns()
    - [x] bridge 设备连接多个 netns
    - [ ] 多主机通过bridge连接各自的 netns

host1

```
ip netns add netns1
ip link add mybr1 type bridge
ip link add veth11 type veth peer name veth12
ip link set veth12 up
ip link set mybr1 up
ip addr add 10.1.1.1/24 dev mybr1
ip link set veth12 master mybr1

ip link set veth11 netns netns1
ip netns exec netns1 ip link set veth11 up
ip netns exec netns1 ip addr add 10.1.1.2/24 dev veth11
ip netns exec netns1 ip route add default via 10.1.1.1 dev veth11
```

host2

```
ip netns add netns2
ip link add mybr2 type bridge
ip link add veth21 type veth peer name veth22
ip link set veth22 up
ip link set mybr2 up
ip addr add 20.1.1.1/24 dev mybr2
ip link set veth22 master mybr2

ip link set veth21 netns netns2
ip netns exec netns2 ip link set veth21 up
ip netns exec netns2 ip addr add 20.1.1.2/24 dev veth21
ip netns exec netns2 ip route add default via 20.1.1.1 dev veth21
```

失败.

尝试把hosts上netns及bridge的修改成`10.1.1.0/24`的IP, 仍然不成功.

仔细想想, 以物理网络为基础, 构建不同独立网段的子网, 这不就是overlay么? 应该借助隧道机制来实现吧.

另外我又尝试在两个bridge上添加服务器网段的IP, 但是仍然没能互相ping通.
