# arp动态与静态记录

参考文章

1. [ARP缓存记录种类动态条目和静态条目](https://my.oschina.net/u/1585857/blog/397725)

ARP记录是有过期时间的, 但这并不是绝对的. 系统自动向局域网广播以获得ARP时, 记录将被写为动态的, 过期失效. 但是用户可以在手动添加记录时将其标记静态的, 除非手动删除, 否则一直存在.

在windows下用`arp`命令可以看到**静态**和**动态**两种记录

```
 gener@WORKGROUP  ~ $ arp
接口: 192.168.0.8 --- 0x18
  Internet 地址         物理地址              类型
  192.168.0.1           a8-6b-7c-9b-10-f6     动态
  192.168.0.2           18-65-90-ce-39-1d     动态
  192.168.0.255         ff-ff-ff-ff-ff-ff     静态
  224.0.0.22            01-00-5e-00-00-16     静态
```

在linux下用`arp`命令可以得到如下

```log
$ arp
Address                  HWtype  HWaddress           Flags Mask            Iface
_gateway                 ether   a8:6b:7c:9b:10:f6   C                     ens160
10.254.2.0               ether   ee:95:c0:ba:b8:eb   CM                    flannel.1
k8s-master-02            ether   00:0c:29:fb:3d:ed   C                     ens160
```

所有的ARP记录都有`C`标记, 而拥有`M`标记的则是静态记录, 否则是动态记录.

使用`ip neighbour`的结果如下

```log
$ ip neighbour
192.168.0.1 dev ens160 lladdr a8:6b:7c:9b:10:f6 REACHABLE
10.254.2.0 dev flannel.1 lladdr ee:95:c0:ba:b8:eb PERMANENT
192.168.0.102 dev ens160 lladdr 00:0c:29:fb:3d:ed REACHABLE
```

其中拥有`PERMANENT`标记的为静态记录, `REACHABLE`则为动态记录.

------

使用`ip neigh add`添加arp记录时, 不能指定"PERMANENT"还是"REACHABLE", 所有通过`ip neigh add`添加的记录都只能是"PERMANENT"类型.

