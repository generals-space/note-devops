# IPv6的路由转发[sysctl]

参考文章

1. [linux – 转发IPv6流量](http://www.voidcn.com/article/p-tqlcusvb-bty.html)
2. [Forwarding IPv6 traffic](https://serverfault.com/questions/459759/forwarding-ipv6-traffic)
    - 参考文章1的原文

IPv4 数据转发的开启选项为`net.ipv4.ip_forward`

IPv6 的则为`net.ipv6.conf.all.forwarding`. 

这里的`all`指的是所有的网卡接口, 如果使用`sysctl -a | grep ipv6.conf | grep forwarding`查看, 你会发现所有接口都有`forwarding`选项, 如果设置了`all`, 就相当于为所有网卡接口设置了转发.

