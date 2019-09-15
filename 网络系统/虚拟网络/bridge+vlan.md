# bridge+vlan

参考文章

1. [KVM + LinuxBridge 的网络虚拟化解决方案实践](http://www.ishenping.com/ArtInfo/1779722.html)
    - 在讲解linux虚拟设备的时候加入了协议栈的角色, 让人理解起来更容易.
    - veth设备不只是网线, 毕竟ta可以拥有IP, 只有在其将连接协议栈的部分断开后才表现的完全是网线的作用.
2. [VLAN filter support on bridge](https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge/)
    - bridge x 2 => bridge x 1 + vlan
3. [Fun with veth-devices, Linux bridges and VLANs in unnamed Linux network namespaces]()
    - [I](https://linux-blog.anracom.com/2017/10/30/fun-with-veth-devices-in-unnamed-linux-network-namespaces-i/)
    - [II](https://linux-blog.anracom.com/2017/11/12/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-ii/)
    - [III](https://linux-blog.anracom.com/2017/11/14/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iii/)
    - [IV](https://linux-blog.anracom.com/2017/11/20/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-iv/)
    - [V](https://linux-blog.anracom.com/2017/11/21/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-v/)
    - [VI](https://linux-blog.anracom.com/2017/11/28/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vi/)
    - [VII](https://linux-blog.anracom.com/2017/12/30/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-vii/)
    - [VIII](https://linux-blog.anracom.com/2018/01/05/fun-with-veth-devices-linux-bridges-and-vlans-in-unnamed-linux-network-namespaces-viii/)
    - 这一系列的文章从内容上来说非常棒, 但作者好像是个德国人, 英文句法看得人一脸萌b, 很多错别字, 阅读障碍相当不小...
