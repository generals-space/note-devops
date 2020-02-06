# 多网卡主机为某一组网卡创建bond后没有默认路由的问题

参考文章

1. [linux绑定bond的七种模式](https://www.jianshu.com/p/13425a7e29a6)
    - 文末最后一句命令手动创建默认路由
2. [How to add IP Route using Channel Bonding in RHEL6](https://www.linuxquestions.org/questions/linux-networking-3/%5Bask%5D-how-to-add-ip-route-using-channel-bonding-in-rhel6-4175444142/)
    - `/etc/sysconfig/network-scripts/route-bond0`
3. [Bonding and default gateway problem (CentOS)](https://serverfault.com/questions/220646/bonding-and-default-gateway-problem-centos)

系统环境: CentOS 8

eth0: 192.168.0.10/24
eth1: 172.32.0.10/24

```
TYPE=Ethernet
NAME=eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.0.10
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=192.168.0.1
DEFROUTE=yes
```

```
TYPE=Ethernet
NAME=eth1
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=static
IPADDR=172.32.0.10
NETMASK=255.255.255.0
GATEWAY=172.32.0.1
DEFROUTE=no
```

------

创建的bond接口配置为

```
TYPE=bond
DEVICE=bond0
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.0.10
NETWORK=192.168.0.0/24
GATWAY=192.168.0.1
DNS1=192.168.0.1
USERCTL=no
BONDING_OPTS="mode=1 miimon=100"
DEFROUTE=yes
```

修改后的eth0配置如下

```
TYPE=Ethernet
NAME=eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none

USERCTL=no
MASTER=bond0
SLAVE=yes
```

> `eht1`网卡保持不变, 没有创建bond接口.

但是重启网络后, 服务器无法连接外网, 查看路由发现, 系统中没有默认路由了...

```
$ ip r
172.32.0.0/24 dev eth1 proto kernel scope link src 172.32.0.130 metric 100
192.168.0.0/24 dev bond0 proto kernel scope link src 192.168.0.10 metric 300
```

之前没有仔细看, 后来发现网络中大部分文章都是手动创建默认路由的(也有创建`route-bond0`网络配置的).

但是我觉得手动配置路由太麻烦, 我试过将`DEFROUTE`字段从`bond0`配置文件再移回到`eth0`, 或是两者都配置`DEFROUTE`, 但是都没用.

后来在参考文章3中找到了灵感, 在`/etc/sysconfig/network`中添加`GATEWAY=192.168.0.1`, 再次重启网络, 就可以了(在`eth0`中添加`GATEWAY`仍然不起作用).

看来是bond模型下会使原来的网络配置失效啊, `network`文件中的配置应该是全局的(不如把`DNS1`也移进去好了).
