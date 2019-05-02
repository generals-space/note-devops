# SSH(-o)选项参数

参考文章

1. [Linux之ssh连接保持与重用](http://www.ttlsa.com/linux/linux-ssh-connection-reuse/)

2. [通过 ControlMaster 对 OpenSSH 进行加速，减少系统资源消耗](https://www.ibm.com/developerworks/community/blogs/IBMzOS/entry/20150502?lang=en)

`-o`选项有很多特性可以选用, 其基本语法为

`ssh -o '选项 值' -o '选项 值' user@ip`

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

## 1. StrictHostKeyChecking - 是否检查目标主机公钥.

此选项默认值为yes.

在ssh连接目标服务器时, 如果在`~/.ssh/knows_hosts`文件中, 没有存储目标主机的公钥, ssh客户端会提示接受目标公钥. 

```
$ ssh root@192.168.166.220
The authenticity of host '192.168.166.220 (192.168.166.220)' can't be established.
RSA key fingerprint is 3c:67:0e:d5:1b:28:30:28:f4:62:15:e4:1d:ea:fb:76.
Are you sure you want to continue connecting (yes/no)? 
```

尤其是如果对方重装过系统, `known_hosts`文件存储的公钥与新公钥不一致时, 会报错而终止.

```
$ ssh  root@192.168.166.220
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that the RSA host key has just been changed.
The fingerprint for the RSA key sent by the remote host is
3c:67:0e:d5:1b:28:30:28:f4:62:15:e4:1d:ea:fb:76.
Please contact your system administrator.
Add correct host key in /app/jiale.huang/.ssh/known_hosts to get rid of this message.
Offending key in /app/jiale.huang/.ssh/known_hosts:1260
RSA host key for 192.168.166.220 has changed and you have requested strict checking.
Host key verification failed.
```

将StrictHostKeyChecking设置为`no`后就不会有这种情况.

```
$ ssh -o 'StrictHostKeyChecking no' root@192.168.166.220
Warning: Permanently added '192.168.166.220' (RSA) to the list of known hosts.
Last login: Sat Dec 30 20:39:42 2017 from 192.168.101.65
[root@220 ~]# 
```

> `StrictHostKeyChecking`选项不是不检查, 而是默认接受对方公钥. 但如果存储的公钥与目标公钥不一致时, 虽然也能正常登录, 但不会更新新的公钥(旧的公钥依然存在).

## 2. ControlMaster与ControlPersist - 连接复用, 无需重复输入密码.

参考文章

1. [使用ssh 的ControlMaster实现不用每次ssh都输入密码](https://www.jianshu.com/p/7e43fa159851)

`ControlMaster`模式, 可以复用之前已经建立的连接. 所以开启这个功能之后, 如果已经有一条到relay的链接, 那么再连接的时候, 就不需要再输入密码了. 

`ControlPersist` 参数的含义就是在最后一个连接关闭之后也不真正的关掉连接, 这样后面再连接的时候就还是不用输入密码. 

启用这两个功能, 就可以解决ssh登录时每次都需要重复输入密码的问题了. 

## 3. 保持连接

参考文章

1. [解决ssh登录后闲置时间过长而断开连接](https://www.cnblogs.com/wanghetao/p/3872919.html)

```
ServerAliveInterval 60
```