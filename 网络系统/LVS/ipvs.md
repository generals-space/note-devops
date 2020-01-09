参考文章

1. [Linux负载均衡--LVS（IPVS）](https://www.cnblogs.com/lipengxiang2009/p/7349271.html)
    - IPVS的三种转发模式(DR, NAT, FULLNAT)
    - IPVS支持的调度算法及解释
2. [LVS(IPVS)了解](https://www.cnblogs.com/aguncn/p/10533822.html)
    - IPVS是LVS（Linux Virtual Server）项目重要组成部分, 目前包含于官方Linux Kernel, IPVS依赖于netfilter框架, 位于内核源码的`net/netfilter/ipvs`目录下.
3. [Keepalived详解之 - LVS(IPVS)管理工具ipvsadm使用指南](https://www.cnblogs.com/dspace/p/9706436.html)
    - `ipvsadm`命令应用.
4. [LVS虚拟linux服务器](https://blog.csdn.net/qq_43141726/article/details/100544838)
    - lvs的实际使用场景, 即负载均衡的生效实验(网上少有这样的示例文章)
5. [如何编写LVS对Real Server的健康状态检测脚本](https://www.cnblogs.com/xiaocen/p/3709869.html)
    - lvs和调度算法的图示详解, 待阅读

## 命令应用

`ipvsadm`主要有两种使用场景.

第一种, 管理virtual server(类似nginx中的`server`块).

```
ipvsadm command [protocol] service-address [-s <scheduling-method>] [-p <persistence>]
```

- protocol: 协议类型, 可选值`-t(tcp)`, `-u(udp)`;
- service-address: 虚拟服务地址(监听地址), 如`192.168.0.10:8080`, 唯一. 类似于nginx中的`listen`指令, IP+port唯一标记一个server块;
- scheduling-method: 负载调度方法, 如rr, wrr, wlc等.
- persistence: 持久性选项, 整型数值, 单位为秒. 在`persistence`时间内, 保持粘滞会话.

第二种, 创建real server(类似于nginx中的`upstream`块)

```
ipvsadm command [protocol] service-address <-r server-address> [packet-forwarding-method] [weight]
```

- server-address: 真实服务器地址(转发的目的地址)
- packet-forwarding-method: 数据包转发算法, 可选值`-g(dr)`, `-i(iptunnel)`, `-m(NAT)`
- weight: 权重, 0-65535的整型数值.

## 示例

**环境准备**

- LB server: 192.168.0.10
- real server: 192.168.0.104/105
- VIP: 192.168.0.200/32


在LB server上执行

```
$ ip addr add 192.168.0.200/32 broadcast 192.168.0.200 dev eth0
$ ip route add 192.168.0.200 scope host dev eth0
$ ipvsadm -A -t 192.168.0.200:10000 -s rr
$ ipvsadm -a -t 192.168.0.200:10000 -r 192.168.0.104:10000 -g
$ ipvsadm -a -t 192.168.0.200:10000 -r 192.168.0.105:10000 -g
```

在real server上执行

```
$ ip addr add 192.168.0.200/32 broadcast 192.168.0.200 dev lo
$ ip route add 192.168.0.200 scope host dev lo
```


禁用real server的ARP请求

```
$ echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
$ echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
$ echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
$ echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
```

然后在局域网中任一服务器上访问`192.168.0.200:10000`, 就可以访问到real server的10000端口.

> 在实验中我发现, `ipvsadm`设置的VS和RS的端口必须保持相同, 如果向VS添加的RS的端口与VS的不同, 会自动改写RS的端口值.

