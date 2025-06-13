参考文章

1. [动态维护FDB表项实现VXLAN通信](http://just4coding.com/2020/04/20/vxlan-fdb/)
    - 对于大规模的VXLAN网络中，最核心的问题一般有两个:
        1. 如何发现网络中其他VTEP
        2. 如何降低BUM（Broadcast, Unknown unicast, Multicast)流量
2. [VLAN和VXLAN，两者有何区别？VXLAN运用场景有哪些？](https://network.51cto.com/art/201902/592347.htm)
    - 虚拟化的应用加重了交换机的负担
3. [在 Linux 上配置 VXLAN](https://zhuanlan.zhihu.com/p/53038354)
    - `vxlan`设备拥有`fdb`转发表, 可以使用`bridge`命令进行操作.

vxlan是为了替代vlan出现的方案, ta最终需要创建一个overlay网络实现ta的目的. 即, vxlan构造的overlay网络, 在L2实现了对vlan的补全.
