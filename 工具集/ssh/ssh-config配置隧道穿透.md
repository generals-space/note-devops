# ssh-config配置隧道穿透

```
Host forward
    HostName 192.168.7.13
    Port 22
    User root
    ServerAliveInterval 60
    IgnoreUnknown RemoteForward
    RemoteForward 2222 localhost:22
```

上述是理论上的配置, 但我在Mac上如此配置并尝试连接时, 我得到了如下错误.

```
$ ssh forward
/Users/jiangming/.ssh/config: line 22: Bad configuration option: �\240
/Users/jiangming/.ssh/config: terminating, 1 bad configuration options
```

没办法, 只能写shell命令, 在当前目录的`ssh_tunnel_keepalive.sh`脚本, 是一个创建隧道并定时检测的小工具.
