# bridge划分vlan.1.(失败示例)

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

ip link add veth11 type veth peer name veth31
ip link add veth12 type veth peer name veth32
ip link add veth23 type veth peer name veth33
ip link add veth24 type veth peer name veth34

ip link set veth11 netns netns1
ip link set veth12 netns netns1
ip link set veth23 netns netns2
ip link set veth24 netns netns2
ip link set veth31 netns netns3
ip link set veth32 netns netns3
ip link set veth33 netns netns3
ip link set veth34 netns netns3

ip netns exec netns1 ip addr add 10.1.1.101/24 dev veth11
ip netns exec netns1 ip addr add 10.1.1.201/24 dev veth12
ip netns exec netns2 ip addr add 10.1.1.102/24 dev veth23
ip netns exec netns2 ip addr add 10.1.1.202/24 dev veth24

ip netns exec netns3 ip link add mybr0 type bridge
ip netns exec netns3 ip link set veth31 master mybr0
ip netns exec netns3 ip link set veth32 master mybr0
ip netns exec netns3 ip link set veth33 master mybr0
ip netns exec netns3 ip link set veth34 master mybr0

ip netns exec netns3 ip link set mybr0 up
ip netns exec netns1 ip link set veth11 up
ip netns exec netns1 ip link set veth12 up
ip netns exec netns2 ip link set veth23 up
ip netns exec netns2 ip link set veth24 up
ip netns exec netns3 ip link set veth31 up
ip netns exec netns3 ip link set veth32 up
ip netns exec netns3 ip link set veth33 up
ip netns exec netns3 ip link set veth34 up
```

> `bridge`设备不像`veth`那样可以移动到其他`netns`.

此时网络拓扑如下

```
+----------------+---------------------------------------------+----------------+
|    netns1      |                    netns3                   |      netns2    |
| 10.1.1.101/24  |                                             |  10.1.1.102/24 |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
|  | veth11 | <-----> | veth31 ├──┐           ┌──┤ veth33 | <-----> | veth23 |  |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|                |                ├─┤ mybr0 ├─┤                |                |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|  | veth12 | <-----> | veth32 ├──┘           └──┤ veth34 | <-----> | veth24 |  |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
| 10.1.1.201/24  |                                             |  10.1.1.202/24 |
+----------------+---------------------------------------------+----------------+
```

此时两个netns中, 4个IP是可以相互ping通的, 因为ta们全在同一个vlan中.

需要注意, 由于`netns1`和`netns2`中各有两个IP, 也因为会存在两条路由. 比如在`netns1`中

```console
$ ip r
10.1.1.0/24 dev veth11 proto kernel scope link src 10.1.1.101
10.1.1.0/24 dev veth12 proto kernel scope link src 10.1.1.201
```

> 如果你发现在`netns1`中ping不通`10.1.1.101`和`10.1.1.201`, 或是在`netns2`中ping不通`10.1.1.102`和`10.1.1.202`, 可以试着把ta们各自的`lo`接口启动起来.

## 2. 划分vlan

**接下来的操作全在`netns3`中执行**

初始的vlan条目如下

```console
$ bridge vlan show
port	vlan ids
veth31	 1 PVID Egress Untagged
veth32	 1 PVID Egress Untagged
veth33	 1 PVID Egress Untagged
veth34	 1 PVID Egress Untagged
mybr0	 1 PVID Egress Untagged
```

接下来还需要划分vlan.

```console
bridge vlan del dev veth31 vid 1
bridge vlan del dev veth32 vid 1
bridge vlan del dev veth33 vid 1
bridge vlan del dev veth34 vid 1
bridge vlan add dev veth31 vid 100 pvid untagged
bridge vlan add dev veth33 vid 100 pvid untagged
bridge vlan add dev veth32 vid 200 pvid untagged
bridge vlan add dev veth34 vid 200 pvid untagged
```

此时vlan条目变成了

```console
$ bridge vlan show
port	vlan ids
veth31	100 PVID Egress Untagged
veth32	200 PVID Egress Untagged
veth33	100 PVID Egress Untagged
veth34	200 PVID Egress Untagged
mybr0	1 PVID Egress Untagged
```

```
+----------------+---------------------------------------------+----------------+
|    netns1      |                    netns3                   |      netns2    |
| 10.1.1.101/24  |                  vlan  100                  |  10.1.1.102/24 |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
|  | veth11 | <-----> | veth31 ├──┐           ┌──┤ veth33 | <-----> | veth23 |  |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|                |                ├─┤ mybr0 ├─┤                |                |
|  +--------+    |    +--------+  | +-------+ |  +--------+    |    +--------+  |
|  | veth12 | <-----> | veth32 ├──┘           └──┤ veth34 | <-----> | veth24 |  |
|  +--------+    |    +--------+                 +--------+    |    +--------+  |
| 10.1.1.201/24  |                  vlan  200                  |  10.1.1.202/24 |
+----------------+---------------------------------------------+----------------+
```

...但好像还是没有明显作用? 4个IP还是可以互相ping通. 

这是因为bridge设备默认不开启vlan过滤功能, 需要手动开启. 输入如下命令

```
ip netns exec netns3 ip link set dev mybr0 type bridge vlan_filtering 1
```

...还是没作用（⊙.⊙）

## 3. 不成功? 哪里出了问题?

开启`vlan_filtering`后, 4个IP还是可以互相ping通.

最初以为是每个`netns`有两条路由的问题, 然后把`netns1`和`netns2`都移除了一条路由, 结果发现还是没用.

后来在进行了第2个实验才醒悟过来, 一个`netns`中存在两个网卡本身就是有问题的. 

于是把`netns3`的`veth33`从`mybr0`中移除, 在`netns1`中`ping 10.1.1.202`就不通了.

可以得出结论, 其实是因为之前的实验中, 数据包经过了这样一个流程`veth11 -> veth31 -> mybr0 -> veth33 -> veth23 -> veth24`.

