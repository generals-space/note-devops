`iptables-save`这个命令会把当前生效的过滤规则以文本的方式输出出来, 可以输出到`/etc/sysconfig/iptables`文件中, 然后直接重启iptables服务就可以永久生效了.

`iptables`服务没有进程, 这一点与CentOS7中的firewalld不一样. 在`iptables`服务未启动甚至根本就没装`iptables`服务的时候, 就可以使用`iptables`命令直接定义防火墙规则了, 并且是即时生效的.

```
$ ps -ef | grep -i iptable
root      7000  6719  0 02:05 pts/0    00:00:00 grep -i iptable
```

在iptables服务停止时, 它会做如下事情(CentOS7下的iptables也一样).

```
$ service iptables stop
Flushing firewall rules:                                   [  OK  ]
Setting chains to policy ACCEPT: filter                    [  OK  ]
Unloading iptables modules:                                [  OK  ]
```

我们可以把`stop`操作当作普通的iptables命令执行过程, 所以它可以多次执行...没错, 可以多次stop, 因为它就只是清理所有的规则而已, 不管是临时的还是写在配置文件里的, 都会清理掉.

所以, 它也是可以多次启动的, 它启动的操作, 就是加载配置文件中的规则...

> 突然发现`iptables`好奇葩...

我们知道, iptables的服务在启动时会加载配置文件(`/etc/sysconfig/iptables`)中的默认配置. 这一点firewalld倒是一样, 不过它的配置文件与iptables的配置文件不一样, 所以它们两个启动时...会相互覆盖.

[iptables 中的 return](http://bbs.csdn.net/topics/340237926)

1. 从一个CHAIN里可以jump到另一个CHAIN, jump到的那个CHAIN是子CHAIN.

2. 从子CHAIN return后，回到触发jump的那条规则，从那条规则的下一条继续匹配.

3. 如果return不是在子CHAIN里，而是在main CHAIN，那么就以默认规则进行.