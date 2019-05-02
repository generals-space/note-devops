# Linux路由配置

参考文章

1. [IP路由查找的“最长匹配原则”](http://blog.csdn.net/ceelo_atom/article/details/47164943)

2. [Linux 路由和多网卡网关的路由出口设置](http://www.cnblogs.com/fengyc/p/6533112.html)

3. [route命令参数详解，linux添加删除路由命令](http://blog.csdn.net/hzhsan/article/details/44753533)

## 1. route命令应用

只给出示例, 其他的可以举一反三, 详细选项需要查看man手册.

场景描述: 

网关主机: 172.16.19.10, 172.32.100.10

当前主机: 172.16.19.20

查看系统当前路由规则

```
$ route -n
```

`-n`禁止域名反解(没必要), 直接以ip形式显示.

添加/删除单条规则

```
## 设置网段路由
$ route add -net 9.123.0.0 netmask 255.255.0.0 gw 9.123.0.1 [dev 网卡名称]
$ route del -net 9.123.0.0 netmask 255.255.0.0 gw 9.123.0.1 [dev 网卡名称]
## 单目标主机路由
route add -host 172.32.100.2 gw 172.16.19.10 dev eno33554984
```

------

与ifconfig设置网络参数一样, 这种方式设置的路由规则在系统重启后就会失效, 为了能永久生效, 我们需要写在配置文件中.

```
172.17.2.0/24 via 172.16.230.109 dev eth0  
```