# CentOS 7 系统网卡命名规则

原文链接

[CentOS 7 系统网卡命名规则](http://blog.csdn.net/example440982/article/details/53107063)

参考文章

1. [linux--centos7更改网卡名称eth0](http://blog.csdn.net/cmqwan/article/details/61250037)

2. [Linux启动网卡时出现RTNETLINK answers: File exists错误解决方法](https://www.linuxidc.com/Linux/2014-01/95253.htm)

网络设备传统的命名是`eth[0123…]`格式

Centos7提供了不同的命名规则，默认是基于固件、拓扑、位置信息来分配。这样做的优点是命名是全自动的、可预知的，缺点是比`eth0`、`wlan0`更难读。比如`enp5s0`

## 1. 命名规则策略

默认的，`systemd`将根据下面的策略来命名接口，应用到支持的命名规则。

1. 对于板载设备命名合并固件或BIOS提供的索引号，如果来自固件或BIOS的信息可读就命名，比如 eno1，这种命名是比较常见的，否则使用规则2。

2. 命名合并固件或BIOS提供的PCI-E热插拔口索引号，比如ens1，如果信息可读就使用，否则使用规则3。

3. 命名合并硬件接口的物理位置，比如 enp2s0，可用就命名，失败直接到方案5。

4. 命名合并接口的MAC地址，比如 enx78e7d1ea46da， 默认不使用，除非用户选择使用此方案。

5. 使用传统的方案，如果所有的方案都失败，eth0。

## 2. 前两个字符的含义

en: 以太网 Ethernet

wl: 无线局域网 WLAN

ww: 无线广域网 WWAN

## 3. 第三个字符根据设备类型选择

## 4. 恢复使用传统的命名方式

如果不习惯使用新的命名规则，可以恢复使用传统的方式命名，编辑`grub`文件，增加两个配置，再使用`grub2-mkconfig`重新生成配置文件即可

```
$ ll /etc/sysconfig/grub
lrwxrwxrwx. 1 root root 17 Mar  6 00:21 /etc/sysconfig/grub -> /etc/default/grub
$ vim /etc/sysconfig/grub
```

在`GRUB_CMDLINE_LINUX`字段中增加两条配置: `net.ifnames=0`和`biosdevname=0`, 按空格分隔. 

然后执行如下语句

```
$ grub2-mkconfig -o /boot/grub2/grub.cfg
```

它会将`/etc/default/grub`中的变量写入到`/boot/grub2/grub.cfg`文件中, 后者才是grub2实际的配置文件.

~~重启系统生效.~~

很多人说这样重启就能生效, 但实际上`ip a`和`ifconfig`的结果依然是`enoxxxxxxx`的形式, 接下来要修改网卡本身的配置文件`ifcfg-enoxxxxxx` -> `ifcfg-eth0`什么的. 注意配置文件中的`NAME`和`DEVICE`字段也要做相应修改.

完成后暂时不要重启网络服务, 因为还有一个地方要改(不改这个地方网络服务没法启动), 就在`/etc/udev/rules.d`目录下, 文件名不确定, 查看一下内容基本也就知道是哪个文件了.

```
# This file was automatically generated on systemd update
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:bf:61:26", NAME="eno16780032"
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:bf:63:86", NAME="eno33559296"
```

把`enoxxxxxxx`也改成`eth0`这种, 就可以了.

...貌似重启网络无法生效, 只能重启系统???