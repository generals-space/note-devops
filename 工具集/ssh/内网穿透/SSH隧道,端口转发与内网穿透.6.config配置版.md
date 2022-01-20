# SSH隧道,端口转发与内网穿透.6.config配置版

```
Host forward
    HostName 192.168.7.13
    Port 22
    User root
    ServerAliveInterval 60
    IgnoreUnknown RemoteForward
    RemoteForward 0.0.0.0:2222 127.0.0.1:22
```

上述是理论上的配置, 但我在Mac上如此配置并尝试连接时, 我得到了如下错误.

```
$ ssh forward
/Users/jiangming/.ssh/config: line 22: Bad configuration option: �\240
/Users/jiangming/.ssh/config: terminating, 1 bad configuration options
```

网上有说加上`IgnoreUnknown`字段, 但还是没用.

没办法, 只能写shell命令, 在当前目录的`ssh_tunnel_keepalive.sh`脚本, 是一个创建隧道并定时检测的小工具.

更新(20191114)

wtf!!!

`RemoteForward`前是tab键才会出错! 换成空格就可以了...

```
Host forward
    HostName 192.168.7.13
    Port 22
    User root
    ServerAliveInterval 60
    ## 不开启tty, 与ssh的`-T`选项作用相同
    ## 如果开启, ssh forward的时候会进入到服务端主机的bash命令行,
    ## 不开启则只是单纯的阻塞.
    RequestTTY no
    RemoteForward 0.0.0.0:2222 127.0.0.1:22
```

> 这种形式定义的主机别名也可以通过ssh远程执行命令, 如`ssh forward 'ls'`可以得到输出结果.

------

最终版记录

```
Host forward-ssh
    HostName 192.168.7.13
    Port 22
    User root
    ServerAliveInterval 60
    ## 不开启tty, 与ssh的`-T`选项作用相同
    ## 如果开启, ssh forward的时候会进入到服务端主机的bash命令行,
    ## 不开启则只是单纯的阻塞.
    RequestTTY no
    ExitOnForwardFailure yes
    BindAddress 0.0.0.0
    RemoteForward 0.0.0.0:2222 127.0.0.1:22
    ServerAliveInterval 10
    ServerAliveCountMax 6
```
