# Linux-hostname详解

参考文章

1. [How to Change Hostname in RHEL / CentOS 7.0](http://linoxide.com/linux-command/change-hostname-in-rhel-centos-7/)

2. [linux的hostname修改详解](http://soft.chinabyte.com/os/281/11563281.shtml)

3. [深入理解Linux修改hostname](http://www.cnblogs.com/kerrycode/p/3595724.html)

## 1. 基本配置及使用方法

能对系统hostname进行操作的配置或命令:

1. `hostname`命令

2. `/proc/sys/kernel/hostname`文件(由于`/proc`是系统启动时创建的虚拟文件系统, 所以这里并不将其本身当做可配置项, 但的确可以通过读写操作修改其值).

3. `sysctl kernel.hostname`的值

4. `/etc/hosts`文件

5. `/etc/hostname`文件

6. `/etc/sysconfig/network`文件
...

------

首先, 网上各种版本纷杂, 不同版本的linux对`hostname`修改各不相同, 并且修改hostname不只有一种手段. 不过大部分人应该是为的能在命令提示符中显示当前hostname值, 生效即可, 不必过多地纠结.

> `$HOSTNAME`值, 体现在Linux命令提示符`PS1`变量的`\H`选项中, 可以通过设置`PS1`变量查看当前会话中的hostname(当然, 也可以直接`echo $HOSTNAME`查看).

系统在启动的时候会按照一个优先级顺序从众多配置文件中加载hostname的值, 并将其写入到`$HOSTNAME`环境变量, 在重新启动之前, 只要没有显式的修改这个变量, 就不会对系统的hostname产生影响.

### 1.1 HOSTNAME环境变量

上述方法中第1,2,3方法本质相同, 对它们的修改操作实际上都是修改了`$HOSTNAME`环境变量, 所以任意一种方法都会对另外两种方法获取hostname产生影响(不过在当前shell是不生效的, 需要打开新会话). 

```
$ hostname 
generals-space
$ cat /proc/sys/kernel/hostname 
generals-space
$ sysctl kernel.hostname
kernel.hostname = generals-space

## 通过hostname命令修改, 不过在当前会话中不生效
$ hostname testname
$ cat /proc/sys/kernel/hostname 
generals-space

## 新开shell会话, 会发现三种操作获取到的hostname值都变了
$ hostname 
testname
$ cat /proc/sys/kernel/hostname 
testname
$ sysctl kernel.hostname
kernel.hostname = testname
```

目前还不知道这三种方式的底层操作如何, 可以使用当前shell的`$HOSTNAME`环境变量不变, 转而影响其他shell的环境变量. 猜测是直接修改了内存中的`$HOSTNAME`值, 而且修改的是这种普通shell的顶级父进程内存区处的内容, 使得所有新建的shell都继承了这块内存中`$HOSTNAME`的值<???>.

不过这种方法设置的hostname在系统重启后就消失了, 永久生效的修改方法, 还是需要写入到配置文件中.

### 1.2 配置文件

网上的讲解一般基于在CentOS6及以下版本, 对hostname的值有明确影响的是`/etc/sysconfig/network`文件, 属于网络服务. 只要在其中定义了`HOSTNAME=新hostname`, 重启系统就会自动加载.

也有大部分文章讲解了修改`/etc/sysconfig/network`异常的情况, 都是系统在启动过程中, 由于`/etc/rc.d/rc.sysinit`的执行, 使得hostname同时关联了`/etc/sysconfig/network`与`/etc/hosts`文件.

首先, 前者是一定会读取的, 如果前者中没有`HOSTNAME`的定义, 那`$HOSTNAME`值默认为`localhost.localdomain`. 但是`rc.sysinit`文件中可能还会存在这种判断: 如果`$HOSTNAME`的值为`localhost`或是`localhost.localdomain`, 还会去读取`/etc/hosts`文件, 并使用网卡接口的IP(如果有设置的话)对应的域名设置hostname.

...其实我还没遇见过这种情况.

------

CentOS7下似乎有些不同. 如果最初只是单纯修改`/etc/sysconfig/network`文件然后新建终端甚至重启, 无法使其生效. 

```
Connecting to 172.32.100.10:22...
Connection established.

Last login: Mon Dec  5 06:16:54 2016 from 172.32.100.1
$ cat /etc/sysconfig/network
# Created by anaconda
HOSTNAME=generals-space

$  hostname
localhost.localdomain
```

根据参考文章中的做法, 可以使用CentOS7自带的`hostnamectl`命令,  它是systemd机制中`systemd-hostnamed.service`服务的客户端操作工具, 专门用来修改hostname值.

其使用方法为

```
$ hostnamectl [--static | --transient | --pretty] set-hostname 新的hostname
```

`--static`选项会使得hostname存储在`/etc/hostname`文件中, 系统启动时会优先读取这个文件中的配置. 新建shell生效, 重启后配置保留. 注意哦, **直接修改`/etc/hostname`是不成的!!!**

`--transient`有点暂时性的意思, 貌似不会写入任何文件, 新建shell中hostname值生效, 重启后消失.

`--pretty`选项会生成`/etc/machine-info`文件, 假设新的hostname为`general`, 使用此选项`machine-info`文件内容将为`PRETTY_HOSTNAME=general`. 但是新建shell和重启都无效, 貌似只能通过`hostnamectl status --pretty`查看.

------

有意思的是, 通过`hostnamectl`命令设置`static`类型的hostname后, 删除`/etc/hostname`文件, `/etc/sysconfig/network`中的`HOSTNAME`字段居然又生效了...而且每次修改它, 重启后都会生效, 简直就像是`hostnamectl`打开了这个文件的开关一样...stupid.

## 2. /etc/hosts对hostname的影响

这个要求在`/etc/hosts`文件中写入当前`hostname`对应的IP映射才有效.

`hostname`有两个选项`-a`和`-f`, 会输出`/etc/hosts`中配置的值.

```
[root@192-168-174-93 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.174.93 192-168-174-93.localdomain 192-168-174-93
[root@192-168-174-93 ~]# hostname -a
192-168-174-93
[root@192-168-174-93 ~]# hostname -f
192-168-174-93.localdomain
```

貌似在`/etc/hosts`这个文件中, 加了主机名的hostname要写前面, 单纯的hostname要写后面.

如果删掉hostname的映射, 则`hostname -a`将输出空值, `hostname -f`会直接得到`hostname`的值.

## 3. hostname原理

<???>