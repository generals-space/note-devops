# tcpdump显示数据包中的vlan tag

参考文章

1. [Tcpdump:抓取vlan的TAG信息](https://blog.51cto.com/molewan/2062159)

`tcpdump`有一个`-e`参数, 可以输出以太网帧头部信息, 其中包括vlan id值, 这是无法通过`-vvv`选项显示的.

如下是dhcp广播请求, 可以看到vlan id为171.

```log
$ tcpdump -nev -i ens33 -p udp
tcpdump: listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
06:15:46.283830 f2:5e:19:84:79:8b > Broadcast, ethertype 802.1Q (0x8100), length 318: vlan 171, p 0, ethertype IPv4, (tos 0x0, ttl 16, id 46080, offset 0, flags [none], proto UDP (17), length 300)
    0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from f2:5e:19:84:79:8b, length 272, xid 0xd3d19da5, Flags [none]
	  Client-Ethernet-Address f2:5e:19:84:79:8b
	  Vendor-rfc1048 Extensions
	    Magic Cookie 0x63825363
	    DHCP-Message Option 53, length 1: Discover
```

tcpdump -nev -i bond0 -p icmp
