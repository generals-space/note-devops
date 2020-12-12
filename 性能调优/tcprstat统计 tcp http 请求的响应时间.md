# tcprstat统计 tcp http 请求的响应时间

参考文章

1. [tcprstat分析服务的响应速度利器](https://www.cnblogs.com/qmfsun/p/11726702.html)
2. [通过 tcprstat 工具统计应答时间](https://gohalo.me/post/linux-tcprstat.html)
3. [Lowercases/tcprstat](https://github.com/Lowercases/tcprstat/releases)
    - github 仓库地址及二进制下载地址

`tcprstat`是用来监测 tcp 端口的响应时间的工具, 说是请求在服务器端的处理时间，其输出结果包括了响应的很多统计值，用来诊断服务器端。

这是一个基于`libpcap`的工具，通过提取 TCP libpcap 的捕获时间 (`struct pcap_pkthd.ts`) 用来计算统计值。也就是通过测量 TCP 的 request 和 response 所需的时间间隔，适用于一问一答式协议类型的处理。

这个东西没有办法用 yum 装, 只能通过源码编译, 从参考文章3处下载源码

```
[root@k8s-master-01 ~]# ls
tcprstat-0.3.1.tar.gz
[root@k8s-master-01 ~]# tar -zxf ./tcprstat-0.3.1.tar.gz
[root@k8s-master-01 ~]# ls
tcprstat-0.3.1  tcprstat-0.3.1.tar.gz
[root@k8s-master-01 ~]# cd tcprstat-0.3.1
[root@k8s-master-01 tcprstat-0.3.1]# ls
AUTHORS  bootstrap  ChangeLog  configure.ac  COPYING  libpcap  Makefile.am  NEWS  README  src  TODO
```

## 编译
