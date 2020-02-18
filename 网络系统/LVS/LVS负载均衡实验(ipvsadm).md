# LVS负载均衡实验(ipvsadm)

参考文章

1. [Linux负载均衡--LVS（IPVS）](https://www.cnblogs.com/lipengxiang2009/p/7349271.html)
    - IPVS的三种转发模式(DR, NAT, FULLNAT)
    - IPVS支持的调度算法及解释
2. [LVS(IPVS)了解](https://www.cnblogs.com/aguncn/p/10533822.html)
    - IPVS是LVS（Linux Virtual Server）项目重要组成部分, 目前包含于官方Linux Kernel, IPVS依赖于netfilter框架, 位于内核源码的`net/netfilter/ipvs`目录下.
3. [Keepalived详解之 - LVS(IPVS)管理工具ipvsadm使用指南](https://www.cnblogs.com/dspace/p/9706436.html)
    - `ipvsadm`命令应用.
4. [LVS虚拟linux服务器](https://blog.csdn.net/qq_43141726/article/details/100544838)
    - lvs的实际使用场景(DR模式), 即负载均衡的生效实验(网上少有这样的示例文章)
5. [【均衡负载之LVS 系列二】 - LVS 基础配置](https://segmentfault.com/a/1190000019967549)
    - 可以算是参考文章4的补充, 对示例代码有更详细的说明
    - 与参考文章4有细微的差别, 虽然都可用, 但我觉得还是这个比较正规.
6. [LVS NAT模式负载均衡实验](https://www.centos.bz/2017/08/lvs-nat-loadbalance/)
    - lvs NAT模式实验, 可与参考文章5对比阅读.
7. [如何编写LVS对Real Server的健康状态检测脚本](https://www.cnblogs.com/xiaocen/p/3709869.html)
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

- LB server: 192.168.0.10(注意开启`ip_forward`)
- real server: 192.168.0.104/105
- VIP: 192.168.0.200/32

本例使用的是`DR`转发模式, 关于`DR`模式的讲解可以见参考文章1, 十分详细. 配合下面的示例代码, 更容易理解.

**在LB Server上执行**

```bash
ip addr add 192.168.0.200/24 dev eth0
ipvsadm -A -t 192.168.0.200:10000 -s rr
ipvsadm -a -t 192.168.0.200:10000 -r 192.168.0.104:10000 -g
ipvsadm -a -t 192.168.0.200:10000 -r 192.168.0.105:10000 -g
```

- `-A`用于创建VS虚拟服务器
- `-a`用于为VS添加RS后端服务器.

在设置VIP的时候, 参考文章4和5有不同的命令. 前者明确指定了掩码位为32, 且broadcast为VIP本身, 不知道出于什么理由; 而后者则为VIP指定为使用与宿主机网段相同的掩码24.

这里我觉得还是相信后者, 因为VIP本来就是需要依赖于实体网卡实现, 相当于一张网卡占用了两个IP, 局域网的其他机器面对这两个IP的行为应该是相同的.

...不过事实上好像两者并没有什么区别.

**在Real Server上执行**

```bash
ip addr add 192.168.0.200/32 broadcast 192.168.0.200 dev lo
```

RS的VIP并不用于通信, 所以可以设置掩码位为32.

> 参考文章4中有为lo上的VIP设置路由, 但实际上不设置也运行正常, 且参考文章5中并无此操作, 这里仍以后者为准.

但此时局域网环境内进行arp请求, 检测VIP在哪台服务器时, LB与RS都会应答(RS会把lo网卡的mac地址返回). 那么在局域网其他机器上访问VIP时可能会直接定位到RS, 不走LB转发. 这样是不行的. 所以需要禁用real server的ARP请求

```bash
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
```

然后在局域网中任一服务器上访问`192.168.0.200:10000`, 就可以访问到real server的10000端口.

> 注意: 必须是从局域网中的其他服务器上访问. 如果在LB server上, 虽然可以ping通VIP `192.168.0.200`, 但是端口是访问不通的, 而且在real server上访问也没有什么说服力.

> 在实验中我发现, `ipvsadm`设置的VS和RS的端口必须保持相同, 如果向VS添加的RS的端口与VS的不同, 会自动改写RS的端口值.

