# Linux-sysctl内核参数-导论

参考文章

1. [linux内核参数注释与优化](http://blog.51cto.com/yangrong/1321594#comment)

<!tags!>: <!sysctl!> <!/proc!>

> sysctl: configure kernel parameters at runtime

sysctl是在系统运行时调整内核参数的工具, 它可以设置的各种值可以通过`sysctl -a`命令查看. 而这些值其实是`/proc/sys`中各个条目的映射, 它们一一对应.

比如

```
$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
$ cat /proc/sys/net/ipv4/ip_forward
1
```

直接修改`/proc/sys`的值相当于用`sysctl`修改. 可以猜测, sysctl是内核提供的一种'钩子'.

这些参数分为几个'领域': 网络, 文件系统, 内核, 用户, 虚拟内存等, 如下

```
$ pwd
/proc/sys
$ ls
abi  crypto  debug  dev  fs  kernel  net  user  vm
```

再细分, 只查看这些目录下的子目录, 不去管具体字段.

```
$ tree -d
.
├── abi
├── crypto
├── debug
├── dev
│   ├── hpet
│   ├── mac_hid
│   ├── raid
│   └── scsi
├── fs
│   ├── binfmt_misc
│   ├── epoll
│   ├── inotify
│   ├── mqueue
│   ├── quota
│   └── xfs
├── kernel
│   ├── keys
│   ├── pty
│   ├── random
│   ├── sched_domain
│   │   ├── cpu0
│   │   │   ├── domain0
│   │   │   └── domain1
│   │   ├── cpu1
│   │   │   ├── domain0
│   │   │   └── domain1
│   │   ├── cpu2
│   │   └── cpu3
│   ├── usermodehelper
│   └── yama
├── net
│   ├── bridge
│   ├── core
│   ├── dccp
│   │   └── default
│   ├── ipv4
│   │   ├── conf
│   │   │   ├── all
│   │   │   ├── default
│   │   │   ├── eth0
│   │   │   ├── eth1
│   │   │   └── lo
│   │   ├── neigh
│   │   │   ├── default
│   │   │   ├── eth0
│   │   │   ├── eth1
│   │   │   └── lo
│   │   └── route
│   ├── ipv6
│   │   ├── conf
│   │   │   ├── all
│   │   │   ├── default
│   │   │   ├── eth0
│   │   │   ├── eth1
│   │   │   └── lo
│   │   ├── icmp
│   │   ├── neigh
│   │   │   ├── default
│   │   │   ├── eth0
│   │   │   ├── eth1
│   │   │   └── lo
│   │   └── route
│   ├── netfilter
│   │   └── nf_log
│   ├── sctp
│   └── unix
├── user
└── vm

```

其中`abi`和`crypo`几乎没机会用到, 而`user`目录下的字段都十分简单且明了, 就是设置用户级命名空间的个数. 最复杂的应该是`net`模块, 这应该是由于TCP/IP协议本身的复杂性导致的. 网络上大部分内核参数调优也都是针对`net`模块而言的.