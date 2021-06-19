参考文章

1. [网卡虚拟化技术 macvlan 详解](https://www.cnblogs.com/gdg87813/p/13355019.html)
    - macvlan 这种技术听起来有点像 VLAN，但它们的实现机制是完全不一样的。macvlan 子接口和原来的主接口是完全独立的，可以单独配置 MAC 地址和 IP 地址，而 VLAN 子接口和主接口共用相同的 MAC 地址。VLAN 用来划分广播域，而 macvlan 共享同一个广播域。

VMware Nat网络模式

- vm01: 172.16.91.10/24
- vm02: 172.16.91.14/24

网关与DNS地址都是`172.16.91.2`.

## 构建网络拓扑

在vm02上执行如下命令

```
ip link add mybr0 type bridge
ip link set ens34 master mybr0
```

```
ip addr del 172.16.91.14/24 dev ens34
ip addr add 172.16.91.14/24 dev mybr0
ip link set mybr0 up
ip r add default via 172.16.91.2 dev mybr0
```

```bash
## 创建两个 macvlan 子接口
## 注意!!! 此时 macvlan 的父接口为 bridge 设备.
ip link add link mybr0 dev macvlan1 type macvlan mode vepa
ip link add link mybr0 dev macvlan2 type macvlan mode vepa

# 创建两个 namespace
ip netns add ns01
ip netns add ns02

# 将两个子接口分别挂到两个 namespace 中
ip link set macvlan1 netns ns01
ip link set macvlan2 netns ns02

# 配置 IP 并启用
ip netns exec ns01 ip addr add 172.16.91.101/24 dev macvlan1
ip netns exec ns01 ip link set macvlan1 up

ip netns exec ns02 ip addr add 172.16.91.102/24 dev macvlan2
ip netns exec ns02 ip link set macvlan2 up
```

由于macvlan设备上自动生成的路由, 默认以`172.16.91.1`当作网关的地址, 而`172.16.91.1`这的地址本身是不存在的, 所以需要更新路由, 将下一跳地址指向`172.16.91.2`.

```
ip netns exec ns01 ip r del 172.16.91.0/24 dev macvlan1
ip netns exec ns01 ip r add 172.16.91.0/24 dev macvlan1 via 172.16.91.2 onlink
ip netns exec ns02 ip r del 172.16.91.0/24 dev macvlan2
ip netns exec ns02 ip r add 172.16.91.0/24 dev macvlan2 via 172.16.91.2 onlink
```

> 如果不添加`onlink`标记, 在添加新路由时, 会显示`RTNETLINK answers: Network is unreachable`.

好了, 现在ns01和ns02之间相互可以通信了, 但是宿主机上仍然无法与ns01/ns02通信, 毕竟vepa只保证macvlan设备之间可以通信, 并不保证macvlan设备与父接口的通信...
