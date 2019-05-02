# Linux 配置笔记

## 1. Linux 配置静态IP

### CentOS

貌似7+与7-都适用啊.

编辑`/etc/sysconfig/network-scripts/ifcfg-你的eth网卡编号`

```shell
DEVICE="eth0"
BOOTPROTO="static"
## HWADDR="00:0C:29:f4:72:2e"
## IPV6INIT="yes"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR="172.32.100.100"
NETMASK="255.255.255.0"
BROADCAST="172.32.100.255"
# DNS1=x.x.x.x
```

解释:

- DEVICE为描述网卡对应的设备别名, 例如ifcfg-eth0的文件中它为eth0

- BOOTPROTO设置网卡获得ip地址的方式, 可能的选项为`static`, `dhcp`或`bootp`, 分别对应静态指定的 ip, 通过dhcp协议获得的ip, 通过bootp协议获得的ip

- HWADDR=00:07:E9:05:E8:B4 #对应的网卡物理地址

如果配置的是VMware虚拟机的NAT网卡, 这样就足够了. 不需要配置网关, 重启虚拟后会自动配置好的. 不过如果是多网卡情况下, 还是需要设置一下的, 免得访问不了外网. 默认网关的配置文件在`/etc/sysconfig/network`, 格式为`GATEWAY=x.x.x.x`即可.

## 2. 修改网卡名称

参考文章

[Linux网卡重命名](http://blog.csdn.net/itjobtxq/article/details/40828917)

VMWare下配置虚拟机曾多次增删网卡, 结果网卡名称变成从`eth1`开始而不是从`eth0`开始. 有点强迫症, 最主要是写脚本进行批量操作会遇到诸多不便, 所以想改回来.

CentOS7-系统下, 修改`/etc/udev/rules.d/70-persistent-net.rules`文件, 将其中的`eth*`改成你想要的名字, 重启网络服务即可(有时要重启服务器).

不过有时自己修改过`/etc/sysconfig/network-scripts`下的网卡配置文件, 虽然上面的文件中没有了`eth2`, 但如果此目录下存在`ifcft-eth2`文件的话, `ifconfig`或`ip a`还是会出现eth2的. 

## 3. network文件

CentOS7下

`/etc/sysconfig/network`

```
## 网关
GATEWAY=192.168.1.253
```

`/etc/sysconfig/network-scripts/ifcfg-网上编号`

```
## DNS手动设置
DNS1=192.168.1.2
DNS2=192.168.1.3
```

## 4. 添加/删除虚拟IP(网卡别名)

网卡上增加一个IP

```
$ ifconfig eth0:1 192.168.0.1 netmask 255.255.255.0
```

删除网卡的第二个IP地址:

```
## 这里指定的是目标虚拟IP, 但网卡接口是实际接口(不带冒号哦)
$ ip addr del 192.168.0.1 dev eth0
```

> 这两种操作都是即时生效, 不需要重启网络服务...maybe