# SSH隧道,端口转发与内网穿透(五) 端口映射失败时自动结束进程

参考文章

1. [Can I make SSH fail when a port forwarding fails?](https://superuser.com/questions/352268/can-i-make-ssh-fail-when-a-port-forwarding-fails)

场景描述

win10下配置ssh远程连接阿里云服务器做内网穿透, config文件如下

```
Host forward-ssh
    HostName note.generals.space
    Port 22
    User general
    ServerAliveInterval 60
    ## 不开启tty, 与ssh的`-T`选项作用相同
    RequestTTY no
    RemoteForward 0.0.0.0:2222 127.0.0.1:22
```

启动一个不开启交互式终端的会话, 会一直在前端阻塞, 所以还需要用powershell的`Start-Process ssh -ArgumentList 'forward-ssh' -WindowStyle Hidden`命令启动后台进程.

然后再创建定时任务检测ssh连接是否还存在, 不存在则重新创建连接.

然后, 问题来了...

有时无法通过公网服务器连接入内网win10, 因为此连接已经失效了, 但是公网服务器的端口也还在被占用. 而我写的脚本(运行在win10主机上)也无法检测到转发进程, 尝试重建. 这无疑仍会失败, 因为公网服务器的端口还在.

执行`ssh forward-ssh`会阻塞, 但映射又是失败的, 检测进程就查不到, 早晚死在进程过多.

于是优先考虑远程端口映射失败时让ssh进程自动结束, 查看`man ssh_config`找到了`ExitOnForwardFailure yes`选项, 但好像没用. 

google了一下, 找到了参考文章1. 原来`ExitOnForwardFailure`需要与`BindAddress`配合使用(原因在于, 如果不指定后者, ssh会尝试在所有接口上映射端口, 只要有成功的就不算出错). 于是config文件改成如下:

```
Host forward-ssh
    HostName note.generals.space
    Port 22
    User general
    ServerAliveInterval 60
    ## 不开启tty, 与ssh的`-T`选项作用相同
    RequestTTY no
    ExitOnForwardFailure yes
    BindAddress 0.0.0.0
    RemoteForward 0.0.0.0:2222 127.0.0.1:22
```

这样, 在转发服务器的端口被占用的情况下, 再次连接`forward-ssh`将会直接失败

```
$ ssh forward-ssh
Error: remote port forwarding failed for listen port 2222
```

...fuck, 有的时候加`BindAddress`正常, 有时候加就不正常, 我都不知道该怎么办了. 如果出现如下问题, 就把`BindAddress`去掉再试试吧.

```
$ ssh forward-ssh
ssh: connect to host note.generals.space port 22: Invalid argument
```
