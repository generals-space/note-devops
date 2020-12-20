# tcprstat编译安装

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

> `libpcap`目录是`libpcap`库的源码.

## 编译

这源码目录下没有`Makefile`, 也没有`configure`, 需要使用该目录下的`bootstrap`可执行文件先生成`configure`.

不过`boostrap`脚本使用了`aclocal`命令(在`automake`包中), 在`configure`过程中还需要`bison`(同名包), `yacc`(`byacc`包), `flex`(同名包), `patch`(同名包).

```
yum install -y automake bison byacc flex patch
bash ./bootstrap
./configure
make
```

`make`完成后就会在`src`目录下生成`tcprstat`, `tcprstat-static`两个文件. 后者可以看作类似于 golang 的编译结果, 单文件, 不依赖外部链接库.

## 基本使用

```
## 监听3306端口，每1秒输出一次，共输出5次
$ tcprstat -p 22 -t 1 -n 5
timestamp	count	max	min	avg	med	stddev	95_max	95_avg	95_std	99_max	99_avg	99_std
1608172431	0	0	0	0	0	0	0	0	0	0	0	0
1608172432	1	600	600	600	600	0	0	0	0	0	0	0
1608172433	3	1059	391	675	575	281	575	483	92	575	483	92
1608172434	0	0	0	0	0	0	0	0	0	0	0	0
1608172435	0	0	0	0	0	0	0	0	0	0	0	0
```

一旦通过 ssh 终端输入一些命令, 这个监听就会立刻显示出来.
