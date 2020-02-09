# bridge划分vlan.2.vlan_filtering

参考文章

1. [KVM + LinuxBridge 的网络虚拟化解决方案实践](http://www.ishenping.com/ArtInfo/1779722.html)
    - 在讲解linux虚拟设备的时候加入了协议栈的角色, 让人理解起来更容易.
    - veth设备不只是网线, 毕竟ta可以拥有IP, 只有在其将连接协议栈的部分断开后才表现的完全是网线的作用.
2. [VLAN filter support on bridge](https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge/)
    - bridge x 2 => bridge x 1 + vlan

## 1. 部署实验网络

```bash
ip netns add netns1
ip netns add netns2
ip netns add netns3
ip netns add netns4
ip netns add netns5

ip link add veth1 type veth peer name veth31
ip link add veth2 type veth peer name veth32
ip link add veth4 type veth peer name veth34
ip link add veth5 type veth peer name veth35

ip link set veth1 netns netns1
ip link set veth2 netns netns2
ip link set veth4 netns netns4
ip link set veth5 netns netns5
ip link set veth31 netns netns3
ip link set veth32 netns netns3
ip link set veth34 netns netns3
ip link set veth35 netns netns3

ip netns exec netns1 ip addr add 10.1.1.101/24 dev veth1
ip netns exec netns2 ip addr add 10.1.1.201/24 dev veth2
ip netns exec netns4 ip addr add 10.1.1.102/24 dev veth4
ip netns exec netns5 ip addr add 10.1.1.202/24 dev veth5

ip netns exec netns3 ip link add mybr0 type bridge
ip netns exec netns3 ip link set veth31 master mybr0
ip netns exec netns3 ip link set veth32 master mybr0
ip netns exec netns3 ip link set veth34 master mybr0
ip netns exec netns3 ip link set veth35 master mybr0

ip netns exec netns3 ip link set mybr0 up
ip netns exec netns1 ip link set veth1 up
ip netns exec netns2 ip link set veth2 up
ip netns exec netns4 ip link set veth4 up
ip netns exec netns5 ip link set veth5 up
ip netns exec netns3 ip link set veth31 up
ip netns exec netns3 ip link set veth32 up
ip netns exec netns3 ip link set veth34 up
ip netns exec netns3 ip link set veth35 up
```

> `bridge`设备不像`veth`那样可以移动到其他`netns`.

此时网络拓扑如下

```
+----------------+---------------------------------------------+----------------+
|    netns1      |                    netns3                   |      netns4    |
| 10.1.1.101/24  |                                             |  10.1.1.102/24 |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
|  | veth1  | <-----> | veth31 ├──┐           ┌──┤ veth34 | <-----> | veth4  |  |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
+----------------+                ├─┤ mybr0 ├─┤                +----------------+
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|  | veth2  | <-----> | veth32 ├──┘           └──┤ veth35 | <-----> | veth5  |  |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
| 10.1.1.201/24  |                                             |  10.1.1.202/24 |
|    netns2      |                                             |     netns5     |
+----------------+---------------------------------------------+----------------+
```

此时两个netns中, 4个`netns`是可以相互ping通的, 因为ta们全在同一个vlan中.

## 2. 切分vlan

**接下来的操作全在`netns3`中执行**

初始的vlan条目如下

```console
$ bridge vlan show
port	vlan ids
veth31	 1 PVID Egress Untagged
veth32	 1 PVID Egress Untagged
veth34	 1 PVID Egress Untagged
veth35	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

接下来还需要划分vlan.

```console
bridge vlan del dev veth31 vid 1
bridge vlan del dev veth32 vid 1
bridge vlan del dev veth34 vid 1
bridge vlan del dev veth35 vid 1
bridge vlan add dev veth31 vid 100 pvid untagged
bridge vlan add dev veth34 vid 100 pvid untagged
bridge vlan add dev veth32 vid 200 pvid untagged
bridge vlan add dev veth35 vid 200 pvid untagged
```

此时vlan条目变成了

```console
$ bridge vlan show
port	vlan ids
veth31	 100 PVID Egress Untagged
veth32	 200 PVID Egress Untagged
veth34	 100 PVID Egress Untagged
veth35	 200 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

```
+----------------+---------------------------------------------+----------------+
|    netns1      |                    netns3                   |      netns4    |
| 10.1.1.101/24  |                  vlan  100                  |  10.1.1.102/24 |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
|  | veth1  | <-----> | veth31 ├──┐           ┌──┤ veth34 | <-----> | veth4  |  |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
+----------------+                ├─┤ mybr0 ├─┤                +----------------+
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|  | veth2  | <-----> | veth32 ├──┘           └──┤ veth35 | <-----> | veth5  |  |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
| 10.1.1.201/24  |                  vlan  200                  |  10.1.1.202/24 |
|    netns2      |                                             |     netns5     |
+----------------+---------------------------------------------+----------------+
```

...但好像还是没有明显作用? 4个`netns`还是可以互相ping通. 

这是

```
ip netns exec netns3 ip link set dev mybr0 type bridge vlan_filtering 1
```

这样, `netns1`就只能ping通`netns4`了, 其他`netns`也按规则隔离开了.
