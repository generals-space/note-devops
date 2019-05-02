# Linux 服务器做网关

参考文章

1. [关于linux的默认网关](http://rainbird.blog.51cto.com/211214/237082/)

2. [Linux 服务器做网关](https://my.oschina.net/guol/blog/125660)

常见场景是, 一个小型局域网, 某一台主机拥有内外双网卡, 其他主机将这个主机作为网关由它来转发数据包即可连接外网, 其实是相当于一个路由器.

网关服务器: 1.1.1.1 + 2.2.2.2, 其中1.1.1.1是外网网卡IP.

其他服务器: 2.2.2.x

网关服务器上的操作

开启转发

```
$ echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
$ sysctl -p
```

设置SNAT

```
$ iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

其他服务器设置GATEWAY为该网关服务器即可.

