# Linux磁盘挂载与格式化

参考文章

[VMware 虚拟机中添加新硬盘的方法](http://blog.csdn.net/hanpengyu/article/details/7475645)

## 1. 理解磁盘挂载

在安装操作系统时, 如果是一块崭新的硬盘, 系统安装程序会提示我们格式化, 并为系统进行分区; 如果是一个已经格式化过的硬盘, 格式化操作就不再是为了让操作系统可以识别, 更多的是清除数据, 也不必再执行分区操作.

在向系统中新增磁盘时, 同样, 如果这是一块未被格式化的崭新磁盘, 系统是无法识别的, 或者, 如果该磁盘上存在的是一个当前系统不能识别的文件系统, 那系统也是不能使用的. 此时, 就像裸机上安装操作系统一样, 需要将这块磁盘格式化成系统可用的格式. 注意: 不能识别是指无法读写, 看还是看的到的.

于是, 就像Windows上的`磁盘管理`, Linux上的`fdisk`, 两者都可以看到安装到主机插槽的所有硬盘, 然后就可以执行格式化了.

当然, 如果这块磁盘本身已经被格式化过并且其文件系统可以识别, 那将其安装到主机插槽就相当于接了一块移动硬盘, 直接可以使用了.

但是linux系统比windows多了一个`挂载(mount)`操作, 因为Linux下所有的磁盘分区都保存在`/etc/fstab`文件中, 系统安装时自动生成最初始的配置, 然后每次启动主机都会加载其中的分区, 才能使用. 而新的磁盘没有在这个文件中, 所以需要手动`挂载`, 让系统能够访问到. Windows与许多桌面版Linux系统都在后台运行一个服务, 当插入U盘或是移动硬盘等设备, 系统会自动执行挂载操作, 但Linux服务器版本一般不会有这个服务, 所以, 手动挂载的方式还是很有必要的.

### 2.1 Windows

1. 右键"我的电脑"－>"管理"－>"磁盘管理"，然后会看到新分配的磁盘但没有分区

2. 右键"新加卷"(未分区的磁盘)，选择"新建"，按照向导，一步步，选择硬盘分区模式、格式化硬盘即可使用.

### 2.2 Linux

随着服务器中服务的增加, 磁盘容量也逐渐告急, 这时我们需要为服务器添加一块新磁盘. Linux主机中插入一块全新的硬盘, 需要将其格式化让系统能够识别, 然后通过挂载, 可以让程序能够访问到. 具体步骤如下.

root身份执行`fdisk -l`, 可以看到新的磁盘, 但未分区, 默认为sdb.

```
$ fdisk -l

Disk /dev/sda: 85.9 GB, 85899345920 bytes
255 heads, 63 sectors/track, 10443 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0004a605

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          39      307200   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              39         549     4096000   82  Linux swap / Solaris
Partition 2 does not end on cylinder boundary.
/dev/sda3             549       10444    79481856   83  Linux

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
```

对新的磁盘执行分区及格式化的操作.

```
$ fdisk /dev/sdb
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x4fe05028.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help):
```

m键可以查看帮助, 下面直接创建分区, 一个硬盘可以创建最多4个主分区与多个扩展分区. 我们将这个新磁盘当作一个分区.

```
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-2610, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-2610, default 2610):
Using default value 2610

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

再次使用 "fdisk -l"这个命令来查看会发现出现了`/dev/sdb1`(说明已经完成了分区工作)

```
$ fdisk -l

Disk /dev/sda: 85.9 GB, 85899345920 bytes
255 heads, 63 sectors/track, 10443 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0004a605

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          39      307200   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              39         549     4096000   82  Linux swap / Solaris
Partition 2 does not end on cylinder boundary.
/dev/sda3             549       10444    79481856   83  Linux

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x4fe05028

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1        2610    20964793+  83  Linux

```

对新建的分区进行格式化: 格式化成ext4的文件系统即可

```
$ mkfs -t ext4 /dev/sdb1
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1310720 inodes, 5241198 blocks
262059 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=4294967296
160 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
	4096000

Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 33 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

```

下面便是对于分好区的`/dev/sdb1` 这一个分区进行挂载及访问.

在挂载之前使用`df -h`查看系统所有可用分区

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        75G  6.4G   65G  10% /
tmpfs           238M  4.0K  238M   1% /dev/shm
/dev/sda1       291M   39M  238M  14% /boot
```

**手动挂载**

使用`mount /dev/sdb1  /要挂载的目录(自定义)`, 然后`cd  /挂载的目录`, 即可对其进行存储和访问

**自动挂载**

修改`/etc/fstab`即可

使用`vim /etc/fstab`打开配置的文件，然后将下面的一行文字添加即可. 这样每次系统启动时就会挂载此磁盘, 直接可以使用.

```
/dev/sdb1       /media(这个挂载的目录你自己设置即可)      ext4    defaults       0       1
```

挂载后, 再次用`df -h`查看

```
$ mount /dev/sdb1 /media
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        75G  6.4G   65G  10% /
tmpfs           238M  4.0K  238M   1% /dev/shm
/dev/sda1       291M   39M  238M  14% /boot
/dev/sdb1        20G  172M   19G   1% /media
```
