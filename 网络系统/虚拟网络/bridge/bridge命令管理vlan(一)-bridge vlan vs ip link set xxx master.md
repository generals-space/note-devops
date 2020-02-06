# bridge命令管理vlan(一)-bridge vlan vs ip link set xxx master

本文里只是确认一下`ip link`与`bridge`操作在逻辑上的关系...

创建两个`netns`, 用一个`veth`将其连接起来

```bash
ip netns add netns1
ip netns add netns2
ip link add veth1 type veth peer name veth2
ip link set veth1 netns netns1
ip link set veth2 netns netns2
ip netns exec netns1 ip addr add 10.1.1.11/24 dev veth1
ip netns exec netns1 ip link set veth1 up
ip netns exec netns2 ip addr add 10.1.1.12/24 dev veth2
ip netns exec netns2 ip link set veth2 up
```

```
+--------------------------------------------+--------------------------------------------+
|    netns1                                  |                                  netns2    |
|                                            |                                            |
|   +------------+        +--------------+   |   +--------------+                         |
|   |  .1.1/24   |        | 10.1.1.11/24 |   |   | 10.1.1.12/24 |                         |
|   +------------+        +--------------+   |   +--------------+        +------------+   |
|   | veth11.100 | <----> |     veth1    |   |   |    veth2     | <----> |    mybr2   |   |
|   +------------+  vlan  +--------------+   |   +--------------+        +------------+   |
|                                 ↑          |           ↑                                |
|                                 └----------------------┘                                |
|                                            |                                            |
+--------------------------------------------+--------------------------------------------+
```


```
## 在netns2中创建bridge
ip netns exec netns2 ip link add mybr2 type bridge
ip netns exec netns2 ip link set mybr2 up

## 在netns2从veth2接口创建两个vlan接口
ip netns exec netns2 ip link add link veth2 name veth2.100 type vlan id 100
ip netns exec netns2 ip link add link veth2 name veth2.200 type vlan id 200
ip netns exec netns2 ip addr add 10.1.1.101/24 dev veth2.100
ip netns exec netns2 ip addr add 10.1.1.201/24 dev veth2.200
ip netns exec netns2 ip link set veth2.100 up
ip netns exec netns2 ip link set veth2.200 up
```

由于`ip link`命令族无法对`bridge`设备的`vlan`功能进行更细致的操作, 所以需要借助`bridge`命令, 这也是`iproute2`安装包提供的工具.

我们做如下测试.

```
## 创建网桥, 初始状态.
## ip netns exec netns2 ip link add mybr2 type bridge
$ bridge vlan show
port	vlan ids
mybr2	 1 PVID Egress Untagged

## 将veth2设备接入网桥
## ip netns exec netns2 ip link set veth2 master mybr2
$ bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
mybr2	 1 PVID Egress Untagged

## 将veth2.100子接口接入网桥
## ip netns exec netns2 ip link set veth2.100 master mybr2
$ bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
veth2.100	 1 PVID Egress Untagged
mybr2	 1 PVID Egress Untagged
```

> 注意: `bridge vlan add`无法添加`dev`为`veth2.100`这种已经是vlan类型的设备.

```console
## 使用bridge删除veth2.100在网桥上的接口
$ bridge vlan del dev veth2.100 vid 1
$ bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
veth2.100	None
mybr2	 1 PVID Egress Untagged

## `ip link`发现veth2.100仍然master mybr2, 好像并没有作用.
$ ip link ls
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth2.100@veth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue master mybr2 state DOWN mode DEFAULT qlen 1000
    link/ether 3a:e9:67:d5:20:2d brd ff:ff:ff:ff:ff:ff
3: veth2.200@veth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN mode DEFAULT qlen 1000
    link/ether 3a:e9:67:d5:20:2d brd ff:ff:ff:ff:ff:ff
4: mybr2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 3a:e9:67:d5:20:2d brd ff:ff:ff:ff:ff:ff
674: veth2@if675: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master mybr2 state UP mode DEFAULT qlen 1000
    link/ether 3a:e9:67:d5:20:2d brd ff:ff:ff:ff:ff:ff link-netnsid 0

## ip link set的nomaster可以
$ ip link set veth2.100 nomaster
$ bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
mybr2	 1 PVID Egress Untagged
```

`bridge vlan`的操作可以看到是对`bridge`设备的`vlan`条目的管理, 而`ip link set <dev> master|nomaster`则可以看作是对物理接口的插拔.

如下, 使用`bridge vlan add`前必须使用`ip link set ... master`将物理接口连接上, 否则会出错.

```console
$ bridge vlan add vid 100 dev veth2
RTNETLINK answers: Operation not supported
$ ip link set veth2 master mybr2
$ bridge vlan add vid 100 dev veth2
$ bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
	     100
mybr2	 1 PVID Egress Untagged
```

使用`ip link set <dev> master <bridge>`命令将设备接入网桥, 你会发现在`bridge vlan show`中接入的设备存在一些默认值, 如`vlan id`为1, 并且拥有`PVID`和`Egress Untagged`标签.

然而使用`bridge vlan add`添加vlan条目, 除了`vid`字段是必须指定的, `PVID`与`Egress Untagged`只能通过`pvid`与`untagged`两个选项显式指定, 否则将为空.
