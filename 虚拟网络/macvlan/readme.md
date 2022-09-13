参考文章

1. [Linux 虚拟网卡技术：Macvlan](https://cloud.tencent.com/developer/article/1495440)
    - 云原生实验室
    - Macvlan的父接口不只可以是 eth0 物理网卡接口, 也可以是802.1q的子接口(eth0.1), 还可以是`bonding`接口.
    - Macvlan 的实现原理及其4种工作模式
2. [Macvlan 网络方案实践](https://cloud.tencent.com/developer/article/1495218)
    - 云原生实验室
    - 通过实验来验证 Macvlan Bridge 模式的连通性
3. [macvlan虚拟接口](https://www.jianshu.com/p/a599d2a9a1ef)
4. [Linux Macvlan的虚拟网卡与宿主物理网卡之间的Bridge通信问题](https://blog.csdn.net/dog250/article/details/81074426)
    - 数据包流通图不错

Macvlan的4种工作模式

1. Bridge: 与通过 bridge 网桥实现的功能很像, 同主机上不同子接口间可以直接通信, 不经过父接口. 但和bridge绝不一样, 它不需要学习 MAC 地址, 也不需要STP, 因此效能比起使用 Linux bridge 好上很多.
2. VEPA(Virtual Ethernet Port Aggregator): 看一下示意图, 会发现同主机上不同子接口间的通信需要从父接口出去, 再折回来才可以, 无法直接通信.
3. Private: 子接口可以与外部主机进行通信, 但是同一主机上不同的子接口之间不可以, 就算先发到外面都回不来.
4. Passthru: 每个父接口只能创建一个子接口并绑定.

![](https://gitee.com/generals-space/gitimg/raw/master/2022/8a685e81ff1dd178120d4e01bcaf5e7d.png)

从数据包的流通图上来看, 可以发现, 连通性: bridge > vepa > private > passthru

