# mount命令应用-bind

参考文章

1. [linux VFS文件系统 ----mount命令介绍（一）](https://blog.csdn.net/weixin_37867857/article/details/90510607)
    - 基本的mount命令分为三部分：
        1. 磁盘(块设备)的挂载
        2. 远程计算机目录挂载(如NFS)
        3. 目录绑定(如`--bind`)
    - `mount`命令的`--bind`参数使用方法
2. [mount --bind和硬连接的区别](https://blog.csdn.net/shengxia1999/article/details/52060354)
    - `mount --bind`命令和硬链接很像, 都是连接到同一个`inode`上面, 只不过后者无法连接目录, 而前者命令弥补了这个缺陷.
    - 很多人将`mount --bind`理解为针对目录的硬连接, 但这想法是错误的, 底层原理不一样.

## 引言

`mount`在默认情况下只能挂载块设备, 比如我们随便建一个目录`source`, 是没有办法将ta挂载到指定目录的. 

```log
$ pwd
/tmp
$ mkdir source
$ mount /tmp/source /tmp/target
mount: 挂载点 /tmp/target 不存在
$ mkdir target
$ mount /tmp/source /tmp/target
mount: /tmp/source 不是一个块设备
```

按照常理来说, `source`可以是已格式化过的磁盘分区, 或是NFS等网络存储路径, 不可以是常规的目录, 但是`--bind`参数解除了这个限制.

```
mount --bind /tmp/source /tmp/target
```

这个操作几乎和硬链接没有区别, 源文件和目标文件的`inode`编号是一致的. 无论是在`source`, 还是在`target`目录下进行目录操作, 都是双方共享的.

**不过常规硬链接不可以创建目录的链接, 只能创建文件的链接, 而且需要目标文件不可事先存在.**

这两者的底层原理并不一样, `mount --bind`更像是向**目标目录**上面**覆盖**了层虚拟层, 但目标的内容其实并没有被清空, 只是被隐藏了, 使用`umount`解除挂载后还可以还原.

详情可见参考文章2.

## mount bind 使用

### 关于覆盖

上面说到, `mount --bind`更像是向**目标目录**上面**覆盖**了层虚拟层, 并不影响该目录原本的内容, 接下来实验一下.

首先, 先解除上面将`source`映射到`target`的绑定.

```
umount /tmp/target
```

在源目录与目标目录分别创建txt文件, 用以区分.

```
touch /tmp/source/source.txt
touch /tmp/target/target.txt
```

然后重新映射

```
mount --bind /tmp/source /tmp/target
```

查看变化

```log
$ ls /tmp/source
source.txt
/tmp
$ ls /tmp/target
source.txt
```

可以看到, `source`已经将`target`覆盖了.

我们在`source`与`target`目录再分别创建一个文件, 研究`--bind`之后目录的修改, 是否会引起`target`原内容的变化.

```
touch /tmp/source/source-after-bind.txt
touch /tmp/target/target-after-bind.txt
```

```log
$ ls /tmp/source
source-after-bind.txt  source.txt  target-after-bind.txt
/tmp
$ ls /tmp/target
source-after-bind.txt  source.txt  target-after-bind.txt
```

可以看到, 此时双方是互通的.

------

ok, 现在我们将映射关系解除, 看看原`target`目录的内容还在不在.

```log
$ umount /tmp/target
/tmp
$ ls /tmp/source
source-after-bind.txt  source.txt  target-after-bind.txt
/tmp
$ ls /tmp/target
target.txt

```

可以看到, 上面对`source`目录的修改是永久的, 而对`target`的修改则只是在一个"虚拟层"中, 卸载后就恢复了.

### 关于删除

我们知道, 硬链接的源文件与目标文件, 是同一个`inode`, ta们的地位完全等同, 无论删除硬链接双方的哪个, 另一个都会作为一个普通文件仍然存在.

```log
$ ln source.log target.log
$ ll -i | grep log
404684629 ----------  2 root root   19 Jan  7 18:11 source.log
404684629 ----------  2 root root   19 Jan  7 18:11 target.log
$ rm -f source.log
$ ll -i | grep log
404684629 ----------  1 root root   19 Jan  7 18:11 target.log
```

那么`bind`的映射呢? 双方的目录, 能删吗? 会影响对方吗?

```log
$ mount --bind /tmp/source /tmp/target
/tmp
$ ll /tmp/target
total 0
-rw-r--r-- 1 root root 0 Jan 18 14:56 source-after-bind.txt
-rw-r--r-- 1 root root 0 Jan 18 14:40 source.txt
-rw-r--r-- 1 root root 0 Jan 18 14:56 target-after-bind.txt
/tmp
$ rm -rf /tmp/target
rm: cannot remove ‘/tmp/target’: Device or resource busy
```

作为被映射端, `target`在删除时报错了, `Device or resource busy`, 也是可以预见的. 

------

不过反过来却是可以的

```log
$ rm -rf /tmp/target
$ ls /tmp/source
ls: cannot access /tmp/source: No such file or directory
```

**但是**, 删除源目录并不会删除`mount`挂载信息. 

```log
$ mount | grep target
/dev/sda3 on /tmp/target type xfs (rw,relatime,attr2,inode64,noquota)
```

这个关系还在, 这导致此时`target`目录映射了一个不存在源目录, 因此无法做任何变更.

```log
$ ll /tmp/target
total 0
/tmp/target
$ touch /tmp/target/target.txt
touch: cannot touch ‘/tmp/target/target.txt’: No such file or directory
```

必须要对`target`先进行`umount`才行.

```log
$ umount /tmp/target/
/tmp
$ ll /tmp/target/
total 0
-rw-r--r-- 1 root root 0 Jan 18 15:28 target.txt
```
