# KVM安装实践

## 1. KVM模块安装

KVM是Linux内核模块, 如果需要安装KVM虚拟机, 则需要将KVM模块编译进内核. 因为这次的系统平台是Fedora, 默认将KVM以模块的形式添加入内核, 所以就没有再执行内核编译. 查看内核的KVM模块方法:

```
[root@localhost ISO]# lsmod | grep 'kvm'
kvm_intel             159744  3
kvm                   495616  1 kvm_intel
```

## 2. QEMU-KVM工具安装

### 2.1 QEMU-KVM配置

```
git clone git://kernel.org/pub/scm/virt/kvm/qemu-kvm.git
```

配置项有很多, 但貌似保持默认就可以了. 直接执行`./configure`

####　2.1.1 第一次出现这个错误

```
[root@localhost qemu-kvm]# ./configure 

Error: zlib check failed
Make sure to have the zlib libs and headers installed.
```

刚开始以为是缺失zlib包与linux内核头, 但是`dnf install zlib kernel-headers`结果发现这两个已经安装, 并未执行任何操作.

迷茫了一会又尝试了一下dnf search zlib, 东西有很多, 猜测可能是因为zlib的开发包未安装. 又执行了dnf zlib-devel

再次configure, 不再报这个错.

#### 2.1.2 但是又出现新问题

```
[root@localhost qemu-kvm]# ./configure 
glib-2.12 required to compile QEMU
```

这个问题百度上有解决方案, 就是glib2包缺失造成的. 保险起见, 将开发包也装上

```
[root@localhost general]# dnf install glib2 glib2-devel
```

这样之后, configure成功.

2.2 QEMU-KVM编译

直接执行make, 却又出现错误:

```
...
...
In file included from ./qemu-common.h:6:0,
from block/qcow2-snapshot.c:25:
block/qcow2-snapshot.c: In function ‘qcow2_write_snapshots’:
./compiler.h:36:23: error: typedef ‘qemu_build_bug_on__250’ locally defined but not used [-Werror=unused-local-typedefs]
typedef char cat2(qemu_build_bug_on__,__LINE__)[(x)?-1:1];
^
...
...
cc1: all warnings being treated as errors
/home/general/Documents/qemu-kvm/qemu-kvm/rules.mak:18: recipe for target 'block/qcow2-snapshot.o' failed
make: *** [block/qcow2-snapshot.o] Error 1
```

看了一下错误原因, 感觉没必要这样也报错(只是一个typedef的变量声明之后没有被使用, 又不是使用的时候发现没有对应的声明).

注意倒数第三行的话: 所有的warnings都被当作errors处理, 所以其实这些错误并不"致命". 在configure生成的Makefile文件中加入

```
QEMU_CFLAGS+=-w
```

再次编译, 成功.

### 2.3 QEMU-KVM安装

make install没有遇到问题, 而且速度很快.

## 3. 安装客户机(就是虚拟机)

这些步骤是书上或是网上的东西, 太多了. 直接拿来抄一下吧.

目标虚拟机是ubuntu 15.04, 所以需要有足够的本地硬盘空间以及要安装的系统的ISO文件

### 3.1 首先创建硬盘

使用Linux下的`dd`命令, `of`选项的参数是目标文件的名称, count选项的参数为硬盘大小, 10G对于ubuntu来说足够了

```
[general@localhost kvm1]$ dd if=/dev/zero of=ubuntu.img bs=1M count=10240
10240+0 records in
10240+0 records out
10737418240 bytes (11 GB) copied, 96.2183 s, 112 MB/s
```

### 3.2 启动虚拟机, 开始安装系统

-m选项是为此虚拟机分配的内存, 这里是2G;

-smp 是为其分配的CPU个数, 这里是1个;

-boot选项是该虚拟机的启动介质顺序(order参数的值的含义c: CD-ROM; d: Hard Disk);

-had目标虚拟的硬盘名称, 使用上一步创建的文件即可;

-cdrom是分配给该虚拟机的光盘介质, 选择目标ISO文件即可;

```
[general@localhost kvm1]$ qemu-system-x86_64 -m 2048 -smp 1 -boot order=cd -hda ./ubuntu.img -cdrom 目标ISO路径/ubuntu-15.04-desktop-amd64.iso 
VNC server running on `127.0.0.1:5900'
```

QEMU会启动一个VNC server, 可以使用vnc工具连接该地址. Fedora中默认安装的vinagre工具就是一个VNC客户端软件, 命令行或是在GNOME的软件搜索框中寻找vinagre都可以.

启动之后选择连接协议, 默认是SSH, 不知道这个可不可以, 我直接使用VNC协议, Host地址就填写127.0.0.1即可, 没有发现端口的填写位置. 点击连接, 就看见Ubuntu的安装界面, 按照提示进行安装, 与VMWare没有太大区别.

### 3.3

再次启动虚拟的时候就不必指定启动顺序与光驱了, 直接执行

```
[general@localhost kvm1]$ qemu-system-x86_64 -m 2048 -smp 1 -hda ./ubuntu.img
```

完成.