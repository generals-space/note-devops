参考文章

1. [网卡虚拟化技术 macvlan 详解](https://www.cnblogs.com/gdg87813/p/13355019.html)
    - 这篇文章在介绍 macvlan 的4种模式时, 将private放在了vepa前面, 实际上private是对vepa基础上进行的扩展和优化...
    - macvlan 这种技术听起来有点像 VLAN，但它们的实现机制是完全不一样的。macvlan 子接口和原来的主接口是完全独立的，可以单独配置 MAC 地址和 IP 地址，而 VLAN 子接口和主接口共用相同的 MAC 地址。
    - VLAN 用来划分广播域，而 macvlan 共享同一个广播域。
2. [网卡也能虚拟化？网卡虚拟化技术 macvlan 详解](https://www.cnblogs.com/bakari/p/10641915.html)
    - 同1
3. [Linux 虚拟网卡技术：Macvlan](https://juejin.cn/post/6844903810851143693)
    - 这篇文章讲解得十分细致
    - 现在大多数交换机都不支持 Hairpin 模式，但 Linux 主机中可以通过一种 Harpin 模式的 Bridge 来让 VEPA 模式下的不同 Macvlan 接口通信
    - linux Bridge 其实就是一种旧式交换机
5. [docker网络之macvlan](https://www.cnblogs.com/charlieroro/p/9656769.html)
6. [图解几个与Linux网络虚拟化相关的虚拟网卡-VETH/MACVLAN/MACVTAP/IPVLAN](https://blog.csdn.net/dog250/article/details/45788279)
    - `vepa`的实现原理

