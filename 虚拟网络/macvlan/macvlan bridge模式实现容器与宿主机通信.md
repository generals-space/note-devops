# macvlan bridge模式实现容器与宿主机通信

参考文章

1. [Macvlan 网络方案实践](https://cloud.tencent.com/developer/article/1495218)
    - 关于 macvlan bridge 模式下, macvlan容器与其所在宿主机通信的模式处理
2. [Docker macvlan host to container 互通](https://www.jianshu.com/p/680fad14a947)
3. [K8S CNI之：利⽤ ipvlan + host-local 打通容器与宿主机的平⾏⽹络](https://juejin.cn/post/6844903801057443853)
    - 本文关于虚拟网络知识, underlay/overlay各自的优缺点等讲解得非常不错.
    - 本文提到了 macvlan 网络中, 容器与宿主机无法互访的情况, 以及通过在宿主机上额外创建 macvlan 接口解决的方法.
    - 作者认为每个宿主机都需要多用一个IP地址, 且遇到了一些不可预知的问题, 所以放弃了这种方法.
    - 通过veth pair实现宿主机与macvlan容器互通(k8s cni中有个"ptp", 其实就是这个原理).

VMWare Nat模式

宿主机: 192.168.42.10/24
网关: 192.168.42.2/24

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

这就可以了, 容器内部不需要添加路由.

`192.168.42.3`是宿主机网络中的某个IP, 需要保留, 不能被物理网络中的其他主机, 或是 macvlan 容器占用.

另外, 我们希望只占用`192.168.42.3`这1个IP, 所以将ta的掩码位设置为32. 这样, 每个宿主机上都可以配置这个IP(因为互相不知道这个IP的存在).

## 3. 借助veth pair

这是参考文章3提到的方法, 作者也尝试过上面2种, 在宿主机上创建额外的 macvlan 接口, 但是遇到了一些不可预知的问题.

而且ta认为为了通过宿主上的 macvlan 设备作路由, 需要为其赋一个IP值, 这样会造成IP浪费(不过我们在第2种方法中只使用了一个32位掩码的IP, 验证是没问题的, 应该是作者没有考虑到的情况).

后来ta只能使用veth pair, 为每个容器都创建一个 veth pair 对, 一端放入容器, 一端留在宿主机.

veth pair 设备不需要赋IP值, 只要分别在容器和宿主机分别添加到对端的路由即可.

这个方法我没有尝试, 应该是可行的, 不过这样会在宿主机留下很多veth设备接口个人觉得还不如第2种.

这里记录一下可能的操作命令.

```
ip link add veth01-0 type veth peer name veth01-1
ip link add veth02-0 type veth peer name veth02-1
ip link set veth01-0 up
ip link set veth01-1 up
ip link set veth02-0 up
ip link set veth02-1 up
ip link set veth01-1 netns ns01
ip link set veth02-1 netns ns02

ip r add 192.168.42.101/24 dev veth01-0
ip r add 192.168.42.102/24 dev veth02-0
ip netns exec ns01 ip r add 192.168.42.10/24 dev veth01-0
ip netns exec ns02 ip r add 192.168.42.10/24 dev veth02-0
```
