# bond示例-ifcfg配置

系统环境: CentOS 8

原`ens160`接口配置

```conf
TYPE=Ethernet
NAME=ens160
DEVICE=ens160
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.0.104
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=192.168.0.1
```

按照如下配置创建bond接口.

创建bond配置

```conf
TYPE=bond
DEVICE=bond0
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.0.104
NETWORK=192.168.0.0/24
GATWAY=192.168.0.1
DNS1=192.168.0.1

USERCTL=no
BONDING_OPTS="mode=1 miimon=100"
```

并且修改`ens160`的配置

```conf
TYPE=Ethernet
NAME=ens160
DEVICE=ens160
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER=bond0
SLAVE=yes
```

然后重启网络`systemctl restart network`即可(貌似不用手动加载module).

网上有很多示例中的配置都不标准, bond配置中`TYPE`写成了`Ethernet`, 或是修改`ens160`配置中`BOOTPROTO`为`dhcp`, 不过都没关系, bond设备可以正常运行.

在bond接口配置文件中

- `ONBOOT`可以代替开机启动的`ifenslave bond0 eth0 eth1`命令.

- `BONDING_OPTS`可以代替`module`加载配置文件中的`options bond0 miimon=100 mode=1`.

