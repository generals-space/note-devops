虚拟网卡, 网桥bridge, 虚拟IP, NAT的区别

vlan, vxlan, macvlan.

参考文章

1. [Linux 上虚拟网络与真实网络的映射](https://www.ibm.com/developerworks/cn/linux/1312_xiawc_linuxvirtnet/index.html)
    - 将现实网络中的元素, 虚拟化环境中的网络元素及Linux系统提供的网络设备模型做了对应, 十分清晰.
    - 列举多个示例在(linux提供的)虚拟化网络模拟现实中的网络拓扑, 还同时提供了最精确与精简后的对比, 很有意义.
    - 经典, 值得收藏
2. [Macvlan介绍及应用实践(一)和(二)](https://www.yangcs.net/categories/network/)
    - Macvlan 的实现原理及其工作模式
    - 通过实验来验证 Macvlan Bridge 模式的连通性
3. [网络虚拟化技术（一）: Linux网络虚拟化](https://blog.kghost.info/2013/03/01/linux-network-emulator/)
    - `ip netns`网络命名空间创建和veth设备连接测试实验
4. [网络虚拟化技术（二）: TUN/TAP MACVLAN MACVTAP](https://blog.kghost.info/2013/03/27/linux-network-tun/)
    - 图解TUN/TAP MACVLAN MACVTAP
5. [图解几个与Linux网络虚拟化相关的虚拟网卡-VETH/MACVLAN/MACVTAP/IPVLAN](https://blog.51cto.com/dog250/1652063)
    - veth虚拟网卡 <-> Macvlan虚拟网卡 应用场景的比较
    - 图解veth和macvlan网络及ta们各自能达到的效果
    - 这个作者的其他文章也可以看一看
6. [虚拟化网络比较: TUN/TAP, MacVLAN, MacVTap](http://www.rendoumi.com/xu-ni-hua-wang-luo-bi-jiao-tun-tap-macvlan-macvtap/)
    - 图解TUN/TAP, MacVLAN, and MacVTap
7. [Linux 虚拟网络基础---namespace、veth pair、bridge 说明和命令实操](https://blog.csdn.net/LL845876425/article/details/82156405)
    - linux网络命名空间netns, tap, veth和bridge的命令实验
8. [Linux虚拟网络设备之tun/tap](https://segmentfault.com/a/1190000009249039)
9. [Linux虚拟网络设备之bridge(桥)](https://segmentfault.com/a/1190000009491002)
    - 这两篇是同一个作者写的系列文章, 值得一看
    - 前者介绍了tap/tun此类虚拟设备与真实设备的区别: tap/tun一端连着内核协议栈, 这一点与真实设备相同, 另一端连接的却是应用程序, 可以说tap/tun是应用程序所需的.
    - 应用程序使用tap/tun的工作流程, 用户层程序通过tun设备只能读写IP数据包, 而通过tap设备能读写链路层数据包, 类似于普通socket和raw socket的差别一样, 处理数据包的格式不一样.
    - 一个C语言示例演示tap/tun编程应用
    - 后者介绍了bridge与veth在创建及配置过程中的网络架构, 十分清晰
    - 将物理网卡添加到bridge(有图示), `ip link set eth0 master mybr0`.
    - bridge必须要配置IP吗?
    - bridge常用场景: 虚拟机, docker
10. [KVM虚拟化的四种简单网络模型介绍及实现（一）](https://blog.51cto.com/jerry12356/2132221)
11. [KVM虚拟化的四种简单网络模型介绍及实现（二）](https://blog.51cto.com/jerry12356/2132246)
12. [虚拟机Linux网络配置](https://blog.51cto.com/13097817/2045868)
    - 分别介绍KVM/VMware各自的网络模型, 原理相同, 可以对比着看
    1. 隔离模型(host only): 虚拟机之间组建网络, 该模式无法与宿主机通信, 无法与其他网络通信, 相当于虚拟机只是连接到一台交换机上. 
    2. 路由模型(vmware无此模型<???>): 相当于虚拟机连接到一台路由器上, 由路由器(物理网卡), 统一转发, 但是不会改变源地址. 
    3. NAT模型: 在路由模式中, 会出现虚拟机可以访问其他主机, 但是其他主机的报文无法到达虚拟机, 而NAT模式则将源地址转换为路由器(物理网卡)地址, 这样其他主机也知道报文来自那个主机, 在docker环境中经常被使用. 
    4. 桥接模型(bridge): 在宿主机中创建一张虚拟网卡作为宿主机的网卡, 而物理网卡则作为交换机. 
13. [TAP/TUN 维基百科](https://en.wikipedia.org/wiki/TUN/TAP)
14. [Linux 中的虚拟网络](https://www.ibm.com/developerworks/cn/linux/l-virtual-networking/)
    - Linux 已经在内核中包含一个 2 层交换机
15. [漫步云中网络](https://www.ibm.com/developerworks/cn/cloud/library/1209_zhanghua_openstacknetwork/index.html)
    - 物理网卡与虚拟网卡之间的关系: 一对一, 一对多, 多对一(bonding负载均衡)
    - 虚拟网络的主要内容: 2层使用TAP设备来实现虚拟网卡, 使用Bridge来实现虚拟交换机, 3层基于Iptable的NAT, 路由及转发, 以及网络隔离vlan.
16. [核心交换机、汇聚交换机区别与应用详解](https://www.feisu.com/bbs/e-1831.html)
    - 核心交换机与汇聚交换机概念区别(有时也分别称为一级, 二级等交换机, 还有接入交换机), 只是在网络架构上的区别, 并不是型号或功能不同.
17. [Linux下单网卡配置属于不同vlan的ip(vlan子接口)](https://www.bladewan.com/2017/05/23/linux_vconfig/)
    - eth0:0, eth0:1 与 eth0.171, eth0.173的区别: 子网卡与虚拟vlan网卡
18. [Linux 上的基础网络设备详解](https://www.ibm.com/developerworks/cn/linux/1310_xiawc_networkdevice/index.html)
    - 不知道怎么归类, 不明觉厉.

NIC: Network Interface Card 网络接口卡, 即网卡, 一般指物理网卡.<???>

虚拟IP: eth0:0, eth0:1 这种eth0和mac地址都是相同的, 本质上还是同一块网卡, 这将限制很多二层的操作.

网桥(Bridge)工作在二层, 了解链路层协议, 按帧转发数据. 就是我们常说的**交换机**(在Linux的语境中, Bridge和Switch是一个概念。), 所以连接到网桥的设备处于同一网段. 交换机就是用来连接2个LAN的. 

但是linux提供的bridge与硬件交换机不同的是, ta可以拥有IP地址...

Veth 设备成对存在, 相当于连接 Bridge 的网线...but这种设备tm也可以有ip.

`net.ipv4.ip_forward` 设置为 1 也相当于 node1 同时充当了一个路由器（路由器的实质就是一个具有多个网卡的机器, 因为它的多网卡同时具有这些不同网段的 IP 地址, 所以它能将一个网络的流量路由转发到另一个网络）. 

TAP...就叫TAP, 不是简写, 模拟第二层数据链路层设备, 操作的是Ethernet frames帧. 用于创建bridge网桥.

TUN则是tunnel, 模拟第三层网络层设备, 操作IP数据包. 用于路由.

> TAP/TUN貌似是编程接口, 用于用户空间的程序向内核网络栈收发数据??? 这是ta们与bridge和iptable的区别吗??? ...不对啊, ip命令也可以创建tap/tun设备的啊.

------

overlay/underlay的概念基本清楚, 但是具体的网络方案还不太明白究竟是哪一种. 比如vlan应该是underlay, vxlan应该是overlay了吧? 另外, calico使用的bgp协议, host gateway网络也属于overlay吧? 所有基于隧道技术的模型应该都是overlay网络吧?

## FAQ

A: 为什么在虚拟化环境中要称为网桥而不是虚拟交换机? 

Q: 网桥其实是小型的交换机.
