# AWS创建IPv6实例记录

参考文章

1. [手把手教你如何在AWS EC2 启用 IPv6](https://www.jianshu.com/p/131409434cec)
2. [亚马逊AWS EC2如何开启ipv6](https://blog.51cto.com/dellinger/2134119)
3. [亚马逊aws开启ipv6的方法图解](https://www.pcwanjia.com/html/2019/08/244.html)
4. [只能用IPv6访问的网站有哪些？](https://www.zhihu.com/question/396298062)
    - 没有哪个商业网站会只运行IPv6单栈协议
    - [What is my IP Address](http://ip6.me/)

## google.com

首先 ping 谷歌是肯定可以的, 且默认解析出 IPv6 的地址来.

```console
$ ping www.google.com
PING www.google.com(ord38s18-in-x04.1e100.net (2607:f8b0:4009:804::2004)) 56 data bytes
64 bytes from ord38s18-in-x04.1e100.net (2607:f8b0:4009:804::2004): icmp_seq=1 ttl=42 time=16.9 ms
64 bytes from ord38s18-in-x04.1e100.net (2607:f8b0:4009:804::2004): icmp_seq=2 ttl=42 time=16.9 ms
^C
--- www.google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 2ms
rtt min/avg/max/mdev = 16.864/16.876/16.888/0.012 ms
```

直接 ping IPv6 的地址也可以 ping 通.

```console
$ ping 2607:f8b0:4009:804::2004
PING 2607:f8b0:4009:804::2004(2607:f8b0:4009:804::2004) 56 data bytes
64 bytes from 2607:f8b0:4009:804::2004: icmp_seq=1 ttl=42 time=16.9 ms
64 bytes from 2607:f8b0:4009:804::2004: icmp_seq=2 ttl=42 time=16.10 ms
^C
--- 2607:f8b0:4009:804::2004 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 16.916/16.942/16.969/0.132 ms
```

在墙内虽然 ping 不通, 但会解析出 IPv4 的地址.

```console
$  ping www.google.com
PING www.google.com (208.43.237.140) 56(84) bytes of data.
^C
--- www.google.com ping statistics ---
631 packets transmitted, 0 received, 100% packet loss, time 630170ms

```

## ipv6.baidu.com

网上有说支持 IPv6 的主机, 在 ping ipv6.baidu.com 这个地址时会出现 IPv6 的解析结果, 否则只会出现 IPv4 的结果.

但是我在 AWS 的主机上 ping 这个地址返回的仍然是 IPv4 的结果, 指定 ping 的协议类型为`-6`还会返回错误.

```console
$ ping ipv6.baidu.com
PING www.wshifen.com (183.232.231.173) 56(84) bytes of data.
64 bytes from 183.232.231.173 (183.232.231.173): icmp_seq=4 ttl=35 time=214 ms
64 bytes from 183.232.231.173 (183.232.231.173): icmp_seq=5 ttl=35 time=214 ms
^C
--- www.wshifen.com ping statistics ---
6 packets transmitted, 2 received, 66.6667% packet loss, time 795ms
rtt min/avg/max/mdev = 214.319/214.363/214.408/0.465 ms
## 指定 IPv6 的方式 ping
$ ping6 ipv6.baidu.com
ping: ipv6.baidu.com: Name or service not known
```

...我都怀疑这个地址是不是部署在 IPv6 的地址上了, 要不就是ta根本没用.

参考文章4提供了一个网址[What is my IP Address](http://ip6.me/), 采用了 IPv4/IPv6 双栈部署. 如果客户端只有 IPv4 的地址, 访问ta将显示 IPv4 的结果; 如果客户端只有 IPv6 的地址, 则会显示 IPv6 的结果; 如果客户端也是双栈, 则会优先显示 IPv6 的结果.

ta还提供了 IPv4/IPv6 两个单栈部署的地址: [IPv4 only](http://ip4.me/)和[IPv6 only](http://ip6only.me/), 不同的协议去访问将会显示"找不到 ip6only.me 的服务器 IP 地址。"

比如, 我本地 PC 网络只有 IPv4, 访问**IPv4/IPv6双栈**和**IPv4单栈**地址则可以得到正确页面.

![IPv4/IPv6 双栈](https://gitee.com/generals-space/gitimg/raw/master/CAC35831379317C33D74103C8059F257.png)

![IPv4 单栈](https://gitee.com/generals-space/gitimg/raw/master/3A84BC3791FC28E9A04F45EA1396A7A9.png)

而访问**IPv6 单栈**会出现错误

![IPv6 单栈](https://gitee.com/generals-space/gitimg/raw/master/1FF1B63E1144BCA07A9D7641775ECD49.png)

同时在AWS主机上, ping [IPv4/IPv6双栈]和[IPv6单栈]的结果如下.

```console
## 这是双栈地址
$ ping ip6.me
PING ip6.me(8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128)) 56 data bytes
64 bytes from 8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128): icmp_seq=1 ttl=37 time=11.1 ms
64 bytes from 8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128): icmp_seq=2 ttl=37 time=11.2 ms
^C
--- ip6.me ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 11.149/11.150/11.151/0.001 ms

## 这是 IPv6 单栈地址
ping ip6only.me
PING ip6only.me(8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128)) 56 data bytes
64 bytes from 8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128): icmp_seq=1 ttl=37 time=11.1 ms
64 bytes from 8210.0000.0000.0000.4800.2083.0d0f.7062.ip6.static.sl-reverse.com (2607:f0d0:3802:84::128): icmp_seq=2 ttl=37 time=11.2 ms
^C
--- ip6only.me ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 11.082/11.132/11.182/0.050 ms
```

而如果 ping [IPv4单栈]域名则只能返回 IPv4 的解析结果.

```
$ ping ip4.me
PING ip4.me (169.45.201.128) 56(84) bytes of data.
64 bytes from 80.c9.2da9.ip4.static.sl-reverse.com (169.45.201.128): icmp_seq=1 ttl=37 time=20.8 ms
64 bytes from 80.c9.2da9.ip4.static.sl-reverse.com (169.45.201.128): icmp_seq=2 ttl=37 time=20.9 ms
^C
--- ip4.me ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 2ms
rtt min/avg/max/mdev = 20.797/20.839/20.881/0.042 ms
```

并未出错, 说明**支持 IPv6 的厂商必须会保持对 IPv4 的支持, 单纯支持 IPv6 的做法还是 too young**.

## 

随便建了个阿里云的主机, 通过 IPv4 协议是可以访问这台 AWS 的, 但是指定为 IPv6 时就会报错.

```
$ ping6 2600:1f16:1c0:d100:203c:cf08:ed7a:1e3f
PING 2600:1f16:1c0:d100:203c:cf08:ed7a:1e3f(2600:1f16:1c0:d100:203c:cf08:ed7a:1e3f) 56 data bytes
From fe80::5054:ff:fe23:dce5%eth0 icmp_seq=1 Destination unreachable: Address unreachable
From fe80::5054:ff:fe23:dce5%eth0 icmp_seq=2 Destination unreachable: Address unreachable
^C
--- 2600:1f16:1c0:d100:203c:cf08:ed7a:1e3f ping statistics ---
2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 2004ms
```

看来是目前的 PC 作为客户端都无法发起 IPv6 的连接, ISP 不给力啊...
