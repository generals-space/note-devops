# vlan的创建方式.3.ip link add link

参考文章

1. [ArchLinux VLAN](https://wiki.archlinux.org/index.php/VLAN)

参考文章1给出了一个通过`ip link add link`的方式创建`vlan`设备.

```
ip link add link eth0 name eth0.100 type vlan id 100
```

`eth0.100`明显是用于本机虚拟环境使用的, 所有被路由到此接口上的数据包, 都会被转发到`eth0`上并携带上vlan tag, 然后被`eth0`转发出去, 而转发出去的数据也需要对端设备可以接收`vlan`包才行, 否则这些数据包会被丢弃.

另外, `ip link add link`创建vlan的目标不只可以是物理网卡`eth0`, 也可以是`veth`, `bridge`设备.
