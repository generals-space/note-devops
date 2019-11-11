# VMware克隆节点后网卡混乱导致无法上网的解决过程

参考文章

1. [CentOS 7 下网络管理之命令行工具nmcli](https://www.jianshu.com/p/5d5560e9e26a)
2. [解决Centos网卡IP和配置文件不符的问题]（http://icestrawberryxjw.me/2019/03/06/ip-conf-file-inconsistency/)
3. [在 RHEL8 配置静态 IP 地址的不同方法](https://juejin.im/post/5d8cde1151882509662c5b9b)

宿主机: Win 10
VMware: 15.5.0
虚拟机: CentOS 7

场景描述

为了测试linux overlay虚拟网络在vmware集群中的表现, 尝试搭建一个双节点的局域网. 

先克隆一个work节点, 为其添加两个网卡: 

一个使用host only模式, 仅与宿主机和另一个节点组成局域网用于测试netns的跨宿主机通信, 网段为`192.168.0.0/24`

另一个使用bridge模式用于连接外网(之后也可以用于通过路由器的跨宿主机通信), 网段为`172.32.0.0/24`.

但是克隆机启动后无法连接外网, 我确认了`/etc/sysconfig/network-scripts/ifcfg-xxx`网卡配置文件是没问题的(我配置了静态IP), 但是执行`systemctl restart network`后, 虽然这个网卡的网络接口IP是正确的, 但是路由却是错乱的. 同时出现了两个`default`路由, 并且多条路由中的dev字段所表示的网络接口与其IP不匹配(比如eth0的IP为192.168网段, 但是某条路由中出现了`172.32.100.2 dev eth0 proto static`).

```
default via 172.32.100.2 dev ens33 proto static metric 100
172.32.100.2 dev ens33 proto static scope link metric 100
```

更让人匪夷所思的是, `172.32.100.0/24`这个网段是另一台电脑上通过VMware创建的, 这个网段也是那时定义的, 但在克隆时所在电脑上的Vmware不存在这样的网段. 

克隆后居然又出现了, 说明这个路由信息(也许是之前的网卡信息)存放在work节点的系统中, 但是我还不知道这个机制的运行原理.

## 1. 

为了解决这个问题, 我找了许多方法.

我重新确认了一遍我没有把网卡和`ifcfg-xxx`配置弄混, 但是重启network服务与重启虚拟机都不能解决路由错乱的问题.

```
DEVICE=ens33
ONBOOT=yes
TYPE=Ethernet
## BOOTPROTO=dhcp
BOOTPROTO=static
IPV6INIT=yes
IPADDR=192.168.0.201
NETMASK=255.255.255.0
DNS1=192.168.0.1
```

我也考虑过是不是由于克隆导致网卡的mac地址, 或是uuid的变动. 但我检查了一下, work与work的克隆机的mac地址和uuid并不冲突.

我的`ifcfg-xxx`配置里没有mac地址和uuid的字段, 我有想过是不是因为只用DEVICE字段无法唯一确认一个物理接口. 然后我加入了

```
HWADDR=00:00:00:11:22:33
UUID=3dd172bf-4768-4a2d-8a4b-110bdbdbb1c8
```

重启network与虚拟机仍然无效, 我有些崩溃...

------

哦, 我有想过双网卡可能由于启动顺序导致默认路由的可能(默认网卡的`ifcfg-xxx`文件添加`DEFROUTE=yes`字段即可), 为此我先将两个网卡接口都`set down`, 然后一个一个启动, 实际上, 只启动一个bridge接口的时候路由中都出现了`172.32.100.2`, 这太扯淡了. 

然后我把host only网卡删除了, 然而...至少可以证明系统中的确存在某种余力影响着当前网卡的网络配置.

------

我本身比较自信我目前(2019-11-10)对linux的网络已经非常熟练, 所以没有想过先手动设置路由把实验搞定. 尝试了上面很多种方法失败后我想妥协了, 然而我把多余的路由删掉, 手动创建使用bridge网络为默认的路由时竟然不管用!? 因为虚拟机里竟然连网关(192.168.0.1)都ping不通!

太失败了.

## 2. 

此时最严重的就是无法ping通网关了, 毕竟理论上这是物理直接网络, 不应该ping不通.

我也有考虑过可能是我修改了VMware的虚拟网络(虚拟网络编辑器), 听说1, 3, 8号虚拟网络是VMware内置的, 分别表示NAT, host only和bridge(对应关系应该不是一样, 不重要), 于是我把ta重置了. 

神奇的是虚拟机竟然可以连通外网了, 但是此时的网络参数都是初始的, 不是静态IP, 也意味着我写的`ifcfg-xxx`配置没有生效.

此时我首先考虑的是, 如何把当前正确的网络配置导出到文件中(就像iptables-save一样)?

于是我找到了`nmcli`.

ta的`nmcli c up 接口名称`可以保存并重新加载网络配置.

ok, 现在的bridge网络是通过DHCP自动获取的, 那么我将执行如下命令将其更改为静态IP, 并导出网络配置.

```
nmcli con mod ens33 ipv4.addresses 192.168.0.201/24
nmcli con mod ens33 ipv4.gateway 192.168.0.1
nmcli con mod ens33 ipv4.dns 192.168.0.1
nmcli con mod ens33 ipv4.method static
nmcli con up ens33 ## 保存并重新加载
```

完成后会将`ens33`设备的配置写入`/etc/sysconfig/network-scripts/`目录下.

```
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=3dd172bf-4768-4a2d-8a4b-110bdbdbb1c8
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.0.201
PREFIX=24
GATEWAY=192.168.0.1
DNS1=192.168.0.1
```

我首先猜的是添加一个`UUID`字段, 但是不生效, 又想了想, 加上了`GATEWAY`字段, 成了...

后来我又把`GATEWAY`字段注释掉, 发现路由中又出现了`172.32.100.2`...呵呵

```
DEVICE=ens33
ONBOOT=yes
TYPE=Ethernet
## BOOTPROTO=dhcp
BOOTPROTO=static
IPV6INIT=yes
NETWORK=192.168.0.0
IPADDR=192.168.0.201
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=192.168.0.1
```

然后再加第2张网卡, 配置文件以上面为模板, 就不会再出错了...WTF
