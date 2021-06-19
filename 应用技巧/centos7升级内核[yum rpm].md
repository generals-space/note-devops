# centos7升级内核[yum rpm]

参考文章

1. [教你三步在CentOS 7 中安装或升级最新的内核](https://www.linuxprobe.com/update-kernel-centos7.html)
    - `ELRepo`仓库可以升级内核到最新版本
    - 设置 GRUB 默认的内核版本
2. [CentOS 升级内核](https://www.cnblogs.com/xzkzzz/p/9627658.html)
    - rpm删除旧内核
3. [Centos7.0升级至指定内核版本](https://www.jianshu.com/p/7c167b3d1539)
4. [内核历史列表1](http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/)
5. [内核历史列表2](http://mirrors.reposnap.com/elrepo/20190305204216/kernel/el7/x86_64/RPMS/)

最近在做`ipvlan`的实验, centos7默认的内核版本为3.10, 但是ipvlan要求最低版本为3.19, 建议版本为4.2, 所以需要进行内核升级.

```
Linux k8s-worker-01 3.10.0-1062.4.1.el7.x86_64 #1 SMP Fri Oct 18 17:15:30 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

centos 可以通过 elrepo 在线升级内核, 但是这个仓库向来只保存当前的最新版本, 没有历史版本.

在网上找了很久, 才找到两个保留了历史版本的仓库, 直接yum安装就行.

```
yum install -y http://mirrors.reposnap.com/elrepo/20190305204216/kernel/el7/x86_64/RPMS/kernel-ml-4.20.13-1.el7.elrepo.x86_64.rpm
```

重启的时候可以选择内核.

```
Linux k8s-worker-01 4.20.13-1.el7.elrepo.x86_64 #1 SMP Wed Feb 27 10:02:05 EST 2019 x86_64 x86_64 x86_64 GNU/Linux
```
