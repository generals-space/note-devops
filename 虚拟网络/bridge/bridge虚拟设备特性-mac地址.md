
bridge设备在创建时拥有独立的mac地址, 但是使用`ip link ... master`接入veth设备后, mac地址会变成第一个(也许是最后一个?)接入设备的mac地址.

当将所有连接的接口拔下后, 其mac值将变为`00:00:00:00:00:00`

...不过这个特性好像也没啥意义.

```
16: br1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether d6:94:d9:2d:68:ca brd ff:ff:ff:ff:ff:ff
    inet6 fe80::d494:d9ff:fe2d:68ca/64 scope link
       valid_lft forever preferred_lft forever
18: veth-32.11-0@if17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 4e:12:6c:db:c0:29 brd ff:ff:ff:ff:ff:ff link-netnsid 2
20: veth-32.12-0@if19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ea:61:1a:7d:6a:d8 brd ff:ff:ff:ff:ff:ff link-netnsid 3
```

接入第1个设备

```
ip link set veth-32.11-0 master br1
```

```
16: br1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 4e:12:6c:db:c0:29 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::d494:d9ff:fe2d:68ca/64 scope link
       valid_lft forever preferred_lft forever
18: veth-32.11-0@if17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master br1 state DOWN group default qlen 1000
    link/ether 4e:12:6c:db:c0:29 brd ff:ff:ff:ff:ff:ff link-netnsid 2
20: veth-32.12-0@if19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ea:61:1a:7d:6a:d8 brd ff:ff:ff:ff:ff:ff link-netnsid 3
```

移除这个接入的设备(本来也只有这一个)

```
ip link set veth-32.11-0 nomaster
```

```
16: br1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::d494:d9ff:fe2d:68ca/64 scope link
       valid_lft forever preferred_lft forever
18: veth-32.11-0@if17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 4e:12:6c:db:c0:29 brd ff:ff:ff:ff:ff:ff link-netnsid 2
20: veth-32.12-0@if19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ea:61:1a:7d:6a:d8 brd ff:ff:ff:ff:ff:ff link-netnsid 3
```
