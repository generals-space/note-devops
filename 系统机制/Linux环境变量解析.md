# Linux环境变量详解

## 1. 生效时机

参考文章

[.bash_profile .bashrc profile 文件的作用的执行顺序](http://www.linuxidc.com/Linux/2013-01/78005.htm)

[Linux-profile、bashrc、bash_profile之间的区别和联系](http://www.cnblogs.com/JohnABC/p/4195164.html)

与环境变量有关的四个文件

- `/etc/profile`

- `/etc/bashrc`

- `~/.bash_profile`

- `~/.bashrc`

本篇文章实验比较多, 步骤有点复杂, 这里先说结论

| 执行方式              | profile | bashrc |                              示例                              |
| :-------------------- | :-----: | :----: | :------------------------------------------------------------: |
| 非交互式且非登录shell | 不加载  | 不加载 |                   `crontab`中执行的bash脚本                    |
| 非交互式登录shell     |  加载   |  加载  |                `crontab`中通过`su -l`执行的脚本                |
| 交互式非登录shell     | 不加载  |  加载  |              如命令行中通过`su 用户名`执行的命令               |
| 交互式登录shell       |  加载   |  加载  | 普通的终端登录, ssh远程登录, 以及使用`su - l 用户名`切换身份等 |


### 1.1 理论基础

首先认识一下登录shell与非登录shell, 交互式shell与非交互式shell.

#### 1.1.1 登录(login)与非登录(nologin)

普通的终端登录, ssh远程登录, 或者是`su -l 用户名`切换用户等, 包含的登录行为, 称打开的终端类型为**登录式shell**, 除了读取`profile`, 还会读取`bashrc`; 

与之相对的, 在打开的终端中执行`bash`命令得到新的shell会话, 还有使用`su 用户名`切换用户的操作创建的终端, 以及执行脚本时创建的bash进程, 都是**非登录式shell**.

~~需要注意的是, 从桌面发行版图形界面登录, 或是通过VNC登录行为, 都是**非登录形式**~~. 经过实验, 觉得这句话并正确, 点击登录按钮时, 桌面程序会加载`/etc/profile`文件, 见下面的实验.

#### 1.1.2 交互式与非交互式

**交互式模式**: 就是shell等待用户输入，并且执行用户键入的命令. 此时shell与用户进行交互, 输入输出与终端相连. 这种模式也是大多数用户非常熟悉的: 终端登录、执行一些命令、退出. 退出后, shell也随之终止.

**非交互式模式**: shell不与用户进行交互，而是读取存放在文件中的命令, 并且执行. 当它读到文件的结尾，shell也就终止了. 典型的例子就是`crontab`定时执行脚本, 它们的输入输出不会与任何bash进程相连接.

它们之间可以相互组合, 所以一共有4种情况.

### 1.2 实验验证

#### 1.2.1 验证登录式与非登录式shell

实验如下操作

```
[root@localhost ~]# echo 'usual_var=123456' >> /etc/profile
[root@localhost ~]# echo $usual_var

## 切换为普通用户, 非登录shell
[root@localhost ~]# su general
[general@localhost root]$ echo $usual_var

[general@localhost root]$ exit
exit
[root@localhost ~]# echo $usual_var

[root@localhost ~]# su -l general
Last login: Sun Dec 11 20:01:46 PST 2016 on pts/1
[general@localhost ~]$ echo $usual_var
123456
[general@localhost ~]$ exit
logout
[root@localhost ~]# echo $usual_var

```

可以看出`ssh`命令的`-l`选项的作用, 就是开启一个正常的登录shell会话. 同时也验证了, `profile`文件需要是登录shell才能加载的.

继续进行, 在当前终端执行`bash`命令, 会打开一个新的shell, 这也是一个非登录式shell.

```
[root@localhost ~]# echo 'usual_var=123456' >> /etc/profile
[root@localhost ~]# echo $usual_var

[root@localhost ~]# bash
[root@localhost ~]# echo $usual_var

```

可见, `bash`与`su`都没有重新加载`profile`文件.

将`usual_var`变量写入到`bashrc`文件, 再执行上述类似操作, 你会发现`bash`, `su`与`su -l`三种行为都会加载`bashrc`, 这里不再列出. 

> 注意bash命令加载的是当前用户的`~/.bashrc`,  而`su`操作加载的是目标用户的`~/.bashrc`.

#### 1.2.2 crontab的非交互式属性

我们都能理解, 通过`crontab`执行的脚本, 输入输出不与特定终端相连, 所以被称为**非交互式shell**. 下面我们验证一下, 使用`crontab`执行定时任务时, 任务脚本对两种文件的加载情况. 

在`/etc/profile`中添加环境变量`env_var`.

```
$ echo 'export env_var=abcdef' >> /etc/profile
```

建立实验用的任务脚本`nointeract.sh`

```
$ cat /tmp/nointeract.sh
#!/bin/bash
echo $env_var >> /tmp/var_result
```

建立`crontab`任务, 每10s执行1次.

```
$ crontab -e
* * * * * sleep 10; /bin/bash /tmp/nointeract.sh
* * * * * sleep 20; /bin/bash /tmp/nointeract.sh
* * * * * sleep 30; /bin/bash /tmp/nointeract.sh
* * * * * sleep 40; /bin/bash /tmp/nointeract.sh
* * * * * sleep 50; /bin/bash /tmp/nointeract.sh
```

...等待10s后, 查看`/tmp/var_result`文件, 是空的, 说明任务脚本没有读取到`/etc/profile`. 然后把`env_var`变量写到`bashrc`文件中, 10s后`var_result`依然文件的输出依然为空.

说明**非交互shell且非登录形式的bash进程不会加载`profile`也不会加载`bashrc`**.

------

先将上面写入到`bashrc`的`env_var`变量删除, 只保留`profile`, 然后修改`crontab`任务列表, 内容如下

```
* * * * * sleep 10; su -l root -c '/bin/bash /tmp/nointeract.sh'
* * * * * sleep 20; su -l root -c '/bin/bash /tmp/nointeract.sh'
* * * * * sleep 30; su -l root -c '/bin/bash /tmp/nointeract.sh'
* * * * * sleep 40; su -l root -c '/bin/bash /tmp/nointeract.sh'
* * * * * sleep 50; su -l root -c '/bin/bash /tmp/nointeract.sh'
```

然后, `/tmp/var_result`就有输出了, 的确是`profile`文件中定义的`env_var`的值.

保留`crontab`, 将`env_var`从`profile`文件中移除, 添加到`bashrc`中, 观察`/tmp/var_result`的输出, 也能得到`env_var`的值.

说明非交互式登录shell可以同时加载`profile`与`bashrc`文件.

#### 1.2.3 图形界面的非登录属性

为了验证这一点, 需要有两台主机, 分别以A和B指代, A是拥有图形界面的桌面发行版.

我们在主机A的`/etc/profile`文件写入以下内容. (主机A是Fedora 24的桌面发行版)

```
for i in {0..100};
do
    ping -c 1 主机B的IP地址
    sleep 1
done
```

重启主机A, 不做任何登录操作, 我们在主机抓取来自主机A的ICMP包`tcpdump -i eth0 src 主机A的IP and dst 主机B的IP`. 没有任何反应.

然后, 在主机A的图形界面登录, 将会得到100秒的黑屏, 在这期间, 主机B上可以抓取到来自A的ping包. 说明在这段时间主机A在加载`/etc/profile`的内容, 并且需要等到其执行完成才进行下一步操作.

还没完, 在主机A的图形界面黑屏期间, 我们尝试使用ssh连接到主机A, 刚完成登录, 终端界面就打印出ping操作的结果, 说明这个新创建的bash进程也尝试加载并执行了`/etc/profile`文件( 不同于图形界面完全阻塞的黑屏状态, 在ssh界面我们可以使用Ctrl+C取消此ping操作的执行), 这很正常.

在ssh登录的shell中执行查询

```
$ ps aux | grep bash
general    7056  0.0  0.0 119904     8 tty2     S+   22:37   0:00 -/bin/bash -c gnome-session
root      23738  0.0  0.1 120708  4376 pts/0    Ss   22:42   0:00 -bash
root      32895  0.0  0.0 117140  1032 pts/0    R+   22:51   0:00 grep --color=auto bash
```

也就是说, 图形界面其实也是由bash进程启动的. 但在未登录阶段, `/etc/profile`并未起作用.

等待图形界面黑屏结束, 在ssh终端中, 再次查找`bash`进程, 就只剩下自己了. 停留在图形界面时, 没有开启bash进程. 但是当打开"终端"程序时, 就会自动以当前用户建立**交互式登录shell**.

> `/etc/profile`与"开机启动"这种操作没有任何关系, 不要把开机启动项写在这里, 没用的.

## 2. 加载顺序

非交互式非登录shell比较好说, 哪一个都不加载...

交互式非登录shell也比较好说, 也就是`/etc/bashrc` -> `~/.bashrc`, 后者覆盖前者.

两种登录式shell两种文件都会加载, 一般是

`/etc/bashrc` -> `~/.bashrc`, 

`/etc/profile` -> `~/.bash_profile`. 

不过`/etc/bashrc` -> `~/.bash_profile`, 总是用户级配置优先级更高. 所以最终加载顺序可以看成是

`/etc/profile` -> `/etc/bashrc` -> `~/.bash_profile` -> `~/.bashrc`.
