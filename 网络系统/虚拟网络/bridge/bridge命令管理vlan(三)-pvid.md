# bridge命令管理vlan(三)-pvid

参考文章

1. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces – IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - 系列文章第4章, 对bridge设备的vlan设置规则有详细介绍, 本章并没有提供代码示例.

在bridge中, 带有`pvid`和`untagged`标记的端口叫作`access port`, 不带的叫`trunk port`.

trunk口不会对进入和发出的数据包中的tag进行修改, 类似于透传.
