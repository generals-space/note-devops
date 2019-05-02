# Linux开机进入字符界面/图形界面

<!key!>: {c2f8cf90-5387-11e9-ae66-aaaa0008a014}

<!link!>: {664fdd98-537c-11e9-b398-aaaa0008a014}

参考文章

1. [systemd详解](https://blog.linuxeye.com/400.html#comments)

2. [真的超赞！用systemd命令来管理linux系统！](https://linux.cn/article-3801-1.html)

## 1. CentOS7-

参考文件`/etc/inittab`关于Linux运行级别的解释(连rcS.conf与rc.conf的区别都只用两句话就讲清楚了). 对启动模式的修改只有最后一行.

```shell
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
#
id:5:initdefault:
```

编辑`id:数字:initdefault`中的数字即可.

重启, 生效.

## 2. CentOS7+/Fedora

参考文件`/etc/inittab`中的解释, CentOS7不再使用`inittab`控制启动流程, 取而代之的是`systemd`. 不再使用`runlevel` 而是`target`的概念.

在`/etc/systemd/system`下有名为`default.target`的软链接指向`/usr/lib/systemd/system`目录下的某个`target`文件作为运行模式(好多). 常用到的有两个:

- multi-user.target: 类似于 runlevel 3(字符界面)

- graphical.target: 类似于 runlevel 5(图形界面)

切换运行模式的命令为

```shell
systemctl set-default 目标target文件名
```

其实它是将`/etc/systemd/system`下名为`default.target`的软链接先删除, 再建立指向新的`target`的`default.target`. (所以在普通用户下可能要输入两次root密码).

重启, 生效.

> 注意: 使用centos dvd iso镜像安装的系统, 在安装步骤中要选择安装桌面环境, 否则设置图形界面是无效的.
