# ifconfig配置虚拟IP

网卡上增加一个IP

```
$ ifconfig eth0:1 192.168.0.1 netmask 255.255.255.0
```

删除这个虚拟ip:

```
## 这里指定的是目标虚拟IP, 但网卡接口是实际接口(不带冒号哦)
$ ip addr del 192.168.0.1 dev eth0
```

> 这两种操作都是即时生效, 不需要重启网络服务...maybe

> 通过ifconfig添加的虚拟ip并不会创建新的网络接口, 使用`ip addr`只能看到`eth0`设备上多出一个ip地址.

