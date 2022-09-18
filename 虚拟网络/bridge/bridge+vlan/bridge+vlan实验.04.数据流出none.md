# bridge+vlan实验.04.数据流出none

恢复引言中的实验网络, 开启 bridge 的 vlan 过滤功能.

```
ip netns exec ns03 ip link set dev mybr0 type bridge vlan_filtering 1
```

## 任何类型的数据包都不会从 none 标记的接口发出

在`ns03`执行如下命令

```
$ bridge vlan del dev veth31 vid 1
$ bridge vlan show
port	vlan ids
veth31	None
veth32	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

此时网络拓扑不变, 只是 bridge 上的接口标记发生的变动, `ns01`与`ns02`是不通的.

这个网络与实验01中很像, 只不过这次我们要从`ns02`进行ping操作.

数据包流向: veth22 -> veth32 -> mybr0 -🚫> veth31 -> veth11

------

为了进一步验证我们的猜想, 我们继续在 veth31 接口上添加上 vid.

```
$ bridge vlan add dev veth31 vid 1
$ bridge vlan show
port	vlan ids
veth31	 1
veth32	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

此时数据包可以通过 veth31 流出.

```console
$ tcpdump -nve not port 22 -i veth31
tcpdump: listening on veth31, link-type EN10MB (Ethernet), capture size 262144 bytes
17:38:10.384940 42:2d:0b:0c:8b:9f > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
```

数据包流向: veth22 -> veth32 -> mybr0 -> veth31 -> veth11

数据包最终到了 veth11, 只不过没有回应.
