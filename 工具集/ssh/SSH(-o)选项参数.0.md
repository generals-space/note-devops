# SSH(-o)选项参数

参考文章

1. [Linux之ssh连接保持与重用](http://www.ttlsa.com/linux/linux-ssh-connection-reuse/)
2. [通过 ControlMaster 对 OpenSSH 进行加速，减少系统资源消耗](https://www.ibm.com/developerworks/community/blogs/IBMzOS/entry/20150502?lang=en)

`-o`选项有很多特性可以选用, 其基本语法为`ssh -o '选项 值' -o '选项 值' user@ip`

可以通过指定多个`-o`选项设置多个特性, 更多可用选项可以用`man`查看.

注意: 这些特性只是针对ssh客户端的, 与sshd的配置并没有关联.

这些选项中的参数都可以写在`~/.ssh/config`配置文件中, 格式类似为

```
## Host只是登录别名
Host *
    StrictHostKeyChecking no
    ControlMaster auto
    ControlPersist yes
```

> 注意: 这一操作是写`/etc/ssh/ssh_config`而不是`/etc/ssh/sshd_config`文件.
