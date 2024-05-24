# Linux命令-dig使用说明[dns nslookup]

参考文章

1. [Dig命令使用大全（转自别人翻译），稍加整理](https://www.cnblogs.com/longyongzhen/p/6592954.html)
2. [linux下安装使用dig命令](https://www.cmsky.com/linux-dig/)

## 最简使用 - 直接查询某个域名

```log
$ dig t.cn
...
;; QUESTION SECTION:
;t.cn.				IN	A

;; ANSWER SECTION:
t.cn.			5	IN	A	203.107.55.116

;; Query time: 6 msec
;; SERVER: 172.16.91.2#53(172.16.91.2)
;; WHEN: 五 11月 13 00:04:53 CST 2020
;; MSG SIZE  rcvd: 38
```

一般我们想要的就是`ANSWER SECTION`中的`A`记录, 其中也有可能会包含`CNAME`记录.

如果输出中没有`ANSWER SECTION`, 只给出了个`AUTHORITY SECTION`(内容格式见下面的示例), 说明目标域名在没找到, 用了`AUTHORITY SECTION`中的 dns 服务器解析也没找到, 那估计就是不存在了.

最下面一块`SERVER`, 显示了本次查询默认使用的 dns 服务器地址(相当于默认路由, 出口第一跳).

## 指定 dns 服务器查询某个域名

一般用来测试目标 dns 服务器工作是否正常

像下面的示例, `172.16.91.10`就没有运行 dns 服务

```log
$ dig @172.16.91.10 t.cn

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> @172.16.91.10 t.cn
; (1 server found)
;; global options: +cmd
;; connection timed out; no servers could be reached
$ telnet 172.16.91.10 53
Trying 172.16.91.10...
telnet: connect to address 172.16.91.10: Connection refused
```

下面就比较正常

```log
$ dig @172.16.91.2 t.cn

;; QUESTION SECTION:
;t.cn.				IN	A

;; ANSWER SECTION:
t.cn.			5	IN	A	203.107.55.116
```

## 查询某域名的 ns 列表

ns: name server, 就是我们在注册域名时, 提供该域名的解析服务的域名服务器地址.

![](https://gitee.com/generals-space/gitimg/raw/master/847f167e81ffcbcb0f5a1fa3e88cbd19.png)

```log
sh-4.2# dig ns note.generals.space

;; QUESTION SECTION:
;note.generals.space.		IN	NS

;; AUTHORITY SECTION:
generals.space.		5	IN	SOA	dns9.hichina.com. hostmaster.hichina.com. 2016030109 3600 1200 3600 360

```

其中`AUTHORITY SECTION`就是可以为我这个域名提供解析服务的 dns 服务器地址了.

> `soa`貌似是主 dns 服务器, 可以使用`dig soa note.generals.space`命令确认

## 常用选项

### +short 只查询IP

简明使用，只会输出A记录(写脚本的时候容易获取ip地址)

```log
$ dig t.cn +short
203.107.55.116
```

### +search 添加后缀

在k8s的pod中, /etc/resolv.conf文件中通常都有`search`字段, 如下

```log
nameserver 10.96.0.10
search mcp-middleware.svc.cs-dev.hpc svc.cs-dev.hpc cs-dev.hpc
options ndots:5
```

dig默认是不会为"Pod名称.Service名称"再去添加后缀的, 所以可能找不到

```log
$ dig +short mcp-redis-1.mcp-redis-svc
## 啥也没有
```

此时需要加上`+search`选项, 让dig顺着/etc/resolv.conf的指向去找

```log
$ dig +short +search mcp-redis-1.mcp-redis-svc
10.23.151.143
```

### `+trace`

还没用到过, 有点类似于`traceroute`路由追踪, 因为 dns 记录也是一级一级递归查询的.
