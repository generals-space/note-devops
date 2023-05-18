`/proc/swap`: 其中的内容为`/etc/fstab`中类型为`swap`的部分(使用`swapoff -a`禁用所有swap分区后, 该文件也将被清空). 

`/proc/${pid}/comm`为当前进程的进程名, 但是没有参数.
`/proc/${pid}/cmdline`为当前进程的启动命令, 含参数.
`/proc/${pid}/status`可以查看当前进程的许多信息, 如进程名, 启动用户uid, 当前进程pid, 

```console
$ cat /proc/$$/status
Name:   bash
## 第一列是进程的启动用户, 最后一列是文件系统的用户, 中间的看不懂
Uid:    1000    1000    1000    1000
Gid:    100     100     100     100
```

