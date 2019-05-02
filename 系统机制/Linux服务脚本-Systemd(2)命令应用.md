# Systemd-命令应用

## 1. 开启/关闭开机启动

参考文章

[CentOS7开机启动管理systemd简介及使用](http://www.linuxidc.com/Linux/2015-04/116648.htm)

[centos7服务管理组件systemctl的服务存贮目录和常用列表命令](http://blog.csdn.net/ownfire/article/details/50906499)

开机启动的操作是将指定服务(`.service`)软链接至指定运行级别(`.target.wants`)目录下.

查看一个服务是否为开机启动

```
$ systemctl is-enabled docker
static
```

`is-enabled`子命令返回值及其含义如下(这三种已经是比较常用的了, 更多返回值及含义可以查看`systemctl`的man手册):

- static: 目标服务未设置开机启动, 而且服务脚本(`.service`)中没有设置合法的`[Install]`块导致不能通过`enable`这样的手段完成设置.

- enable: 目标服务已设置为开机启动.

- disable: 目标服务未设置开机启动.

------

首先, 如果想要通过`systemctl enable|disable 服务名`开启或关闭服务的开机启动, 目标服务的`.service`脚本中需要配置`[Install]`块. 

```
[Install]
WantedBy=multi-user.target
```

然后, `enable`操作是建立`/usr/lib/systemd/system/服务名.service`到`/etc/systemd/system/multi-user.target.wants/服务名.service`的软链接, `disable`则是删除目标服务的软链接. **注意不是到`/usr/lib/systemd/system/multi-user.target.wants`.**(也许可以, 不过我实验中好像不行)

> 这个操作可以手动完成, 即使目标服务脚本文件中无`[Install]`块, 手动创建或删除软链接后也能完成开启/关闭软链接的工作, 并且之后使用`is-enabled`子命令也能得到`enabled|disabled`的结果.

### 查看所有开机启动以的服务

首先, 要说的是使用`list-unit-files`子命令可以查看所有由`systemd`管理的服务单元.

```
$ systemctl list-unit-files
arp-ethers.service                          disabled
atd.service                                 enabled 
auditd.service                              enabled 
auth-rpcgss-module.service                  static 
...
```

然后就可以使用`grep`过滤你想要查看的状态.