# Keepalived配置(一)-入门

参考文章

[使用keepalived实现双机热备](http://blog.csdn.net/kkdelta/article/details/39433137)

通常说的双机热备是指两台机器都在运行，但并不是两台机器都同时在提供服务(这一点与负载均衡架构不同). 当提供服务的一台出现故障的时候，另外一台会马上自动接管并且提供服务，而且切换的时间非常短。

使用keepalived可以实现对这两台(也可以是多台)实现监控, 当原来提供服务的一方出现故障, 将备机切换过来继续服务.

## 1. 实现原理

keepalived用到Linux下的虚拟IP的概念.

测试环境如下

nodeA: CentOS6  192.168.8.4

nodeB: CentOS6  192.168.8.6

VIR_IP(虚拟IP): 192.168.8.100

如下图所示

![](https://gitee.com/generals-space/gitimg/raw/master/df7c0b15582550e531fdb50595eae77b.png)

其中nodeA与nodeB分别只有一块网卡`eth0`, 分别绑定`8.4`与`8.6`两个IP, 虚拟IP`8.100`在`192.168`网段所在的局域网中没有被其他机器占用, 这个很重要!!! A与B主机上都需要启动`keepalived`服务, 互相监控对方是否正常运行. 但客户端连接该服务的IP是VIR_IP-`8.100`, 而不是A与B其中的任意一个. 

假设初始时, 两节点正常工作, A作为主节点, 两个`keepalived`会协商, 将`8.100`这个IP绑定到A的eth0接口的MAC地址上, 并将这个消息广播出去, 局域网中其他机器会把**`8.100`这条IP与A节点的MAC地址**的对应信息更新到自己的ARP表. 这样, 来访`8.100`的请求就会被发送到A节点. 

当节点A发生故障的时候，节点B上的`keepalived`会检测到，并且将下面的信息广播出去, `8.100`这个IP对应的MAC地址为节点B网卡的MAC地址. 
局域网中其它电脑会更新自己的ARP表, 切换完成.

但这样仅仅实现了IP的切换(可能也叫做'飘移'), 数据库类型的服务器往往实现主从集群, 从节点不可写. 当主节点故障, `keepalived`把从节点推到了前面, 但从节点没有办法实现写操作, 这个时候需要将从节点提升为主节点, 并且当原来的主节点恢复正常时, ~~作为新的从节点备用~~, 原来的主节点会再次获得主节点角色, 这貌似是根据`priority`的值确定的. `keepalived`提供了角色切换时执行指定脚本的方式, 十分方便.

## 2. 实践

首先关闭防火墙, CentOS6为`iptables`, CentOS7为`firewalld`, 否则不能相互发现, 各自认为自己是主节点.

还有关闭SELinux, 因为在配置`notify_*`字段时, SELinux会阻碍目标脚本的执行.

A与B原来的IP配置为

```shell
[root@20ce69da6dac ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
208: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.8.4/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:9/64 scope link 
       valid_lft forever preferred_lft forever

```

```shell
[root@6bef839be587 ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
212: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:0c brd ff:ff:ff:ff:ff:ff
    inet 192.168.8.6/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:c/64 scope link 
       valid_lft forever preferred_lft forever

```

接下来配置`keepalived`

A节点的配置

```conf
global_defs {  
    ## 表示运行Keepalived服务器的一个标识, 名称而已, 不会冲突
    router_id nodeA  
}
## 监测实例名 VI_1, 可自定义
vrrp_instance VI_1 {  
    state MASTER    #设置为主服务器  
    interface eth0  #监测网络接口  
    virtual_router_id 51  #该值可以随意, 但是主、备必须一样. 注意不要与其他keepalived组冲突  
    priority 100   #(主、备机取不同的优先级，主机值较大，备份机值较小,值越大, 切换时优先级越高, 多主机时会很有用)  
    advert_int 1   # VRRP Multicast广播周期秒数  
    authentication {  
    auth_type PASS  #VRRP认证方式，主备必须一致  
    auth_pass 1111   #(密码)  
    } 
    virtual_ipaddress {  
        192.168.8.100/24  #VRRP HA虚拟IP地址, 不能被其他主机占用, 否则会冲突  
    }  
}
```

B节点的配置

```conf
global_defs {  
    ## 表示运行Keepalived服务器的一个标识, 名称而已, 不会冲突
    router_id nodeB  
} 
## 监测实例名 VI_1
vrrp_instance VI_1 {  
    state BACKUP    #设置为主服务器  
    interface eth0  #监测网络接口  
    virtual_router_id 51  #主、备必须一样  
    priority 90   #(主、备机取不同的优先级，主机值较大，备份机值较小,值越大优先级越高)  
    advert_int 1   #VRRP Multicast广播周期秒数  
    authentication {  
        auth_type PASS  #VRRP认证方式，主备必须一致  
        auth_pass 1111   #(密码)  
    }  
    virtual_ipaddress {  
        192.168.8.100/24  #VRRP HA虚拟地址  
    } 
}
```

启动服务, 并且启动keepalived, 可以看到A节点的IP配置如下(注意eth0下有两个IP), 而B节点的IP配置不变.

```shell
[root@20ce69da6dac keepalived]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
208: eth0@if209: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.8.4/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.8.100/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:9/64 scope link 
       valid_lft forever preferred_lft forever

```

将A节点关闭, 可以看到`8.100`这个IP显示在了B节点的`eth0`接口下, 实现了IP的切换. 对应的ARP广播消息在`/var/log/message`中可以看到.

需要注意的是, 貌似哪个作为节点是由各个`keepalived`中的`priority`的值决定的, 不管`state`是`MASTER`还是`BACKUP`, 也不管A, B的启动顺序.

上面这种只是对整个主机的存活状况监控, 还可以对单个服务监控, 这样就不是当主机宕机才会切换, 而是当服务实例挂掉也会进行切换. 不过`keepalived`不能实现端口的监控, 而是需要服务本身有监控的接口(或者直接telnet目标服务监听的端口), `keepalived`可以每隔一段时间执行该脚本来判断.