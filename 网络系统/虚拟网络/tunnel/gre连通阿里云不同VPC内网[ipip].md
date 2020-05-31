# gre连通阿里云不同VPC内网[ipip]

参考文章

1. [Linux ipip隧道及实现](http://www.361way.com/linux-tunnel/5199.html)
    - 移动IPv4主要有三种隧道技术, 它们分别是: IP in IP, 最小封装以及通用路由封装
        - IP in IP: 即`ipip`
        - 最小封装: 应该是`sit`, `Simple Internet Transition`
        - 通用路由封装: `gre`, `Generic Routing Encapsulation`
    - Linux系统内核实现的IP隧道技术主要有三种(PPP、PPTP和L2TP等协议或软件不是基于内核模块的): ipip、gre、sit
    - ipip最简单, 但只能传输IP包; gre(CISCO)最为通用, 可以传输广播包和IPv6(ipip不行)
2. [阿里云VPC网络之间通过GRE隧道打通](https://www.yunwei123.com/%E9%98%BF%E9%87%8C%E4%BA%91vpc%E7%BD%91%E7%BB%9C%E4%B9%8B%E9%97%B4%E9%80%9A%E8%BF%87gre%E9%9A%A7%E9%81%93%E6%89%93%E9%80%9A/)
3. [通过 GRE 隧道 实现 VPC 互通方案介绍](https://yq.aliyun.com/articles/69035)
    - 阿里云环境虚拟路由的配置
4. [IP/GRE隧道配置说明](https://www.viayc.com/2019/03/15/IPGRE%E9%9A%A7%E9%81%93%E9%85%8D%E7%BD%AE%E8%AF%B4%E6%98%8E/)
    - 搭建隧道时需要在双方vpc下添加路由表, 安全组开放公网ip对端地址和内网对端ip地址（不限端口 -1/-1）
5. [公司与机房的GRE隧道配置实例](https://blog.51cto.com/icenycmh/1932232)
    - 公司内网与机房网络互联, 但是仍需要双方拥有公网IP.

## 引言

...隧道得是双向的, 即建立隧道的两台主机**本来就可以互相通信(通过路由)**. 

一台主机在内网, 另一台在阿里云是无法实现的, 因为本地主机没有公网IP, 阿里云服务器无法建立连接.

网上的文章的实验环境, 要么是两台主机都在内网, 要么是两台主机都拥有公网IP, 这样可以直接建立隧道.

## 实践

阿里云上开了两台服务器, 分别在杭州和香港.

杭州A: 公网 `47.114.45.139` 内网 `172.16.156.195/20`(所属网络为`172.16.144.0/20`)
香港B: 公网 `8.210.37.47`   内网 `172.31.249.7/20`  (所属网络为`172.31.240.0/20`)

> 所属网络及内网网关等信息可以查看路由获取

A

```bash
ip tunnel add tun_gre0 mode gre remote 8.210.37.47 local 172.16.156.195
ip link set tun_gre0 up
ip addr add 192.168.1.1 peer 192.168.1.2 dev tun_gre0
ip r add 172.31.240.0/20 dev tun_gre0
```

B

```bash
ip tunnel add tun_gre0 mode gre remote 47.114.45.139 local 172.31.249.7
ip link set tun_gre0 up
ip addr add 192.168.1.2 peer 192.168.1.1 dev tun_gre0
ip r add 172.16.144.0/20 dev tun_gre0
```

普通环境下这样应该就可以了, 顶多是iptables放开`gre`流量.

```
iptables -I INPUT -p gre -j ACCEPT
```

但是在云环境中, iptables规则都是空的, 且默认策略为`ACCEPT`. 但此时双方仍是无法通信的, 还需要设置虚拟路由器和安全组, 以香港主机为例.

![](https://gitee.com/generals-space/gitimg/raw/master/3297D55CA106926B133888DF8F03E650.png)

> 路由表中下一跳类型为"ECS", 下一跳的地址为香港主机自身的id.

![](https://gitee.com/generals-space/gitimg/raw/master/4281717A311B7EAA5B20115EF38F7D01.jpg)

> 红框中圈起来的部分, 协议类型有一种是`gre`, 应该也可以.

------

...不过后来我把路由表和安全组的设置都删除了, 双方还是能ping通, 可能是由于缓存的原因吧???

------

随后我把gre隧道删除, 重新创建了ipip隧道. 在没有对应虚拟路由表项和安全组配置的情况下, 双方也能相互ping通. 

不过奇怪的是, 当 A ping B 时, 并没有直接回应, 如果同时在 B 上再 ping A, 那么双方都会有响应...看起来不像是全双工的样子. 只有当设置了双方的安全组后, 才能在一方直接ping通另一方...呵呵

