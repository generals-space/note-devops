参考文章

1. [虚拟机上安装centos8.0](https://www.cnblogs.com/fanzhenyong/p/11616192.html)

2. [Failed to restart network.service: Unit network.service not found 解决办法](https://blog.csdn.net/qq_40162735/article/details/101780012)

3. [基于RHEL8/CentOS8的网络IP配置详解](https://zhuanlan.zhihu.com/p/56892392)

4. [Centos8 配置静态IP](https://www.cnblogs.com/qianyuliang/p/11591970.html)

centos 8 官网没有 minimal 版本的镜像, 只能在安装的时候选择 minimal 方式安装.

主要是操作系统要选 red hat enterprise 8, 否则无法正确引导.

minimal安装完成后第一次启动发现无网络, 原因可能是在`/etc/sysconfig/netwok-scripts/`的网上配置文件中, `ONBOOT`属性设置为了no. 将其修改为yes后重启网络服务.

需要注意的是, centos8中没有了network服务, 只有NetworkManager, 用的是nmcli命令来管理网络.

引用参考文章2中所说

Network和NetworkManager区别 

Network：对网卡的配置,network的制御网络接口配置信息改动后, 网络服务必须重新新启动, 来激活网络新配置的使得配置生效, 这部分操作和从新启动系统时时一样的作用. 制御（控制）是/etc/init.d/network这个文件, 可以用这个文件后面加上下面的参数来操作网络服务

NetworkManager：是检测网络、自动连接网络的程序. 无论是无线还是有线连接, 它都可以令您轻松管理. 对于无线网络,网络管理器可以自动切换到最可靠的无线网络. 利用网络管理器的程序可以自由切换在线和离线模式. 网络管理器可以优先选择有线网络, 支持 VPN. 网络管理器最初由 Redhat 公司开发, 现在由 GNOME 管理

