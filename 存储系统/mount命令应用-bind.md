# mount命令应用-bind

参考文章

1. [linux VFS文件系统 ----mount命令介绍（一）](https://blog.csdn.net/weixin_37867857/article/details/90510607)
    - `mount`命令的`--bind`参数使用方法
2. [mount --bind和硬连接的区别](https://blog.csdn.net/shengxia1999/article/details/52060354)
    - `mount --bind`命令和硬链接很像, 都是连接到同一个`inode`上面, 只不过后者无法连接目录, 而前者命令弥补了这个缺陷.
    - 很多人将`mount --bind`理解为针对目录的硬连接, 但这想法是错误的, 底层原理不一样.

`mount`在默认情况下只能挂载块设备, 比如我们随便建一个目录`source`, 是没有办法将ta挂载到指定目录的. 

```console
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

不过常规硬链接不可以创建目录的链接, 只能创建文件的链接, 而且需要目标文件不可事先存在.

这两者的底层原理并不一样, `mount --bind`更像是向目标目录上面覆盖了层虚拟层, 但目标的内容其实并没有被清空, 只是被隐藏了, 使用`umount`解除挂载后还可以还原.

详情可见参考文章2.
