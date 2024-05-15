# shell 里的进程替换(Process Substitution)

参考文章

1. [/bin/sh source from stdin (from other program) not file](https://superuser.com/questions/272485/bin-sh-source-from-stdin-from-other-program-not-file)
2. [shell 里的进程替换(Process Substitution)](https://www.runoob.com/w3cnote/shell-process-substitution.html)

## 场景描述

docker容器中, 只有主进程1可以获取环境变量, 如果其他进程(或是通过ssh登录的终端)希望获取环境变量时, 只能通过`/proc/1/environ`文件.

```bash
$ cat /proc/1/environ |tr '\0' '\n'
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=k8s-master-01
KUBE_DNS_PORT_9153_TCP_PROTO=tcp
...
```

xargs+export是不行的.

```log
$ cat /proc/1/environ |tr '\0' '\n' | xargs export
xargs: export: No such file or directory
```

只能是将`cat`的结果写入文件, 然后用`source`加载(之后可以把文件删除).

但是参考文章1中提到一种行内读取的方法.

```bash
source <(cat /proc/1/environ |tr '\0' '\n')
```

## 原理

简单来说, 就是`<(command)`这个操作符, 可以将括号内的命令`command`执行完毕后, 将输出写入到`/dev/fd/...`下的一个临时文件, 这样`source`就可以像加载文件一样加载ta了.

`(command)`可以理解为在一个子进程中执行的命令, 而`<()`, `>()`则是一种特殊的使用方法, 参考文章2给出了2个易懂的示例.

1. `cat <(ls)`: 把`<(ls)`当一个临时文件, 文件内容是`ls`的结果, `cat`这个临时文件

2. `ls > >(cat)`: 把`>(cat)`当成临时文件, `ls`的结果重定向到这个文件, 最后这个文件被`cat`
