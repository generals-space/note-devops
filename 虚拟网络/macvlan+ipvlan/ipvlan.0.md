# ipvlan认识

参考文章

1. [Macvlan 和 IPvlan](https://www.cnblogs.com/menkeyi/p/11374023.html)
    - IPvlan分为两种工作模式: L2/L3

如果说`macvlan`在某种程度上实现了部分`bridge`设备的功能, 那么`ipvlan`就实现了部分`router`的功能.

> 之前一直在想为什么linux虚拟设备中没有虚拟路由器的存在, 还要在宿主机上开`ip_forward`+添加路由规则才能完成, 现在有了 ヾ(*´▽‘*)ﾉ

`ipvlan`设备有2种工作模式:

1. L2: 和 macvlan bridge 模式工作原理很相似, 父接口作为交换机来转发子接口的数据. 同一个网络的子接口可以通过父接口来转发数据, 而如果想发送到其他网络, 报文则会通过父接口的路由转发出去. 
2. L3: 有点像路由器的功能, 它在各个虚拟网络和主机网络之间进行不同网络报文的路由转发工作. 只要父接口相同, 即使虚拟机/容器不在同一个网络, 也可以互相 ping 通对方, 因为 ipvlan 会在中间做报文的转发工作. 

> 一个父接口只能选择一种模式, 依附于它的所有虚拟接口都运行在这个模式下, 不能混用模式.

简单来说, 就是在L2模式下相连的设备可以通信, 但走的是L2, 不会涉及路由. 

如果ipvlan设备是工作在L3, 那么就会经过路由进行转发, 这种情况下会匹配到`iptables`中的`PREROUTING/POSTROUTING`阶段. 

如果ipvlan设备工作在L3, 而各设备的IP又非同一子网, ta们之间是没有办法直接通信的, 除非在宿主机上添加各自的路由. 这个倒不难理解.

------

不能基于`lo`环回网卡创建ipvlan设备.

```console
$ ip link add link lo ipvlan1 type ipvlan mode l3
RTNETLINK answers: Invalid argument
```

另外, 基于`bridge`设备虽然可以创建的`ipvlan`设备, 但是`ipvlan`设备之间不能像基于ether设备那样互通.
