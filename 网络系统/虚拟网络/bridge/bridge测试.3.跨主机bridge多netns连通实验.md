# bridge测试.3.跨主机bridge多netns连通实验

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - [x] veth 设备连接两个 netns()
    - [x] bridge 设备连接多个 netns
    - [x] 多主机通过bridge连接各自的 netns

2. [阿里云vpc专有网云服务器 docker swarm overlay多机无法ping通](https://blog.csdn.net/a704397849/article/details/100054793)
3. [【Docker网络原理分析三】直接路由实现bridge之间以及跨主机bridge之间通信](https://blog.csdn.net/u013355826/article/details/102801351)

实验环境(阿里云上的实验失败)

宿主机: Win10
VMWare 15.5.0
虚拟机: CentOS 7
虚拟机采用双网卡, bridge网卡连接宿主机所在网络, 为无线局域网, 网络号为`192.168.0.0/24`, 用于连接外网; host only网卡与宿主机组成本地局域网.


```
                VMware01                                                           VMware02                 
+---------------------------------------+                          +---------------------------------------+
|  +----------------+                   |                          |                   +----------------+  |
|  |   10.1.1.2/24  |                   |                          |                   |   20.1.1.2/24  |  |
|  |   +--------+   |                   |                          |                   |   +--------+   |  |
|  |   | veth11 |   |  netns01          |                          |          netns02  |   | veth21 |   |  |
|  |   +----↑---+   |                   |                          |                   |   +----↑---+   |  |
|  +--------|-------+                   |                          |                   +--------|-------+  |
|    +------↓-----+       +--------+    |                          |    +--------+       +------↓-----+    |
|    |    mybr1   | <---> | veth12 |    |                          |    | veth22 | <---> |    mybr2   |    |
|    +------------+       +--------+    |                          |    +--------+       +------------+    |
|      10.1.1.1/24                      |                          |                       20.1.1.1/24     |
|                         +--------+    |                          |    +--------+                         |
|      172.32.0.11/24     |  ens34 ├───────────┐            ┌───────────┤ ens34  |     172.32.0.12/24      |
|                         +--------+    |      |            |      |    +--------+                         |
|                         +--------+    |      |            |      |    +--------+                         |
|      192.168.0.201/24   |  ens33 |    |      |            |      |    | ens33  |     192.168.0.202/24    |
|                         +----┬---+    |      |            |      |    +----┬---+                         |
+------------------------------|--------+      |            |      +---------|-----------------------------+
                               |          +----↓------|-----↓----+           |                             
                               |          |       host only      |           |                             
                               |          |     172.32.0.1/24    |           |                             
                               |          |        VMware        |           |                             
                               |          +----------------------+           |                             
                               |          +-----------|----------+           |                             
                               |          |                      |           |                             
                               └─────────>|    192.168.0.1/24    |<──────────┘                             
                                          |         路由器        |
                                          +----------------------+
```

host1

```bash
## 双方都要开启
sysctl -w net.ipv4.ip_forward=1

ip netns add netns1
ip link add mybr1 type bridge
ip link add veth11 type veth peer name veth12
ip link set veth12 up
ip link set mybr1 up
ip addr add 10.1.1.1/24 dev mybr1
ip link set veth12 master mybr1

ip link set veth11 netns netns1
ip netns exec netns1 ip link set veth11 up
ip netns exec netns1 ip addr add 10.1.1.2/24 dev veth11
ip netns exec netns1 ip route add default via 10.1.1.1 dev veth11

## 通过物理网卡转发netns的包
ip route add 20.1.1.0/24 via 172.32.0.12 dev ens34
```

host2

```bash
## 双方都要开启
sysctl -w net.ipv4.ip_forward=1

ip netns add netns2
ip link add mybr2 type bridge
ip link add veth21 type veth peer name veth22
ip link set veth22 up
ip link set mybr2 up
ip addr add 20.1.1.1/24 dev mybr2
ip link set veth22 master mybr2

ip link set veth21 netns netns2
ip netns exec netns2 ip link set veth21 up
ip netns exec netns2 ip addr add 20.1.1.2/24 dev veth21
ip netns exec netns2 ip route add default via 20.1.1.1 dev veth21

## 通过物理网卡转发netns的包
ip route add 10.1.1.0/24 via 172.32.0.11 dev ens34
```

失败.

尝试把hosts上netns及bridge的修改成`10.1.1.0/24`的IP, 仍然不成功.

仔细想想, 以物理网络为基础, 构建不同独立网段的子网, 这不就是overlay么? 应该借助隧道机制来实现吧.

另外我又尝试在两个bridge上添加服务器网段的IP, 但是仍然没能互相ping通.

更新: 按照参考文章2中所说, 云服务几乎都不支持vlan/vxlan, 这可能是实验失败的一大原因(vlan/vxlan强烈依赖(虚拟)交换机设备). 使用VMware在本地搭建集群时就可以了.

------

本来以为使用家用路由器是无法实现跨主机的netns通信的, 毕竟这需要二层的支持, 上面的操作是使用host only的网卡实现的, 这其实是VMware实现的虚拟网络, 依赖于其虚拟交换机组件.

但是我又实验了下, 发现通过bridge网卡(物理无线网络)也能实现.

...这应该算是3层转发吧???

host1

```
ip r del 20.1.1.0/24
ip r add 20.1.1.0/24 via 192.168.0.201 dev ens33
```

host2

```
ip r del 10.1.1.0/24
ip r add 10.1.1.0/24 via 192.168.0.202 dev ens33
```

------

有没有发现, 这种网络模型的实现最主要的就是指定使用物理网卡的路由? 

虚拟机本身成为了一个路由器, 因为ta连接了两个不同的网段. 这两个网段能互通的关键在于, 宿主机开启了`ip_forward`, 且设置了确定的路由.
