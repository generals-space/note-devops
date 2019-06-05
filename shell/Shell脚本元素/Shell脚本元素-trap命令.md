# Shell脚本元素-trap命令

原文链接

[关于Linux Shell的信号trap功能你必须知道的细节](https://blog.robotshell.org/2012/necessary-details-about-signal-trap-in-shell/)

参考文章

1. [Sending and Trapping Signals](http://mywiki.wooledge.org/SignalTrap)

信号处理(Signal Handling)在 Linux 编程中一直扮演者重要的角色, 几乎每个系统工具都要用到它, 最常见的功能莫过于用信号进行进程间通信(尤其是父子进程)以及捕捉SIGINT、SIGTERM之类的退出信号以做一些善后处理(cleanup). C中自不必多说, 可以使用 wait 族函数; 而 shell 脚本中也有捕捉信号的 trap 功能——然而许多人在使用 trap 功能的时候却存在着这样那样的误解, 这些看似无关紧要的小细节最后有可能使得你的脚本与你预想的行为完全不同. 

如无特殊说明, 下文所指 shell 均以 Bash 为例. 

## 0. trap 的使用简介

虽然我很想说这些应当要自己看man page , 但考虑到也许正在读文章的你手边没有 Linux , 还是简单说一下吧. 

```
USAGE: trap [action condition ...]
```

即当捕捉到 condition 列表所对应的**任何一个信号**时, 执行 action 动作(使用 eval action 来执行, 故 action 可以是 shell **内建指令**、**外部命令**及**脚本中的函数**等). action 还可是""(空)、'-'等, 分别代表忽略相应信号及重置相应信号为默认行为. 

## 1. condition 的标准格式是什么? 

condition 中的信号到底应该如何书写? 比如终端中断信号(一般用 CTRL-C 发出), 到底是写 `SIGINT` 、 `INT` 还是`2`(大部分系统上该信号对应的信号数)? 是大写还是小写? 

如果你使用最新版的 Bash , 那么这几种写法都可以. 而 **如果你需要在不同 shell 中保持可移植性, 请使用大写、不带前缀的`INT`**! 

根据 POSIX 标准,  `trap` 的 condition 不应当加上 SIG 前缀, 且必须全大写, 允许带 SIG 前缀或小写是某些 shell 的扩展功能. 而信号数在不同的系统上可能不同, 所以也不是一个好主意. 

## 2. trap 必须放在第一行么? 

许多资料, 尤其是中文资料中不容申辩地指明——**trap 必须放在脚本中第一个非注释行**. 事实果真如此么? 

不论是 man page 还是 POSIX 文档中, 我都没有找到任何与之相关的说明. 甚至在TLDP的 [Bash Guide for Beginners](http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html) 中, 多个例子都分明把 `trap` 放在了脚本的中间. 最后我在这篇文档中找到了下面这句经常被误读的话: 

> **Normally**, all traps are set before other executable code in the shell script is encountered, i.e., at the beginning of the shell script.

果然, 这只是一个为了保证信号钩子尽早被设立的一个设计惯例罢了. 事实上,  `trap` 可以根据你的需要放在脚本中的任何位置. 脚本中也可以有多个 trap , 可以为不同的信号定义不同的行为, 或是修改、删除已定义的 `trap` . 更进一步地,  `trap` 也有作用范围, **你可以把它放在函数中, 它将只在这个函数里起效! **你看, 其实 trap 的行为是很符合 UNIX 的惯例的. 

> trap处理的信号可以写多个(空格分隔)

## 3. 信号究竟是在什么时候被 trap 处理? 

这是本文最重要的一点. 信号到底是什么时候被处理的? 更准确地说, 比如脚本正在执行某个命令时收到了某个信号, 那么它会被立即处理, 还是要等待当前命令完成? 

我不打算直接说明答案. 为了让我们对这个问题有更透彻的理解, 让我们来做一下实验. 看下面这个时常被用来讲解`trap`的脚本: 

```
#!/bin/bash
trap 'echo "INTERRUPTED!"; exit' INT
sleep 100
```

大多数教程都是这么做的, 运行这个脚本, 按下 `CTRL-C` . 你看到了什么? 

脚本打出了"INTERRUPTED!"并停止了运行. 这看起来似乎很正常、很直觉——以此看来,  `trap` 会立即捕捉到信号并执行, 不管当前正在执行的命令. 许多脚本也正是在这个假设下写的. 

然而真的是这样么? 让我们做另一个实验——在一个终端执行这个脚本, 并打开另一个终端, 用`ps -ef |grep bash`找到这个脚本的进程号, 然后用`kill -SIGINT pid`向这个进程发送 `SIGINT` 信号. 你在原先的终端中看到了什么? 

没有任何反应! 如果你愿意等上100秒, 你最终会看到"INTERRUPTED!"被输出. 这样看来 `trap` 是等到当前命令结束以后再处理信号. 

这样的矛盾究竟是为什么? 问题其实出在 `CTRL-C` 身上. Bash 等终端的默认行为是这样的: 当按下 `CTRL-C` 之后, 它会向当前的整个进程组发出 `SIGINT` 信号. 而 sleep 是由当前脚本调用的, 是这个脚本的子进程, 默认是在同一个进程组的, 所以也会收到 SIGINT 并停止执行, 返回主进程以后 trap 捕捉到了信号. 

> 注: 第一种是`sleep`与其所在脚本都收到了`INT`信号, 第二种则是只有脚本本身收到了`INT`, 所以后者会让当前正在执行的命令执行完成再做出反应.

[这篇文档](http://mywiki.wooledge.org/SignalTrap)给了我们一个更准确的说明——**如果当前正有一个外部命令在前台执行, 那么 trap 会等待当前命令结束以后再处理信号队列中的信号**. (而许多教程出错的另一个原因就是——某些 shell 中 sleep 是内建命令, 会被打断. )

那么上文的例子应当要如何写才能达到想要的效果呢? 有两种方法: 

1. 把 `sleep` 放到后台进行, 再用内建的 `wait` 去等待其执行结束(详见上一段提到的那篇文档)；

2. 暴力一点, 把一长段 `sleep` 拆成一秒的小 `sleep` 的循环, 这在对精度要求不高的情况下也是一个可行的办法(这应该不用写范例了吧? ). 