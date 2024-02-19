# Linux 配置静态IP

环境

CentOS(貌似7+与7-都适用啊)

编辑`/etc/sysconfig/network-scripts/ifcfg-你的eth网卡编号`

```shell
DEVICE=eth0
BOOTPROTO=static
## HWADDR=00:0C:29:f4:72:2e
## IPV6INIT=yes
ONBOOT=yes
TYPE=Ethernet
IPADDR=172.32.100.100
NETMASK=255.255.255.0
## vmware中, nat类型虚拟机的网关地址一般为"x.x.x.2", 需要额外设置.
GATEWAY=172.32.100.2
## vmware中, nat类型虚拟机的dns地址也可以写成 GATEWAY 的地址
# DNS1=x.x.x.x
BROADCAST=172.32.100.255
```

解释:

- `DEVICE`为描述网卡对应的设备别名, 例如ifcfg-eth0的文件中它为eth0
- `BOOTPROTO`设置网卡获得ip地址的方式, 可能的选项为`static`, `dhcp`或`bootp`, 分别对应静态指定的 ip, 通过dhcp协议获得的ip, 通过bootp协议获得的ip
- `HWADDR=00:07:E9:05:E8:B4` #对应的网卡物理地址

如果配置的是VMware虚拟机的NAT网卡, 这样就足够了. 不需要配置网关, 重启虚拟后会自动配置好的. 不过如果是多网卡情况下, 还是需要设置一下的, 免得访问不了外网. 默认网关的配置文件在`/etc/sysconfig/network`, 格式为`GATEWAY=x.x.x.x`即可.
