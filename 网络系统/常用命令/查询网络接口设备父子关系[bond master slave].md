参考文章

1. [listing parent interface of a vlan](https://serverfault.com/questions/882754/listing-parent-interface-of-a-vlan)

以 bond 设备为例

```bash
$ cat /sys/class/net/bond0/bonding/slaves
eth0 eth1
```

或者还有一种通用的方式

```log
$ ls -al /sys/class/net/bond0/
...省略
lrwxrwxrwx  1 root root    0 Nov 25 07:58 lower_eth0 -> ../../../pci0000:87/0000:87:02.0/0000:88:00.0/net/eth0
lrwxrwxrwx  1 root root    0 Nov 25 07:58 lower_eth1 -> ../../../pci0000:86/0000:86:02.0/0000:87:00.0/net/eth1
...省略
lrwxrwxrwx  1 root root    0 Dec  3 14:01 upper_vlan.0 -> ../vlan.0
lrwxrwxrwx  1 root root    0 Dec  3 14:01 upper_vlan.1 -> ../vlan.1
lrwxrwxrwx  1 root root    0 Dec  3 14:01 upper_vlan.2 -> ../vlan.2
lrwxrwxrwx  1 root root    0 Dec  3 14:01 upper_vlan.3 -> ../vlan.3
```

该目录下的`lower_*`表示底层设备, `upper_xxx`表示连接到该设备的上层设备.
