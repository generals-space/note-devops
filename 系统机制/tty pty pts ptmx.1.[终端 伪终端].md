参考文章

1. [Linux中的tty、pty、pts与ptmx辨析](https://blog.csdn.net/zhoucheng05_13/article/details/86510469)
2. [yifengyou/linux-0.12](https://github.com/yifengyou/linux-0.12/blob/master/docs/%E7%AC%AC7%E7%AB%A0-%E5%88%9D%E5%A7%8B%E5%8C%96%E7%A8%8B%E5%BA%8F/%E7%AC%AC7%E7%AB%A0-%E5%88%9D%E5%A7%8B%E5%8C%96%E7%A8%8B%E5%BA%8F.md)
    - 《Linux内核完全剖析》第7章
    - "伪终端"与"虚拟终端"应该是同一概念
3. [Linux：减少tty数量](https://blog.51cto.com/yjh625/698475)
    - `/etc/inittab`

环境: CentOS 7

## 0. tty(终端设备的**统称**)

> `tty`一词源于`teletypes`, 或者`teletypewriters`, 原来指的是电传打字机, 是通过串行线用打印机键盘通过阅读和发送信息的东西. 
> 
> 后来这东西被键盘与显示器取代, 所以现在叫**终端**比较合适. 终端是一种字符型设备, 它有多种类型, 通常使用tty来简称**各种类型**的终端设备.

ta原本长这个样子.

![](https://gitee.com/generals-space/gitimg/raw/master/4562c38fd7fbe15d5a3cd87dfdc84d9b.png)

现在`tty`是一个统称, 实际上ta包含如下种类:

1. 控制终端(/dev/tty)
2. 控制台终端(/dev/ttyn(其中`n`为数字), /dev/console)
3. 伪终端(/dev/pty/)
4. 虚拟终端(/dev/pts/n(其中`n`为数字))
5. 串口端口终端(/dev/ttySn(其中`n`为数字))

## 串口端口终端

ttyS: tty serial

/dev/ttySn是串行终端设备, 这些设备文件会映射到物理串行端口, 如果我们执行下列命令

```
echo 2 > /dev/ttyS2
```

那么在对应的物理端口, 如COM2上可以检测到输出.

由于串口设备基本只在嵌入式编程中使用, 高级语言编程中很难见到, 所以本文不再详细研究.

## 控制终端

控制终端: Controlling Terminal

控制终端`/dev/tty`的行为表现与控制台终端`/dev/console`一致, 具体可见下一节的解释.

控制终端更像是一个逻辑概念, 用户在哪个终端上进行交互, 哪个就是控制终端, 由于linux允许同一个用户多地登录, 所以这个概念很"唯心".

> 为什么参考文章2中要把`/dev/console`归为控制台终端, 和`/dev/ttyn`放在一起呢? 和`/dev/tty`一起归为控制终端不好吗???

## 控制台终端

### `Alt+F1..F7`

控制台终端, 就是通过显示器接口直接显示的交互式终端, 区别与通过`sshd`, `telnet`等外部程序接入的伪终端, ta包括`/dev/ttyn`, `/dev/console`.

linux默认提供了6个字符界面终端+1个图形桌面, 可以通过`Alt+F1..F7`进行切换, 其中`Alt+F7`为图形界面. 

系统开机后, 默认进入第1个字符终端`Alt+F1`(可配置).

登录后, 通过`ps -ef | grep tty`, 以及`who`命令可以查看tty控制台终端对应的登录情况.

![](https://gitee.com/generals-space/gitimg/raw/master/603631105eddbc3f75a56e1dfb533b04.png)

此时在终端界面中执行`Alt+F2`, 切换至第2个tty终端, 将会显示未登录状态的空闲终端.

![](https://gitee.com/generals-space/gitimg/raw/master/220877e4d79b409b8a02e65850bc3026.png)

再次登录, 并查看终端占用信息, 如下

![](https://gitee.com/generals-space/gitimg/raw/master/3152cead7d954f889711025493447205.png)

从`Last login`提示信息, 可以知道上一次登录的终端在`tty1`, 从`w`命令的输出信息, 可以知道当前的终端为`tty2`.

除了`w`命令, 还有`tty`命令可以查看当前所处的终端编号.

![](https://gitee.com/generals-space/gitimg/raw/master/9607713fa0819e56960602d44707da06.png)

`Alt+Fn`切换终端, 可以看到执行`tty`命令的不同输出.

------

由于这台虚拟机没有装图形桌面系统, 所以`Alt+F7`没有反应, 安装之后是可以的. 

另外, linux默认提供了6个字符界面的控制终端, 平常也不太常用, 可以适当减少这个数值, 具体操作方法见参考文章3.

### `/dev/ttyn`

假设当前处于`tty1`, 那么`echo hello > /dev/tty1`, 将在当前终端直接打印出内容.

![](https://gitee.com/generals-space/gitimg/raw/master/9266eda138032067c7dff699abbebb62.png)

但是`echo hello > /dev/tty2`则没有输出, 因为字符串被打印在了`tty2`终端, 此时`Alt+F2`切换至`tty2`有如下输出.

![](https://gitee.com/generals-space/gitimg/raw/master/aa659cd3dba551e4d5203f04d2ef179e.png)

参考文章2中把"控制台终端"和"虚拟终端"划分为了两类, 但又将"虚拟终端(tty1-tty6)"归到了"控制台终端"小节...

### `/dev/console`

上一节我们了解了`/dev/ttyn`文件与各控制终端界面的关系, 那么`/dev/console`又是什么?

可以说, `/dev/console`就是指向当前`tty`的一个指针, 无论当前为于哪个`tty`终端, ta都指向当前的`/dev/ttyn`文件.

```
            +--------------+
            | /dev/console |
            +-------┬------+
                    |
      ┌─────────────┘
+-----↓-----+ +-----------+    +-----------+
| /dev/tty1 | | /dev/tty1 | .. | /dev/ttyn |
+-----------+ +-----------+    +-----------+
```

在任意tty终端, 执行`echo hello > /dev/console`, 都只会当前终端直接打印, 且**不会影响其他tty终端**.

![](https://gitee.com/generals-space/gitimg/raw/master/ac2988e79dd4c3421aaf4464a1b2d399.png)

> `/dev/tty`, `/dev/tty0`与`/dev/console`的行为表现相同, 但ta们之间并不存在软/硬链接关系, inode编号也不相同.

## pty-伪终端

pty: pseudo-tty(伪终端)

伪终端设备用于远程连接(如ssh), ta们与实际物理设备并不直接相关, 而是是**成对存在的逻辑设备**.

> "串口端口终端"与串口接口相关, "控制台终端"与显示器接口相关, 都算是与物理设备有关的.

`pty`由master和slave两端构成, 在任何一端的输入都会传达到另一端. 与tty不同, 系统中并不存在pty这种文件, ta是由pts(pseudo-terminal slave)和ptmx(pseudo-teiminal master)两种设备文件来实现的. 

`master`与`slave`的使用方式很像管道, 两端的程序向管道对象中进行读写操作即可, 但还是稍微有所差别. 

确切的说, `slave`端才是管道, 连接着用户终端, 而`master`端则像是连接着内核层.

## pts

我们通过`ssh`登录上面的主机, 使用`ps -ef | grep tty`, `w`命令和`tty`命令查看.

![](https://gitee.com/generals-space/gitimg/raw/master/0eedf856cce1d40d479593997e939d40.png)

可以看到, 这次的终端类型区别于上面的控制终端, 显示为了`/dev/pts/0`.

另开一个`ssh`会话, `/dev/pts/`目录下会再增加一个`1`, 按顺序递增.

![](https://gitee.com/generals-space/gitimg/raw/master/0f0b658f2729e3b33a71831cf2491365.png)

同样, 向`/dev/pts/0`和`/dev/pts/1`写入数据, 会是什么场景?

![](https://gitee.com/generals-space/gitimg/raw/master/d4c3d77d04536e516d306c66e4822d7e.png)

向`/dev/pts/n`写入数据, 会直接打印到相应的伪终端上(向`/dev/ttyn`写入也是一样的).

------

若是此时没有第3个ssh会话, 却向`/dev/pts/2`写入数据会发生什么?

```log
$ echo hello > /dev/pts/2
-bash: /dev/pts/2: 权限不够
```

------

如果打开0, 1, 2共3个伪终端, 然后退出`pts1`, 再建立连接时, 打开的伪终端编号会是`pts1`还是`pts4`?

答案是`pts1`, 伪终端会寻找最小最合适的终端编号.

## ptmx

关于`ptmx`, 在`/dev`下仅有2个`ptmx`文件, 如下

![](https://gitee.com/generals-space/gitimg/raw/master/e9253fd4c2e2d920e5e607910ab6a06b.png)

从中可以看出任何用户都可对`/dev/ptmx`进行读写, 而任何用户对`/dev/pts/ptmx`都没有读写权限.

那ta是怎么使用的呢?

参考文章1和2其实都没有特别清晰地给出答案, 这里记录一下自己的理解.

按照参考文章2中的实验, ssh接入终端后执行如下命令.

![](https://gitee.com/generals-space/gitimg/raw/master/46d62ceb2674b4de95fc3e98ab7624e0.png)

可以看到, 在打开`/dev/ptmx`文件的瞬间, `/dev/pts`目录下新增了一个pts slave端.

我觉得像 ssh server 这样的服务, 应该是每当一个客户端建立ssh会话, 都会 open `/dev/pts`文件, 同时由内核分配给该客户端一个 pts 设备.

通过`lsof`命令, 查看ssh会话的打开文件列表, 证实了我的猜测.

![](https://gitee.com/generals-space/gitimg/raw/master/6501e2de342c64d2fee5ce8c6de29406.png)

> 注意: `lsof`的目标是ssh的会话进程, 而非sshd服务进程.

数据流路线如下

```
bash -> 打开/dev/ptmx时得到的fd             -> 
                                                kernel
bash <- /dev/pts/0(打开ptmx时分配的伪终端)  <-
```
