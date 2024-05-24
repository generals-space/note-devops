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

## 部署实验网络

本节实验仍然使用前一篇文章中的网络.

网络拓扑如下

```
+-----------------------------+-----------------------------------------------------------------------+
|                     ns01    |                                    ns03                 |    ns02     |
|  10.1.1.3/24                |                                                         | 10.1.1.4/24 |
| +-----------+     +-------+ | +-------+     +-----------+     +-------+     +-------+ |  +-------+  |
| | veth11.100| <-> | veth11| | | veth31| <-> | veth31.100| <-> | mybr0 | <-> | veth32| |  | veth22|  |
| +-----------+     +---↑---+ | +---↑---+     +-----------+     +-------+     +----↑--+ |  +--↑----+  |
|                       └───────────┘                                              └──────────┘       |
+-----------------------------+---------------------------------------------------------+-------------+
```

在这个网络中, `ns01`和`ns02`是可以相互ping通的, 本实验中我们只修改 bridge vlan 接口配置, 不再修改网络结构, 且主要观察从右到左的数据流向.

## 1. `vid 100 -> veth1.100`: 从bridge端口中流出的数据包带有值与`veth vlan`设备的相同的`vlan tag`, 可以被后者接收

先记录一下原始的`vlan`配置.

```log
$ bridge vlan show
port	vlan ids
veth32	 1 PVID Egress Untagged
veth31.100	 1 PVID Egress Untagged
veth31.100
mybr0	 1 PVID Egress Untagged
```

我们把`veth32`和`veth31.100`接入的端口`vid`修改为100, 并且移除后者`untagged`标记.

```bash
bridge vlan del dev veth31.100 vid 1
bridge vlan del dev veth32 vid 1
bridge vlan add dev veth31.100 vid 100
bridge vlan add dev veth32 vid 100 pvid
```

此时`vlan`配置如下

```
$ bridge vlan show
port	vlan ids
veth32	 100 PVID
veth31.100	 100
veth31.100
mybr0	 1 PVID Egress Untagged
```

此时从`ns02`中`ping 10.1.1.3`已经不通了. 在`ns03`中抓包, 结果如下

**veth31**

```log
$ tcpdump -nve -i veth31
05:19:43.350913 8e:d9:b6:70:d3:82 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 100, p 0, ethertype 802.1Q, vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
```

说明数据包已经被转发出去了.

## 2. `vid 200 -> veth1.100`: 从bridge端口流出的数据包带有值为200的`vlan tag`, 但仍会被`veth1.100`修改为100.

修改`veth32`和`veth31.100`的接入端口`vid`值为200.

```bash
bridge vlan del dev veth31.100 vid 100
bridge vlan del dev veth32 vid 100
bridge vlan add dev veth31.100 vid 200
bridge vlan add dev veth32 vid 200 pvid
```

此时`vlan`配置如下

```log
$ bridge vlan show
port	vlan ids
veth32	 200 PVID
veth31.100	 200
veth31.100
mybr0	 1 PVID Egress Untagged
```

再次抓包.

**veth31.100**

```log
$ tcpdump -nve -i veth31.100
05:28:08.309281 8e:d9:b6:70:d3:82 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 200, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
```

**veth31**

```log
$ tcpdump -nve -i veth31
05:28:13.311851 8e:d9:b6:70:d3:82 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 100, p 0, ethertype 802.1Q, vlan 200, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
```

虽然流经`mybr0 -> veth31.100`的数据包都携带值为200的`vlan tag`, 但会被`veth31.100`修改为100.

## 3. `vid 200 untagged -> veth1.100`: 从bridge端口流出的数据包不带`vlan tag`, 也会被`veth1.100`添加上值为100的`vlan tag`.

我们把`veth31.100`接入的端口加上`untagged`标记.

```bash
bridge vlan del dev veth31.100 vid 200
bridge vlan add dev veth31.100 vid 200 untagged
```

修改后的vlan配置为

```log
$ bridge vlan show
port	vlan ids
veth32	 200 PVID
veth31.100	 200 Egress Untagged
veth31.100
mybr0	 1 PVID Egress Untagged
```

再次抓包.

**veth31.100**

```
$ tcpdump -nve -i veth31.100
05:47:32.509708 8e:d9:b6:70:d3:82 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
05:47:32.509724 a2:df:d5:0d:c3:a1 > 8e:d9:b6:70:d3:82, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.3 is-at a2:df:d5:0d:c3:a1, length 28
```

**veth31**

```
$ tcpdump -nve -i veth31
05:47:45.543786 8e:d9:b6:70:d3:82 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.3 tell 10.1.1.4, length 28
05:47:45.543803 a2:df:d5:0d:c3:a1 > 8e:d9:b6:70:d3:82, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.3 is-at a2:df:d5:0d:c3:a1, length 28
```

虽然`veth31.100`接入的端口流出的数据包不带有`vlan tag`, 但仍会被`veth31.100`设备加上值为100的`vlan tag`. 
