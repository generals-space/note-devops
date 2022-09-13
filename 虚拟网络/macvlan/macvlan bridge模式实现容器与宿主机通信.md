参考文章

1. [Macvlan 网络方案实践](https://cloud.tencent.com/developer/article/1495218)
    - 关于 macvlan bridge 模式下, macvlan容器与其所在宿主机通信的模式处理
2. [Docker macvlan host to container 互通](https://www.jianshu.com/p/680fad14a947)

```
ip link set ens34 promisc on

ip netns add ns01
ip netns add ns02

ip link add link ens34 macvlan01 type macvlan mode bridge
ip link add link ens34 macvlan02 type macvlan mode bridge

ip link set macvlan01 netns ns01
ip link set macvlan02 netns ns02

ip netns exec ns01 ip addr add 192.168.42.101/24 dev macvlan01
ip netns exec ns02 ip addr add 192.168.42.102/24 dev macvlan02

ip netns exec ns01 ip link set macvlan01 up
ip netns exec ns02 ip link set macvlan02 up

ip netns exec ns01 ip route add default via 192.168.42.2 dev macvlan01
ip netns exec ns02 ip route add default via 192.168.42.2 dev macvlan02
```



为了实现宿主机与其上面的 macvlan 容器相互通信, 可以按照参考文章1和2, 有2种不同的处理方法(不过原理上感觉是相同的).

## 1. 宿主机新建macvlan设备, 取代物理网卡eth0

```
ip link add link ens34 macvlan00 type macvlan mode bridge
## 下面的命令一定要放在一起执行, 或者有能力通过非远程形式进入主机终端, 否则中间会失去连接
ip addr del 192.168.42.10/24 dev ens34 && \
  ip addr add 192.168.42.10/24 dev macvlan00 && \
  ip link set dev macvlan00 up && \
  ip route flush dev ens34 && \
  ip route flush dev macvlan00 && \
  ip route add 192.168.42.0/24 dev macvlan00 && \
  ip route add default via 192.168.42.2 dev macvlan00
```

## 2. 宿主机新建macvlan设备, 取代物理网卡eth0

```
ip link add link ens34 macvlan00 type macvlan mode bridge
ip addr add 192.168.42.3/32 dev macvlan00
ip link set dev macvlan00 up
```

宿主机访问ta上面的 macvlan 容器时, 用这个网卡做路由.

```
ip route flush dev macvlan00
ip route add 192.168.42.101 dev macvlan00
ip route add 192.168.42.102 dev macvlan00
```

这就可以了.

`192.168.42.3`是宿主机网络中的某个IP, 需要保留, 不能被物理网络中的其他主机, 或是 macvlan 容器占用.

另外, 我们希望只占用`192.168.42.3`这1个IP, 所以将ta的掩码位设置为32. 这样, 每个宿主机上都可以配置这个IP(因为互相不知道这个IP的存在).
