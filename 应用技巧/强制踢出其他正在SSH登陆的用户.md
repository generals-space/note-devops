# 强制踢出其他正在SSH登陆的用户

## 1. 踢人前提

首先, linux系统下root用户可强制踢出其它登录用户, 如果同时有两个root在终端登录, 其中任何一个都可以踢掉另一个;

然后, 任何普通用户都可以踢掉自己, 如果同一个普通帐户在多个终端登录时, 可以互相踢. 但是, 被踢的用户不能用`su`转成其他用户, 否则需要root权限才能踢除. 比如两个用户使用同一个普通帐户`A`登录不同终端, 其中第1个人使用`su`转成了帐户B, 第2个人将无法将其踢除, 除非他有root权限.

最后, 如果要踢掉使用`tty`方式登录的用户(包括普通用户)必须要root权限(ubuntu下是如此, 还没有在其他地方测试过), tty方式登录说明该用户有能力接近服务器本机而不是通过远程ssh登录, 可能这样权限的确大些.

## 2. 实施方法

1 . 首先可用`w`命令查看登录用户信息, `who`命令也可以, 不过信息不如`w`的输出丰富.

```
general@ubuntu:~$ w
 05:54:18 up 13 min,  5 users,  load average: 0.00, 0.17, 0.18
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
general  tty1                      05:50    4:10   0.10s  0.09s -bash
general  :0       :0               05:46   ?xdm?  29.35s  0.17s init --user
general  pts/7    :0               05:46    6:50   0.09s  0.09s bash
general  pts/1    192.168.138.1    05:48    6:10   0.07s  0.07s -bash
general  pts/24   192.168.138.1    05:54    2.00s  0.10s  0.00s w
```

其中, `tty1`是使用`Ctrl+Alt+F1`登录的, `pts/7, 1, 24`是通过ssh或ubuntu提供的伪终端登录的.

2 . 可以用`who am i`命令查看此时自己属于哪个终端(小心别踢错了).

```
general@ubuntu:~$ who am i
general  pts/24       2016-02-28 05:54 (192.168.138.1)
```

3 . 踢人的命令格式为`pkill -kill -t 终端名`或是`pkill -9 -t 终端名`

```
general@ubuntu:~$ pkill -kill -t pts/1
general@ubuntu:~$ w
 06:26:29 up 46 min,  4 users,  load average: 0.00, 0.04, 0.13
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
general  tty1                      05:50   36:21   0.10s  0.09s -bash
general  :0       :0               05:46   ?xdm?  41.26s  0.19s init --user
general  pts/7    :0               05:46   39:01   0.09s  0.09s bash
general  pts/24   192.168.138.1    05:54    5.00s  0.12s  0.01s w
```
