# ip tunnel无法删除通道设备gre-Operation not supported

参考文章

1. [Cannot Delete GRE Tunnel](https://serverfault.com/questions/247767/cannot-delete-gre-tunnel)

手动创建了1个`gre`设备, 然后就出现了3个名字里带`gre`的接口...

```console
$ ip tunnel add tun_gre0 mode gre local 10.10.1.1
$ ip a
11: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default qlen 1000
    link/gre 0.0.0.0 brd 0.0.0.0
12: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
13: tun_gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default qlen 1000
    link/gre 10.10.1.1 brd 0.0.0.0
```

`tun_gre0`可以正常删除, 但是剩下两个就搞不掉了.

```
$ ip tunnel del tun_gre0
$ ip tunnel del gre0
delete tunnel "gre0" failed: Operation not supported
$ ip tunnel del gretap0
delete tunnel "gretap0" failed: Operation not supported
```

我试着像`ipip`的解决方法一样, 执行了一下`modprobe -r`

```
$ modprobe -r gre
modprobe: FATAL: Module gre is in use.
```

O_O

最后还是找到了参考文章1. 本质上其实还是个`ipip`一个问题, 只不过要卸载的内核模块不该是`gre`.

```
$ lsmod | grep gre
ip_gre                 22749  0
ip_tunnel              25163  1 ip_gre
gre                    13144  1 ip_gre
```

`ip_gre`才是要卸载的目标啊...
