# Mac下做持久ssh隧道

参考文章

1. [ssh无法登录,提示Pseudo-terminal will not be allocated because stdin is not a terminal.](https://www.cnblogs.com/wangcp-2014/p/6691445.html)

`~/.ssh/config`

```ini
Host forward-xcx
    HostName 122.51.137.99
    Port 22
    User general
    ServerAliveInterval 60
    ## 不开启tty, 与ssh的`-T`选项作用相同
    RequestTTY no
    RemoteForward 0.0.0.0:10001 127.0.0.1:22
```

`~/.ssh/autorestart.sh`

```bash
#!/bin/bash

is_exist=$(ps ux | grep forward-xcx | grep -v grep | wc -l)

if [ $is_exist -eq 0 ]; then
    echo 'try to restart...'
    ssh forward-xcx >> /tmp/forward.log 2>&1
fi
```

cronjob配置

```
* * * * * cd ~/.ssh; /bin/bash autorestart.sh
```

## 无法创建ssh进程的问题

在命令行执行`ssh forward-xcx`, 能够生成一个阻塞的进程, 同时在中转服务器上映射10006端口. 但是cronjob始终没有办法创建出`forward`进程, 连接始终都没有成功(在中转服务器上watch netstat的输出, 并不是连接的一瞬间断开, 而是直接没有成功).

在`autorestart.sh`脚本中打印一下日志.

```bash
    echo 'try to restart...' >> /tmp/forward.log
    ssh forward-xcx >> /tmp/forward.log 2>&1
```

结果有如下输出

```log
try to restart...
Pseudo-terminal will not be allocated because stdin is not a terminal.
```

查了查, 找到参考文章1, 得知可能需要添加`-tt`参数强制为ssh进程分配伪终端, 于是将`autorestart.sh`的ssh命令改成如下

```
ssh -tt forward-xcx
```

成功.
