# bridge+vlan实验.03.数据流入vid 100 pvid

恢复引言中的实验网络, 开启 bridge 的 vlan 过滤功能.

```
ip netns exec ns03 ip link set dev mybr0 type bridge vlan_filtering 1
```

## 不带 vlan tag 的数据包, 会被接收, 且 bridge 会给数据包打上 vid 100 的 tag

在`ns03`中执行如下命令, 修改 veth31 接口的 vlan tag

```log
$ bridge vlan del dev veth31 vid 1
$ bridge vlan add dev veth31 vid 100 pvid
$ bridge vlan show
port	vlan ids
veth31	 100 PVID
veth32	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

网络拓扑没变, 从`ns01`中ping 10.1.1.4当然还是不通的, 不过这次数据包并没有被 bridge 丢弃.

数据包流向: veth11 -> veth31 -> mybr0 -🚫> veth32 -> veth22

## 数据包带有 vlan tag, 但 id 不为 100, 则会被丢弃

从 veth11 设备上添加 vid 1 的 vlan 设备.

```
ip netns exec ns01 ip link add link veth11 name veth11.1 type vlan id 1
ip netns exec ns01 ip addr del 10.1.1.3/24 dev veth11
ip netns exec ns01 ip r flush dev veth11
ip netns exec ns01 ip addr add 10.1.1.3/24 dev veth11.1
ip netns exec ns01 ip link set veth11.1 up
```

这样发出的数据包就会带有 vid 1 的 vlan tag 了.

此时网络拓扑如下

```
+-------------------------------+-------------------------------------------------------+
|              netns1           |                  netns3                 |   netns2    |
|  10.1.1.1/24                  |                                         | 10.1.1.2/24 |
|  +----------+      +-------+  |  +-------+     +-------+     +-------+  |  +-------+  |
|  | veth11.1 ├──────┤ veth11|  |  |veth31 | <-> | mybr0 | <-> | veth32|  |  | veth22|  |
|  +----------+      +---↑---+  |  +---↑---+     +-------+     +----↑--+  |  +--↑----+  |
|      vlan              └─────────────┘                            └───────────┘       |
+-------------------------------+-----------------------------------------+-------------+
```

但这下, 数据包又被 bridge 丢弃了.

数据包流向: veth11 -> veth31 -🚫> mybr0 -> veth32 -> veth22

## 数据包带有 vlan tag, 且 id 为 100, 则会被接收并转发

```
ip netns exec ns01 ip link del veth11.1

ip netns exec ns01 ip link add link veth11 name veth11.100 type vlan id 100
ip netns exec ns01 ip addr add 10.1.1.3/24 dev veth11.100
ip netns exec ns01 ip link set veth11.100 up
```

再次ping, bridge 上就已经可以抓到数据了.

数据包流向: veth11 -> veth31 -> mybr0 -🚫> veth32 -> veth22

