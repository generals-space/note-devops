# Linux资源限制策略(一)

<!tags!>: <!linux应用技巧!>

## 1. limit

Linux对普通用户能够获取的资源进行了诸多限制, 比如能够启动的进程的最大进程数, 能够打开的最大文件数等, 使用`ulimit -a`可以看到这些配置项. 用户与用户间的限制可以不同, 要看指定用户的详细配置, 需要切换到这个用户下执行`ulimit`命令.

```
[root@localhost ~]# ulimit -a
core file size          (blocks, -c) 0                      ## 程序能够产生的内存转储文件大小(一般只有进程意外崩溃时才会产生)
data seg size           (kbytes, -d) unlimited              ## 进程数据段大小(貌似是限制代码中的局部变量<???>, 结构体变量太多会不会被限制...)
scheduling priority             (-e) 0                      ## 调度优先级
file size               (blocks, -f) unlimited              ## 用户能拥有的文件大小不能超过这个值
pending signals                 (-i) 15209                  ## <???>
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited              ## 内存的最大使用量
open files                      (-n) 1024                   ## 能够打开的最大文件数
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 10240
cpu time               (seconds, -t) unlimited
max user processes              (-u) 15209                  ## 用户能够启动的最大进程数, 可以防止`fork bombs`(fork炸弹)
virtual memory          (kbytes, -v) unlimited 
file locks                      (-x) unlimited 
```

在终端使用`ulimit -n 10240`可以将当前用户的打开文件数最大值设置为10240. 同理, 其他的选项也可以通过这种方法设置. 关键字`unlimited`表示无限制.

> 这种方式只能在当前shell会话中生效, 无法持久. 如果希望在当前系统中全局有效, 需要在`/etc/security/limit.conf`中配置.

> 只有root有权限执行这个命令, 但只能修改root本身的限制, 要修改普通用户的, 同样需要在`/etc/security/limit.conf`中配置.

## 2. limit配置文件

`/etc/security/limit.conf`中有上述`ulimit`可以设置的选项, 格式如下

```
<domain>        <type>  <item>  <value>
```

- domain: 一般是用户名或组名, 表示对这些用户/用户组的限制规则

- type: 一般取`soft|hard`, hard类型的value值一般大于等于同选项的soft类型的值, 超过soft设置的值后系统会发出警告(应该是在/var/log/message文件中), 但是仍然可以继续运行进程,  如果超过hard设置的值...呃, 好吧, hard设置的上限绝对不可能超过.

- item: 被限制的选项, 如: `core`(核心转储文件), `nproc`(用户最大进程数), `nofile`(最大打开文件数)等, 详细列表与介绍见`/etc/security/limit.conf`.

- value: 被限制的选项的值, 一般是数字, 表示具体的值, 也可以是`unlimited`, 表示无限制.

示例:

```
log          soft    nproc     1024
log          hard    nproc     10240
root       soft    nproc     unlimited
```

上述规则表示, 当log用户的进程数超过`1024`(soft类型的上限), 系统会发出警告, 但是还可以继续启动新的进程. 但用户进程数到了10240, 再启动新的进程会失败. root用户的soft类型都设置为了`unlimited`, 它可以启动无限的进程(系统资源足够的话).

修改后立即生效, 不需要重启.

> 注意: 系统可能对`hard`的标准有默认限制, 自定义的设置如果单纯设置`soft`值将会无法越过默认值限制, 所以如果有需要, 可以同时设置`hard`标准.

> **警告:** 对root所做的`hard`类型修改可能导致严重的结果, 但好在只有在新终端生效, 所以保持编辑终端不要退出, 有问题可以及时撤销.