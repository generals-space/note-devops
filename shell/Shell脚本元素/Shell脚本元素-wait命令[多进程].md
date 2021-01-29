# Shell脚本元素-wait命令

参考文章

1. [Linux Shell wait命令 多线程 kill超时进程](https://blog.csdn.net/qq_35260875/article/details/108643310)

`wait`是bash的内置命令, 作用是, **等待指定进程结束然后返回其退出状态码**. 这在shell脚本的多进程实现中颇为有用, 是许多高级语言(c, python等)都实现了的特性.

其语法如下:

```
$ wait 子进程pid
$ wait job序号
```

> 注意: 这是一个阻塞的方法. 

## 使用示例

示例

```console
$ ping -c 20 www.baidu.com > /tmp/ping_baidu &
[1] 6913
$ wait 6913 ; echo 'yes'

[1]+  Done                    ping -c 50 www.baidu.com > /tmp/ping_baidu
yes
```

上面的示例中`wait`的参数为pid, 下面的示例则是指定的job id.

```
$ ping -c 20 www.baidu.com > /tmp/ping_baidu &
[1] 6927
$ wait %1 ; echo 'yes'
[1]+  Done                    ping -c 20 www.baidu.com > /tmp/ping_baidu
yes
```

> 如果不指定参数, 则`wait`将等待所有后台进程执行完毕后才返回.

------

`wait`只能等待其所在终端的子进程的结束, 确切的说, 它只能等待自己的兄弟进程的结束. 即同一终端或是同一脚本内启动的后台进程. 否则会报如下错误.

```
general@ubuntu:/tmp$ wait 6815 ; echo 'yes'
-bash: wait: pid 6815 is not a child of this shell
```

## 得到子进程返回码

`wait 子进程pid`得到的返回码是子进程的返回码, 而不是`wait`命令本身的返回码.

```bash
#!/bin/bash

function subproc {
    sleep 3
    exit 123
}

subproc &
subpid=$!

wait $subpid
echo $?
```

打印的退出码是`123`, 为子进程的退出码.

但是这样做有一个问题, 那就是`wait`没有超时时间的选项, 导致只能等待`subproc`自然完成, 这可能要花很长时间, 对于主进程来说并不合理.

### `wait`+超时子进程

```bash
#!/bin/bash

## @function:   后台子进程
function subproc {
    echo 子进程开始
    sleep 5
    echo 子进程结束
    exit 0
}

## @function:   为目标后台子进程设置超时时间, 达到该时间后 kill 掉目标进程.
## $1:          目标子进程pid(必选)
## $2:          超时时间, 单位秒, 默认值为10(可选)
function watchdog {
    sleep ${2:-10}
    echo 目标超时
    kill $1
}

subproc &
subpid=$!

watchdog $subpid 3 &
watchpid=$!

## 如果发生超时, watchdog 将子进程移除后, 这里的 wait 会发生异常.
## wait 一个不存在的进程, 其退出码为 143 ???
wait $subpid > /dev/null 2>&1
subcode=$?

if (( subcode == 0 )); then
    echo 子进程正常结束
fi

## 如果发生超时, watchdog 内部 kill 完成后就结束了, 再次 kill 一个不存在的进程会发生错误.
kill $watchpid > /dev/null 2>&1

```
