# Centos7开机rc.local 不执行的问题

原文链接

[解决centos7 开机/etc/rc.local 不执行的问题](http://www.jb51.net/article/108874.htm)

最近发现centos7 的/etc/rc.local不会开机执行, 于是认真看了下/etc/rc.local文件内容的就发现了问题的原因了

```bash
#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In constrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.
```

翻译：

```bash
#这个文件是为了兼容性的问题而添加的.
#
#强烈建议创建自己的systemd服务或udev规则来在开机时运行脚本而不是使用这个文件.
#
#与以前的版本引导时的并行执行相比较, 这个脚本将不会在其他所有的服务后执行.
#
#请记住, 你必须执行“chmod +x /etc/rc.d/rc.local”来确保确保这个脚本在引导时执行.
```

于是我有确认了下`/etc/rc.local`的权限

```
[root@localhost ~]# ll /etc/rc.local
lrwxrwxrwx. 1 root root 13 8月 12 06:09 /etc/rc.local -> rc.d/rc.local
[root@localhost ~]# ll /etc/rc.d/rc.local
-rw-r--r--. 1 root root 477 6月 10 13:35 /etc/rc.d/rc.local
```

`/etc/rc.d/rc.local`没有执行权限, 于是按说明的内容执行

`chmod +x /etc/rc.d/rc.local`

重启后发现`/etc/rc.local`能够执行了.

看样子是版本的变迁, `/etc/rc.local`, `/etc/rc.d/rc.local`正在弃用的路上.

------

没错, CentOS6的rc.local默认是有执行权限的, 而CentOS7的没有, 需要手动添加.