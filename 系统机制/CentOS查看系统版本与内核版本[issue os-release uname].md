# CentOS查看系统版本与内核版本[issue os-release]

参考文章

1. [centos用什么命令可查版本号](https://www.php.cn/faq/489533.html)

```
[root@localhost ~]# cat /etc/issue
CentOS release 6.5 (Final)
Kernel \r on an \m
```

```
[root@localhost ~]# cat /etc/redhat-release
CentOS release 6.5 (Final)
```

```
[root@localhost ~]# cat /proc/version
Linux version 2.6.32-754.15.3.el6.x86_64 (mockbuild@x86-01.bsys.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-23) (GCC) ) #1 SMP Tue Jun 18 16:25:32 UTC 2019
```

```
[root@localhost ~]# uname -a
Linux localhost.localdomain 2.6.32-754.15.3.el6.x86_64 #1 SMP Tue Jun 18 16:25:32 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```
