# Linux-nohup阻塞等待回车的问题

参考文章

1. [nohup 写脚本运行就一直阻塞着 如何解决](https://segmentfault.com/q/1010000010018238/)

nohup可以让目标命令脱离终端限制, 在后台保持运行, 如下

```
$ nohup ls &
[1] 12918
[root@172-16-4-100 ~]# nohup: ignoring input and appending output to ‘nohup.out’

[1]+  Done                    nohup ls
```

但是在执行`nohup`后需要输入一个回车才能完成, 如果写在脚本中, 就会卡住, 是个大问题.

参考文章1的高票回答解决了这个问题.

默认nohup需要等待一个键入来结束，按任意键都行，并非只是ctrl + c。

需要这样一个输入的原因就是没有指定nohup接收输出流的位置，也就是为什么提示显示将输出放置到了目录下的nohup.out里。

要让这个提醒消失也很简单，就是指定输出流向，例如：

```
$ nohup ls / >/dev/null 2>&1 &
```

完美. 