# vxlan构建overlay网络

参考文章

1. [VLAN和VXLAN，两者有何区别？VXLAN运用场景有哪些？](https://network.51cto.com/art/201902/592347.htm)
    - 虚拟化的应用加重了交换机的负担
2. [在 Linux 上配置 VXLAN](https://zhuanlan.zhihu.com/p/53038354)
    - `vxlan`设备拥有`fdb`转发表, 可以使用`bridge`命令进行操作.

vlan: `underlay L2`网络, 不适用于云环境.

vxlan: `overlay L3`网络.

vlan实现了L2的广播域隔离, 但不只如此. 

vxlan是为了替代vlan出现的方案, ta最终需要创建一个overlay网络实现ta的目的. 即, vxlan构造的overlay网络, 在L2实现了对vlan的补全.
