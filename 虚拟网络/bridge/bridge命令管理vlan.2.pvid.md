# bridge命令管理vlan(三)-pvid

参考文章

1. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces – IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - 系列文章第4章, 对bridge设备的vlan设置规则有详细介绍, 本章并没有提供代码示例.
2. [Linux 如何实现 VLAN - 每天5分钟玩转 OpenStack（12）](https://mp.weixin.qq.com/s?__biz=MzIwMTM5MjUwMg==&mid=2653587920&idx=1&sn=79332fb8fd8370b8d6b7d9728c383008&chksm=8d3081c9ba4708df9fcff17839e3c0fbb53a82298799c15ee45889f830a0087a46672505f115&scene=21#wechat_redirect)
    - `Access`口与`Trunk`口各自的作用

在使用物理交换机组网时, 连接到同一组vlan端口的主机可以组成一个广播域, 当然vlan端口是需要事先在交换机的命令行中按序号手动划分的.

而在使用虚拟交换机bridge时, 则需要考虑更多的东西. 你不能说把`veth`设备一端连接到bridge就成了, 需要考虑数据流入和流出两个方面. 

- 流入: 设备 -> bridge
- 流出: bridge -> 设备

1. 从设备流入到bridge的数据包中带有的`vlan tag`, 需要与该设备在bridge中的相关的vlan条目(设备连接到bridge时会自动创建与之相关的条目)相同, 否则流入的数据包将被丢弃;
2. 从bridge流出到设备的数据包, 可以在bridge中配置是否将`vlan tag`移除, 如不移除, 则只有与该`vlan tag`相同的设备才能够接收;

在`bridge vlan`子命令的操作中, `vid`参数表示vlan id, 而`pvid`则为

在bridge中, 带有`pvid`和`untagged`标记的端口叫作`access port`, 不带的叫`trunk port`. `trunk`口不会对进入和发出的数据包中的tag进行修改, 类似于透传.


```
ip link add link <ethX | vethX > name vlanX.100 type vlan id 100 
```

`vlanX.100`(名称随意)的作用在于, 数据流向为`vlanX.100 -> ethX|vethX`的时候, 到达ethX或vethX设备的数据包中会携带`vlan tag`, 但反过来则不会.

