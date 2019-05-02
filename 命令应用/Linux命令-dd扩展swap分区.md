# Linux命令-dd扩展swap分区

参考文章

1. [手把手教您扩展SWAP虚拟内存](http://blog.csdn.net/linuxnews/article/details/51271875)

2. [通过操作swap文件来扩大或缩小swap空间](https://blog.csdn.net/onebigday/article/details/7410733)

系统: CentOS 7

原来的swap空间为8G

```
$ free -m
              total        used        free      shared  buff/cache   available
Mem:          15837       14663         168           8        1006         743
Swap:          8912        1604        7308
```

1. 创建`/home/swapfile`文件, 每个块为1M, 一共`1024 * 32`个块.

```
$ dd if=/dev/zero of=/home/swapfile bs=1M count=32768
```

2. 格式化刚才创建的`swapfile`

```
$ mkswap -f /home/swapfile 
正在设置交换空间版本 1，大小 = 33554428 KiB
无标签，UUID=11f974e2-9acd-4066-8697-cce532440278
```

3. 启用swapfile,查看虚拟内存大小

```
$ swapon /home/swapfile
swapon: /home/swapfile：不安全的权限 0644，建议使用 0600. 
$ chmod 600 /home/swapfile
$ swapon /home/swapfile
$ free -m
              total        used        free      shared  buff/cache   available
Mem:          15837       14875         233           8         728         535
Swap:         41680        1714       39966
```

4. 实现开机自动挂载交换文件

在`/etc/fstab`中增加一下条目 `/home/swapfile swap swap defaults 0 0`, 就能实现开机自动挂载.

```
$ cat /etc/fstab 
# /etc/fstab
# Created by anaconda on Sat Dec 30 01:38:57 2017
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=5a1fca7a-645e-45bf-ac70-b591fc951b87 /boot                   xfs     defaults        0 0
/dev/mapper/centos-home /home                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
/home/swapfile		swap 			swap	defaults	0 0
```

### 减小swap分区

参考文章2文末的方法可行.

```
[root@192-168-104-74 home]# free -m
              total        used        free      shared  buff/cache   available
Mem:          23938       12996         552          32       10389       10368
Swap:         73727         443       73284
[root@192-168-104-74 home]# swapon -s
Filename				Type		Size	Used	Priority
/dev/sda2                              	partition	8388604	453992	-1
/home/swapfile                          	file	67108860	0	-2
## 首先用swapoff命令收回空间
[root@192-168-104-74 home]# swapoff /home/swapfile 
## 查看swap空间已经缩减
[root@192-168-104-74 home]# free -m
              total        used        free      shared  buff/cache   available
Mem:          23938       12951         596          32       10390       10413
Swap:          8191         443        7748
```

如果不准备再使用额外的swapfile, 就可以删掉这个文件, 然后将`/etc/fstab`中对这个文件的挂载行删除.

如果只是想将这个swapfile变小一点, 那么先删除原来的, 再重新创建一个比较小的文件, 格式化后再重新挂载, 但是`/etc/fstab`就不用再修改了.

## FAQ

### 1. 挂载swap文件的时候提示设备忙

```
$ swapon /home/swapfile
swapon: /home/swapfile：swapon 失败: 设备或资源忙
```

> 提示: ...其实可能已经挂上了, 可以用`free`查看一下.