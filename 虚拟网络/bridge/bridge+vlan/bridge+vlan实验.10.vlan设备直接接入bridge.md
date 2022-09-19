# bridge+vlan实验.00.引言+总结

参考文章

1. [《每天5分钟玩转 OpenStack》教程目录](https://www.jianshu.com/p/4c06dff6cea8)
    - 系列教程目录
2. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces]()
    - [I](https://linux-blog.anracom.com/2017/10/30/fun-with-veth-devices-in-unnamed-linux-network-namespaces-i/)
        - lxc, cgroup, namespace等技术引言
    - [II](https://linux-blog.anracom.com/2017/11/12/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-ii/)
        - 实验索引(一共8个)
    - [III](https://linux-blog.anracom.com/2017/11/14/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iii/)
        - 使用bridge+veth连接两个netns
    - [IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
        - 在veth设备的一端创建vlan子接口时, 是否另一端也必须使用vlan子接口?
        - 什么情况下可以只在veth设备一端使用vlan子接口?
        - `veth`和`veth vlan`哪种可以用来连接到bridge设备? 如果都可以, 会有什么不同?
    - [V](https://linux-blog.anracom.com/2017/11/21/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-v/)
    - [VI](https://linux-blog.anracom.com/2017/11/28/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vi/)
    - [VII](https://linux-blog.anracom.com/2017/12/30/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vii/)
    - [VIII](https://linux-blog.anracom.com/2018/01/05/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-viii/)
    - 这一系列的文章从内容上来说非常棒, 但作者好像是个德国人, 英文句法看得人一脸萌b, 很多错别字, 阅读障碍相当不小...
    - 从veth设备创建vlan子设备(`ip link add link veth1 name veth1.100 type vlan id 100`)

这一阶段讲述的网络结构并不是那么合理, 因为把一个 vlan 设备直接接入 bridge 会有一些意想不到的情况发生.

## 1. 部署实验网络

```bash
ip netns add ns01
ip netns add ns02
ip netns add ns03

ip link add veth11 type veth peer name veth31
ip link add veth22 type veth peer name veth32

ip link set veth11 netns ns01
ip link set veth22 netns ns02
ip link set veth31 netns ns03
ip link set veth32 netns ns03

ip netns exec ns01 ip link add link veth11 name veth11.100 type vlan id 100
ip netns exec ns03 ip link add link veth31 name veth31.100 type vlan id 100
ip netns exec ns01 ip addr add 10.1.1.3/24 dev veth11.100
ip netns exec ns02 ip addr add 10.1.1.4/24 dev veth22
ip netns exec ns01 ip link set veth11 up
ip netns exec ns02 ip link set veth22 up
ip netns exec ns03 ip link set veth31 up
ip netns exec ns03 ip link set veth32 up
ip netns exec ns01 ip link set veth11.100 up
ip netns exec ns03 ip link set veth31.100 up
```

在`ns03`中创建, 配置`bridge`, 并将`veth31`与`veth32`接入.

```bash
ip netns exec ns03 ip link add mybr0 type bridge
ip netns exec ns03 ip link set mybr0 up
ip netns exec ns03 ip link set veth31.100 master mybr0
ip netns exec ns03 ip link set veth32 master mybr0
ip netns exec ns03 ip link set dev mybr0 type bridge vlan_filtering 1
```

```
+-----------------------------+-----------------------------------------------------------------------+
|                    ns01     |                                   ns03                  |    ns02     |
|  10.1.1.3/24                |                                                         | 10.1.1.4/24 |
| +-----------+     +-------+ | +-------+     +-----------+     +-------+     +-------+ |  +-------+  |
| | veth11.100| <-> | veth11| | | veth31| <-> | veth31.100| <-> | mybr0 | <-> | veth32| |  | veth22|  |
| +-----------+     +---↑---+ | +---↑---+     +-----------+     +-------+     +----↑--+ |  +--↑----+  |
|                       └───────────┘                                              └──────────┘       |
+-----------------------------+---------------------------------------------------------+-------------+
```

## 2. 网络分析

~~此时在`ns01`中`ping 10.1.1.4`应该是不通的, 因为来自`veth31.100`的数据包中的`vlan tag`值为100, 而接入`mybr0`的端口默认`vid`值为1, 数据包是进不了的.~~

看来我之前的认知是错误的, 因为双向都可以ping通...🤔

```console
$ bridge vlan show
port	vlan ids
veth32	 1 PVID Egress Untagged
veth31.100	 1 PVID Egress Untagged
veth31.100
mybr0	 1 PVID Egress Untagged
```

我们从`ns01`执行 ping 10.1.1.4, 在`ns03`中抓包时, 发现数据包流经`veth31`时, 还带着`vlan tag`, 值为100. 但是在流经`veth31.100`时, 捕获到的数据包已经没有`vlan tag`了. 并且由于`veth31.100`接入`mybr0`的端口默认带有`pvid`标记, 所以线路就通了.

veth31.100 -> mybr0 也能被接收, 说明流入的数据包是不带 vlan tag 的, 否则会被丢弃.

mybr0 -> veth31.100 过程中, 流出的数据包因为`untagged`的存在, 已经不再有`vlan tag`, 而无tag的数据包直接从 veth31.100 发出, 则会带上 vid 10 的 vlan tag.

------

感觉 ta 们之间的关系就像这样

```
           移除 vlan tag
             ┌─────┐
-------------↑-----↓---------------------
veth31.100 ──┘     └─> mybr0
```

```
           移除 vlan tag
             ┌─────┐
-------------↓-----↑---------------------
veth31.100 <─┘     └── mybr0
```

不管 mybr0 的 veth31.100 vlan 接口有没有配置`untagged`, 在将数据包发送给 vlan 设备时, 一定是没有 vlan tag 的.

