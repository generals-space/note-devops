# Ubuntu应用总结

## 1. 设置关闭开机启动的服务

系统版本: Ubuntu 14.04.1 LTS

在CentOS与Fedora下有chkconfig命令, 但Ubuntu下并没有这个工具.

百度甚至是谷歌中都是使用工具操作的教程, 但找到的几个工具如`sysv-rc-conf`, `rcconf`和Ubuntu自带的`update-rc.d`命令都无效, 配置中显示已经关闭, 但该启动的还是自启动, `sysv-rc-conf`甚至连我的服务都关不了. 不知道是不是版本问题, 暂时使用手动方式.

在目录`/etc/init.d`下有各种服务的启动脚本, 打开其中mysql的启动脚本可以看到前几行如下:

```
#!/bin/bash
#
### BEGIN INIT INFO
# Provides:          mysql
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Should-Start:      $network $time
# Should-Stop:       $network $time
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop the mysql database server daemon
# Description:       Controls the main MySQL database server daemon "mysqld"
#                    and its wrapper script "mysqld_safe".
### END INIT INFO
```

`Default-Start/Stop`应该就是配置自启动所在的运行级别(当前运行级别可以`runlevel`命令查看), 但是这处于被注释的状态. 尝试将`Default-Start`中的2去除, 加到`Default-Stop`中, 重启无效.

其实, Ubuntu的服务应该是在`/etc/init`目录下, 只是未免数量太多了些(我这里显示有107个), 可能是系统自带的也有许多, 感觉大多是无法用'service 服务名 start| stop'操作的那种.

```
# MySQL Service

description     "MySQL Server"
author          "Mario Limonciello <superm1@ubuntu.com>"

start on runlevel [2345]
stop on starting rc RUNLEVEL=[016]
```

修改`start on runlevel`和 `stop on starting rc RUNLEVEL`中的数值, 将2从前者中去除, 加到后者中, 重启, 生效.

PS: Ubuntu也太让人无语了吧.

...md, 直接写在`/etc/rc.local`文件中好了.

## 2. 静态IP

`/etc/network/interfaces`文件

```
# The primary network interface
auto eth0
iface eth0 inet static
address 172.32.100.50
netmask 255.255.255.0
gateway 172.32.100.2
dns-nameservers 172.32.100.2
```

关于这个文件的使用方式, 可以用`man 5 interfaces`查看.