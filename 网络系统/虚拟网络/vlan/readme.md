参考文章

1. [《每天5分钟玩转 OpenStack》教程目录](https://www.jianshu.com/p/4c06dff6cea8)
    - 系列教程目录
2. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces]()
    - [I](https://linux-blog.anracom.com/2017/10/30/fun-with-veth-devices-in-unnamed-linux-network-namespaces-i/)
        - lxc, cgroup, namespace等技术引言
    - [II](https://linux-blog.anracom.com/2017/11/12/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-ii/)
        - 实验索引(一共8个)
    - [III](https://linux-blog.anracom.com/2017/11/14/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iii/)
        - 使用bridge+veth连接两个netns
    - [IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
        - 在veth设备的一端创建vlan子接口时, 是否另一端也必须使用vlan子接口?
        - 什么情况下可以只在veth设备一端使用vlan子接口?
        - `veth`和`veth vlan`哪种可以用来连接到bridge设备? 如果都可以, 会有什么不同?
    - [V](https://linux-blog.anracom.com/2017/11/21/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-v/)
    - [VI](https://linux-blog.anracom.com/2017/11/28/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vi/)
    - [VII](https://linux-blog.anracom.com/2017/12/30/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vii/)
    - [VIII](https://linux-blog.anracom.com/2018/01/05/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-viii/)
    - 这一系列的文章从内容上来说非常棒, 但作者好像是个德国人, 英文句法看得人一脸萌b, 很多错别字, 阅读障碍相当不小...
    - 从veth设备创建vlan子设备(`ip link add link veth1 name veth1.100 type vlan id 100`)

| 流入设备  | 入口端口配置 | 出口端口配置   | 流出设备  |
|:----------|:-------------|:---------------|:----------|
|           | vid 100      |                |           |
| veth1     | vid 100 pvid | untagged       | veth1     |
| veth1.100 | vid 200      | vid 100 tagged | veth1.100 |
|           | vid 200 pvid | vid 200 tagged | veth1.100 |

**流入场景**

1. `veth1 -> vid 100`: `veth1`可以看作网线, 对数据进行透传, 其流入的数据包可能包含`vlan tag`, 也可能没有. 见**实验1**.
    - **重点:** 如果数据包是`untagged`的, 则不会被接收;
    - 如果数据包中包含`vlan tag`, 但`vlan id`不为100, 也不会接收;
    - 只有数据包中包含`vlan tag`且`vlan id`为100才会被接收并转发;
2. `veth1 -> vid 100 pvid`: 见**实验2**.
    - 如果数据包是`untagged`的, 则会被接收, 且会被打上值为100的`vlan tag`, 之后也会根据此值寻找合适的端口进行转发;
    - **重点**: 数据数据包中包含`vlan tag`, 但`vlan id`不为100, 也不会接收;
    - 只有数据包中包含`vlan tag`且`vlan id`为100才会被接收并转发;
3. `veth1.100 -> vid 100`: 来自`veth1.100`的数据包都会包含`vlan tag`, 其中`vlan id`为100, 所以会被直接接收.
4. `veth1.100 -> vid 100 pvid`: 同第3点.
5. `veth1 -> vid 200`: 同第1点.
6. `veth1 -> vid 200 pvid`: 同第2点.
7. `veth1.100 -> vid 200`: **重点**: 由于来自`veth1.100`流入的数据包一定不会带有`vlan tag`, 所以这一场景同第5点. 见**实验3**.
8. `veth1.100 -> vid 200 pvid`: 由于来自`veth1.100`流入的数据包一定不会带有`vlan tag`, 所以这一场景同第6点.

**流出场景**

1. `untagged -> veth1`: 由于流出数据包不带有`vlan tag`, 所以可以直接流出.
2. `untagged -> veth1.100`: 从bridge端口中流出的数据包带有值与`veth vlan`设备的相同的`vlan tag`, 可以被后者接收. 但这并不准确, 见第3点. 见**实验4**.
3. `vid 100 -> veth1.100`: 从bridge端口流出的数据包带有值为200的`vlan tag`, 但仍会被`veth1.100`修改为100. 见**实验4**.
4. `vid 200 -> veth1.100`: 从bridge端口流出的数据包不带`vlan tag`, 也会被`veth1.100`添加上值为100的`vlan tag`. 见**实验4**.

