# Linux启动genymotion提示要先安装virtualbox的问题

系统: CentOS7

VirtualBox: 5.1

genymotion: 2.11

安装genymotion完成后启动, 提示要先安装virtualbox, 但实际上已经事先安装了`VirtualBox-5.1`

提示如下

![](https://gitee.com/generals-space/gitimg/raw/master/fde94594197e4ffc107afefcd9e41d0f.png)

尝试单独运行virtualbox, 命令行显示如下

```
$ virtualbox 
WARNING: The vboxdrv kernel module is not loaded. Either there is no module
         available for the current kernel (3.10.0-693.el7.x86_64) or it failed to
         load. Please recompile the kernel module and install it by

           sudo /sbin/vboxconfig

         You will not be able to start VMs until this problem is fixed.
```

不过能够正常启动, 没有尝试新建虚拟机, 估计会失败.

按照它的提示执行了`/sbin/vboxconfig`, 结果如下

```
$ /sbin/vboxconfig 
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
This system is not currently set up to build kernel modules (system extensions).
Running the following commands should set the system up correctly:

  yum install kernel-devel-3.10.0-693.el7.x86_64
(The last command may fail if your system is not fully updated.)
  yum install kernel-devel
vboxdrv.sh: failed: Look at /var/log/vbox-install.log to find out what went wrong.
This system is not currently set up to build kernel modules (system extensions).
Running the following commands should set the system up correctly:

  yum install kernel-devel-3.10.0-693.el7.x86_64
(The last command may fail if your system is not fully updated.)
  yum install kernel-devel

There were problems setting up VirtualBox.  To re-start the set-up process, run
  /sbin/vboxconfig
as root.
```

OK, 看来是因为内核依赖没装, 继续执行它提示的安装命令, 如下.

```
$ yum install kernel-devel-3.10.0-693.el7.x86_64
$ yum install kernel-devel
$ /sbin/vboxconfig 
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
vboxdrv.sh: Starting VirtualBox services.
```

完成. genymotion也能启动了.