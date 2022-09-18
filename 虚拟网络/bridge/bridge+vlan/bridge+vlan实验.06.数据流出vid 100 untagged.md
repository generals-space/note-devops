# bridge+vlan实验.06.数据流出vid 100 untagged

本实验从实验04继续进行.

为 veth31 添加 untagged 标记.

```console
$ bridge vlan add dev veth31 vid 1 untagged
$ bridge vlan show
port	vlan ids
veth31	 1 Egress Untagged
veth32	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

再次从ns02执行ping操作

数据包从 veth31 接口流出时, 已经不再带有 vlan tag 了.

```console
$ tcpdump -nve not port 22 -i veth31
tcpdump: listening on veth31, link-type EN10MB (Ethernet), capture size 262144 bytes
17:44:07.170793 42:2d:0b:0c:8b:9f > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
17:44:07.170892 36:67:0f:4b:1a:ee > 42:2d:0b:0c:8b:9f, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.3 is-at 36:67:0f:4b:1a:ee, length 28
```

数据包流向:

veth22 -> veth32 -> mybr0 -> veth31 -> veth11
veth22 <- veth32 <- mybr0 <🚫- veth31 <- veth11

由于mybr0 -> veth31流出的数据包已经不带有 vlan tag 了, 所以 veth11 接收到后, 进行了回应.

只不过由于响应包不带 vlan tag, 而且 mybr0 的 veth31 接口又没有 pvid 标记, 所以被 bridge 设备丢弃了.
