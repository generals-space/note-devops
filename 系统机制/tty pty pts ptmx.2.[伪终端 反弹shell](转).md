# tty pty pts ptmx.2.[伪终端 反弹shell](转)

原文链接: [Linux 的伪终端的基本原理 及其在远程登录（SSH，telnet等）中的应用](https://www.cnblogs.com/zzdyyy/p/7538077.html)

本文介绍了linux中伪终端的创建，介绍了终端的回显、行缓存、控制字符等特性，并在此基础上解释和模拟了telnet、SSH开启远程会话的过程。

## 一、轻量级远程登录

之前制作的一块嵌入式板子，安装了嵌入式linux操作系统，可以通过串口（Console）登录。为了方便使用，需要寻找通过网线远程登录的方法。最初的想法是SSH，不过板子的ROM太小，存不了体积庞大庞大的OpenSSH套装。后来换用了telnet，直接拿busybox的telnetd做服务器，效果很好。

后来有一天，发现了Linux中有一个直接建立TCP连接的工具：nc 。在服务端使用nc -l 端口号 来进行监听，在客户端使用nc IP地址 端口号来建立连接。建立连接后，nc会把从stdin读入的字节流发送给另一方，把接收到的字节流写入stdout中。配合方便的管道操作，不正可以将shell的输入/输出传送到远端机器上吗？于是在Ubuntu中实验操作如下（之后发现这种操作叫做“反弹shell”）：

打开一个终端A，输入命令

```bash
mkfifo /tmp/p  # 创建临时管道
sh -i </tmp/p |& nc -l 2333 >/tmp/p
```

该命令将bash的标准输入输出与nc的标准输出输入连接起来，并由nc将其与socket连接起来。同时，nc监听2333端口（如果使用小于1024的端口，需要root权限），等待远程连接。现在打开另一个终端B，准备连接：

```
nc localhost 2333
```

这时，在终端B中出现了sh的提示符。输入一般的shell命令后可以执行并得到结果。看来linux自带的工具已经灵活、强大到足够搭建一个小型的远程登录系统。这个过程可以使用下面的图来描述：

![](https://gitee.com/generals-space/gitimg/raw/master/b786f2e87cd552167bde5bb4dc04bb35.png)

通过tty命令，我们看到，此时的shell并没有一个tty终端。确实，它的标准输入输出都是管道。这会带来一个问题，需要操纵tty的一些命令，比如vi、less、sudo等都无法正常使用（可以动手试试效果怎么样）。更为要命的是，在终端B中按下Ctrl+C这样的控制键，内核把结束信号发送给了客户端nc，而不是远程的程序！

![](https://gitee.com/generals-space/gitimg/raw/master/db1fd86c52dda6c4175d4aec4a372141.png)

Ctrl+C直接杀死nc，结束了会话。对比telnet，我们的登录系统还缺少什么东西。这就是伪终端（pseudoterminal）。

## 二、了解伪终端

### 1. 终端和它的作用

终端（terminal）这个词拥有很多含义，这里尽量将其分开说明。

历史上，终端（有时被成为tty，tele typewriter）是用户访问计算机主机的硬件设备，可以理解为一个显示器和一个键盘的组合。

- 现代Linux里面比较接近此概念的是（一系列）虚拟控制台（virtual console）。在Ubuntu等发行版本中按下Ctrl+Alt+F1(或F2, F3, ...)即可切换到相应控制台下。/dev/tty1等文件是这些硬件在linux下的设备文件。程序通过这些文件的读写实现对控制台的读写，通过ioctl实现对硬件参数的设置。

终端还可以指代设备文件，实现软件接口。比如常见的/dev/tty1文件，还有/dev/pts目录下的所有文件。

- 对终端设备文件进行读写，能够从键盘读取输入，从显示器进行输出，实现交互式的输入输出
- linux中的每个进程有一个“控制终端（control terminal）”的属性（取值为设备文件），用于实现作业控制。在终端上输入Ctrl+C、Ctrl+Z，则以该终端为控制终端的前台进程组会收到终止、暂停的信号。
- 对终端设备进行ioctl操作，可以实现终端相关的硬件参数设置。login、sudo的不显示密码，都离不开对终端设备的操作。

终端还可以指代“终端模拟器”。终端模拟器是应用程序，用于模拟一个终端。它一般是GUI程序，带有窗口。从窗口输入的字符作为模拟键盘的输入，在窗口上打印的字符作为模拟显示器的输出。终端模拟器还需要创建模拟的终端设备（如/dev/pts/1），用于当做命令行进程（CLI进程）的输入输出、控制终端。当键盘键入一个字符，它要让CLI进程从终端设备中读到这个字符，当CLI进程写入终端设备时，终端模拟器要读到并显示出来。

终端模拟器的这个需求，恰恰和telnet这种远程登录服务器的需求相似。telnet服务器也要创建模拟的终端设备，用于当做命令行进程（CLI进程）的输入输出、控制终端。当从网络收到一个字符，它要让CLI进程从终端设备中读到这个字符，当CLI进程写入终端设备时，telnet要把输出发送到网络。

这种共同的需求在linux中有一个统一实现——伪终端（pseudoterminal）。没错，上面的/dev/pts/文件夹里的以数字命名的文件就是伪终端的设备文件。

### 2. 伪终端的介绍

通过man pts可以查阅linux对伪终端的介绍。伪终端是伪终端master和伪终端slave（终端设备文件）这一对字符设备。/dev/ptmx是用于创建一对master、slave的文件。当一个进程打开它时，获得了一个master的文件描述符（file descriptor），同时在/dev/pts下创建了一个slave设备文件。

master端是更接近用户显示器、键盘的一端，slave端是在虚拟终端上运行的CLI（Command Line Interface，命令行接口）程序。Linux的伪终端驱动程序，会把“master端（如键盘）写入的数据”转发给slave端供程序输入，把“程序写入slave端的数据”转发给master端供（显示器驱动等）读取。

![](https://gitee.com/generals-space/gitimg/raw/master/7671946c12f6555903083929461b51fe.png)

我们打开的“终端”桌面程序，其实是一种终端模拟器。当终端模拟器运行时，它通过/dev/ptmx打开master端，创建了一个伪终端对，并让shell运行在slave端。当用户在终端模拟器中按下键盘按键时，它产生字节流并写入master中，shell便可从slave中读取输入；shell和它的子程序，将输出内容写入slave中，由终端模拟器负责将字符打印到窗口中。

（终端模拟器的显示原理就不在这里展开了，这里认为键盘按键形成一列字节流、向显示器输出字节流后便打印到屏幕上）

linux中为什么要提出伪终端这个概念呢？shell等命令行程序不可以直接从显示器和键盘读取数据吗？为了同屏运行多个终端模拟器、并实现远程登录，还真不能让bash直接跨过伪终端这一层。在操作系统的一大思想——虚拟化的指导下，为多个终端模拟器、远程用户分配多个虚拟的终端是有必要的。上图中的shell使用的slave端就是一个虚拟化的终端。master端是模拟用户一端的交互。之所以称为虚拟化的终端，它除了转发数据流外，还要有点终端的样子。

### 3. 作为终端的伪终端

最为一个虚拟的终端，每一个伪终端里面封装了一个终端驱动，让它能做到这些事情：

1. 为程序提供一些输入输出模式的帮助，比如输入密码时隐藏字符
2. 为用户提供对进程的控制，比如按下Ctrl+C结束前台进程

对，这些就是转发数据之外的控制。

**终端的属性：回显控制和行控制**

当用户按下一个按键时，字符会出现在屏幕上。这可不是CLI进程写回来的。不信的话可以在终端里运行cat，随便输入些什么按回车。第二行是cat返回来的，第一行正是终端的特性。

终端驱动里存储了一个状态——回显控制：是否将写入master的字符再次送回master的读端（显示器）。默认情况下这个是启用的。在命令行里可以使用stty来更改终端的状态。比如在终端中运行

```
stty -echo
```

则会关掉当前终端的回显。这时按下按键，已经没有字符显示出来了。输入ls等命令，能够看到shell正常接收到我们的命令（此时回车并没有显示出来）。这时cat后，盲打一些文字，按下回车后看到只有一条文字了。

![](https://gitee.com/generals-space/gitimg/raw/master/189216535ba19c53582cf4d2443ff24a.png)

除了用户通过命令行方式，CLI的程序还能通过系统调用来设置终端的回显，比如login，sudo等程序就是通过暂时关闭回显来隐藏密码的。具体方式是在slave的文件描述符上调用ioctl函数（参考man tty_ioctl），不过推荐使用更友好的tcsetattr函数。详细设置可查阅man tcsetattr。

另外，终端驱动还提供有行缓冲功能。还是以cat为例：当我们输入文字，在键入回车之前，cat并不能读取到我们输入的字符。这里的cat的行为可以理解为逐字符读写：

```c
while(read(0, &c, 1) > 0) //read from stdin, while not EOF
    write(1, &c, 1);  //write to stdout
```

是谁阻止cat及时读入字符了呢？其实是终端驱动。它默认开启了一个行缓冲区，这样等程序要调用read系统调用时，先让程序阻塞着（blocked），等用户输入一整行后，才解除阻塞。我们可以使用下列命令将行缓存大小设置为1：

```
stty min 1 -icanon
```

这时，运行cat，尝试输入文字。每输入一个字符，能够立即返回一个字符。（把min改为time，还能设置输入字符最长被阻塞1秒）

这些终端的状态属性信息还有很多，比如设置终端的宽度、高度等。具体可以参考man stty。

**特殊控制字符**

特殊控制字符，是指Ctrl和其他键的组合。如Ctrl+C、Ctrl+Z等等。用户按下这些按键，终端模拟器（键盘）会在master端写入一个字节。规则是：Ctrl+字母得到的字节是（大写）字母的ascii码减去0x40。比如Ctrl+C是0x03，Ctrl+Z是0x1A。参见下表：

![](https://gitee.com/generals-space/gitimg/raw/master/846d07be797f37975bd39eda30410696.png)

驱动收到这些特殊字符，并不会像收到正常字节那样处理。在echo的时候，它返回两个可见字符。比如键入Ctrl+C（0x03），就会回显^和C（0x5E 0x03）两个字符。更重要的是，驱动将会拦截某些控制字符，他们不会被转发给slave端，而是触发作业控制（job control）的规则：向前台进程组发送SIGINT信号。

要想绕过这一机制，我们可以使用stty的一些设置。下面的命令能够同时关闭控制字符的特殊语义、设置行缓冲大小为1：

```
stty raw
```

然后，运行cat命令，我们键入的所有字符，包括控制字符Ctrl+C（0x03），都会成功传递给cat，并且被原样返回。（可以试试上下左右、回车键的效果）

## 三、实验：利用伪终端实现远程登录

理解伪终端的基本原理后，我们就可以尝试解释telnet和SSH等远程登录的原理了。每次用户通过客户端连接服务端的时候，服务端创建一个伪终端master、slave字符设备对，在slave端运行login程序，将master端的输入输出通过网络传送至客户端。至于客户端，则将从网络收到的信息直接关联到键盘/显示器上。我们将这个过程描述为下图：

![](https://gitee.com/generals-space/gitimg/raw/master/71b1fc497870e94ef7fdc6bdea39f4e0.png)

说了这么多，其实这个结构相比本文第一张图而言，只多了一个伪终端。下面具体描述各部分的实现细节。

### 服务端②：创建伪终端，并将master重定向至nc

按照man pts中的介绍，要创建master、slave对，只需要用open系统调用打开/dev/ptmx文件，即可得到master的文件描述符。同时，在/dev/pts中已经创建了一个设备文件，表示slave端。但是，为了能让其他进程（login，shell）打开slave端，需要按照手册介绍来调用两个函数：

> Before opening the pseudoterminal slave, you must pass the master's file descriptor to grantpt(3) and unlockpt(3).

具体信息可以查阅man 3 grantpt,man 3 unlockpt文档。

我们可以直接关闭（man 2 close）终端创建进程的0和1号文件描述符，把master端的文件描述符拷贝（man 2 dup）到0和1号，然后把当前进程刷成nc（man 3 exec）。这虽然是比较优雅的做法，但比较复杂。而且当没有进程打开slave的时候，nc从master处读不到数据（read返回0），会认为是EOF而结束连接。所以这里用一个笨办法：将所有从master读到的数据通过管道送给nc，将所有从nc得到的数据写入master。我们需要两个线程完成这件事。

此小节代码总结如下：

```c++
//ptmxtest.c

//先是一些头文件和函数声明
#define _XOPEN_SOURCE
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<sys/ioctl.h>

/* Chown the slave to the calling user.  */
extern int grantpt (int __fd) __THROW;

/* Release an internal lock so the slave can be opened.
   Call after grantpt().  */
extern int unlockpt (int __fd) __THROW;

/* Return the pathname of the pseudo terminal slave associated with
   the master FD is open on, or NULL on errors.
   The returned storage is good until the next call to this function.  */
extern char *ptsname (int __fd) __THROW __wur;

char buf[1]={'\0'};  //创建缓冲区，这里只需要大小为1字节
int main()
{
    //创建master、slave对并解锁slave字符设备文件
	int mfd = open("/dev/ptmx", O_RDWR);
	grantpt(mfd);
	unlockpt(mfd);
    //查询并在控制台打印slave文件位置
	fprintf(stderr,"%s\n",ptsname(mfd));

	int pid=fork();//分为两个进程
	if(pid)//父进程从master读字节，并写入标准输出中
	{
		while(1)
		{
			if(read(mfd,buf,1)>0)
				write(1,buf,1);
			else
				sleep(1);
		}
	}
	else//子进程从标准输入读字节，并写入master中
	{
		while(1)
		{
			if(read(0,buf,1)>0)
				write(mfd,buf,1);
			else
				sleep(1);
		}
	}

	return 0;
}
```

将文件保存后，打开一个终端（称为终端A），运行下列命令，在命令行中建立此程序与nc的通道：

```
gcc -o ptmxtest ptmxtest.c
mkfifo /tmp/p
nc -l 2333 </tmp/p | ./ptmxtest >/tmp/p
```

至此，图中的②构建完毕，已经有一个nc在监听2333端口，它的输入输出通过管道送到ptmxtest程序中，ptmxtest又将这些信息搬运给master端。

在我的Ubuntu中运行命令后显示，创建的slave设备文件是/dev/pts/20。

### 服务端①：将login程序与终端关联起来

在图中①处的地方，需要将login与伪终端的输入输出关联起来。这一点通过输入输出重定向即可完成。不过，想要实现Ctrl+C等作业控制，还需要更多的设置。这涉及到一些Linux的进程管理的知识（感兴趣的可以去搜索“进程、进程组、会话、控制终端”等关键字）。

一个进程与终端的联系，不仅取决于它的输入输出，还有它的控制终端（Controlling terminal，可通过tty命令查询，通过/dev/tty打开）。简单地说，进程控制终端是谁，谁才能向进程发送控制信号。这里要将login的控制终端设为伪终端，具体说是slave设备文件才行。

设置控制终端需要使用终端设备的ioctl来实现。查看man tty_ioctl，可以找到相关信息：

> **Controlling terminal**
> 
> TIOCSCTTY int arg
>> Make the given terminal the controlling terminal of the calling process. The calling process must be a session leader and not have a controlling terminal already. For this case, arg should be specified as zero.
>
> TIOCNOTTY void
>> If the given terminal was the controlling terminal of the calling process, give up this controlling terminal. ...

比较重要的信息是，我们可以指定TIOCSCTTY参数来设置控制终端，但它要求调用者是没有控制终端的会话组长（Session leader）。所以要先指定TIOCNOTTY参数来放弃当前控制终端，并用setsid函数（man 2 setsid）创建新的会话并设置自己为组长。

我们将login包装一层，完成上面的操作，得到新的程序mylogin：

```c++
//mylogin.c

#include<stdio.h>
#define _XOPEN_SOURCE
#include<stdlib.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<termios.h>
#include<sys/ioctl.h>

int main(int argc, char *argv[])
{
	int old=open("/dev/tty",O_RDWR);  //打开当前控制终端
	ioctl(old, TIOCNOTTY);  //放弃当前控制终端
  
    //根据"man 2 setsid"的说明，调用setsid的进程不能是进程组组长（从bash中运行的命令是组长），故fork出一个子进程，让组长结束，子进程脱离进程组成为新的会话组长
	int pid=fork();
	if(pid==0){
		setsid();  //子进程成为会话组长
		perror("setsid");  //显示setsid是否成功
		ioctl(0, TIOCSCTTY, 0);  //这时可以设置新的控制终端了，设置控制终端为stdin
		execv("/bin/login", argv);  //把当前进程刷成login
	}
	return 0;
}
```

保存文件后，打开一个终端（称为终端B），编译运行：

```
gcc -o mylogin mylogin.c
#假设这里的slave设备是/dev/pts/20
#因为login要读取密码文件，需要用root权限执行
sudo ./mylogin </dev/pts/20 >/dev/pts/20 2>&1
```

该命令将实验图中①处的slave设备，重定向至mylogin的stdin、stdout和stderr。在程序执行时，会将控制终端设置为伪终端，然后执行login。至此，服务端全部建立完毕。

### 客户端：连接远程机器，配置本地终端

客户端处于实验图的③处。打开新的终端（终端C），这里简单地使用nc连接远程socket，并且nc的输入输出重定向至键盘、显示器即可。但是要注意，nc是运行在终端C上的，而终端C的默认属性会拦截字符Ctrl+C、使用行缓冲区域。这样nc的输入输出其实并不直接是键盘、显示器。为此，我们先设置终端C的属性，再运行nc：

```
stty raw -echo
nc localhost 2333  #该行没有回显，要摸黑输入
```

然后，在终端C中出现了我们打印的setsid的信息，和login的提示符。在终端C中，使用键盘可以正常登录，得到shell的提示符。使用tty命令能够看到当前shell使用的控制终端是/dev/pts/20，也就是我们创建的伪终端。输入w命令可以看到系统中登录的用户和登录终端。

![](https://gitee.com/generals-space/gitimg/raw/master/a9a813f77d0eaafc01664b636314bfc2.png)

至此为止，我们实现了类似telnet的远程登录。

## 结语

linux中终端驱动本身有回显、行缓存、作业控制等丰富的属性，在此基础上实现的伪终端在终端模拟器、远程登录等场合下能够得到多种应用。

在实验过程中也牵扯到进程控制、输入输出重定向、网络通信这么多的知识，更体现出linux的复杂精致的结构。我感觉，**linux 就像一个包罗万象、又自成体统的小宇宙，它采用独特的虚拟化技术，灵活的模块化和重用机制，虚拟出各种设备，实现了驱动程序的随意拼插。在这里，所有模块都得到了充分的利用，并能够像变形金刚那样对各类需求提出面面俱到的解决方案。**
