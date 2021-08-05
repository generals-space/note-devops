# Linux修改网卡名称(网卡重命名)

参考文章

1. [Linux网卡重命名](http://blog.csdn.net/itjobtxq/article/details/40828917)

VMWare下配置虚拟机曾多次增删网卡, 结果网卡名称变成从`eth1`开始而不是从`eth0`开始. 有点强迫症, 最主要是写脚本进行批量操作会遇到诸多不便, 所以想改回来.

CentOS7-系统下, 修改`/etc/udev/rules.d/70-persistent-net.rules`文件, 将其中的`eth*`改成你想要的名字, 重启网络服务即可(有时要重启服务器).

不过有时自己修改过`/etc/sysconfig/network-scripts`下的网卡配置文件, 虽然上面的文件中没有了`eth2`, 但如果此目录下存在`ifcft-eth2`文件的话, `ifconfig`或`ip a`还是会出现eth2的. 
