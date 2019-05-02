# Linux文件时间属性

参考文章

[linux文件的三种时间属性](http://blog.csdn.net/signjing/article/details/7723516)

[Find命令搭配atime/ctime/mtime时的日期写法](http://golehuang.blog.51cto.com/7499/1108124/)

[理解inode](http://www.ruanyifeng.com/blog/2011/12/inode.html)

[linux文件的三个主要的修改时间,和修改时间的touch命令](http://blog.csdn.net/taolinke/article/details/5715971)

## 1. 理论基础

- atime：访问时间（access time），指的是文件最后被读取的时间，可以使用touch命令更改为当前时间;

- ctime：变更时间（change time），指的是文件**本身(自身权限, 名称, 路径等属性)**最后被变更的时间，变更动作包括`chmod`、`chgrp`、`mv`, `gzip`等等(注意: `gzip 文件名`貌似不会创建新文件, 压缩文件实际上替代了原文件, 并且只改变了ctime, 另外两个时间属性与原文件相同);

- mtime：修改时间（modify time），指的是文件**内容**最后被修改的时间，修改动作可以使用`echo`重定向、`vim`等等;

查看一个文件的三种时间属性可以使用`ls`或`stat`命令

```
## 列出文件的 ctime
$ ls -lc 文件名 
## 列出文件的 atime
$ ls -lu 文件名 
##   列出文件的 mtime
$ ls  -l  文件名 
```

```
$ stat ./testA 
  File: `./testA'
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd04h/64772d	Inode: 8594237     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2012-01-01 00:00:38.304903043 +0000
Modify: 2012-01-01 00:00:38.304903043 +0000
Change: 2012-01-01 00:00:38.304903043 +0000
```

## 2. 验证

使用`date`命令修改当前日期, 这样我们就可以自由的设定文件的创建时间与修改时间了. 首先在2012年创建一个文件`testA`, 观察它的三个时间属性.

```shell
$ date 
Sun Jan  1 00:03:14 CST 2012
$ date -s 2012/01/01
Sun Jan  1 00:00:00 CST 2012
$ date
Sun Jan  1 00:00:02 CST 2012
## 现在的系统日期为2012年
## 创建一个新文件, 最初三个时间都是相同的
$ touch testA
$ stat ./testA 
  File: ‘./testA’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: 803h/2051d	Inode: 408869961   Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2012-01-01 00:02:28.635043041 -0800
Modify: 2012-01-01 00:02:28.635043041 -0800
Change: 2012-01-01 00:02:28.635043041 -0800
 Birth: -
```

然后我们跳到2013年, 对其进行一些操作后再次观察. 

```
$  date -s 2013/01/01
Tue Jan  1 00:00:00 PST 2013
## 如果不对`testA`文件进行任何操作的话, 这三个时间是不会变化的
## cat一下它(还是空文件, 所以无输出), 注意到它的atime变了, 而mtime与ctime都没变
$ cat testA
$ stat ./testA 
  File: ‘./testA’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: 803h/2051d	Inode: 408869961   Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2013-01-01 00:01:22.539522919 -0800
Modify: 2012-01-01 00:02:28.635043041 -0800
Change: 2012-01-01 00:02:28.635043041 -0800
 Birth: -

## 然后我们修改它的权限
## 可以看到其ctime被修改, 另外两个也没有改变
$ chmod 777 ./testA 
$ stat ./testA 
  File: ‘./testA’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: 803h/2051d	Inode: 408869961   Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2013-01-01 00:01:22.539522919 -0800
Modify: 2012-01-01 00:02:28.635043041 -0800
Change: 2013-01-01 00:10:09.834080800 -0800
 Birth: -

## 然后再修改它的内容, 原本它是空文件
## 这个操作修改了testA文件的mtime与ctime
## 其中ctime的更新是因为追加内容改变了其元数据中的size属性, 即文件大小
$ echo 'testing' > ./testA 
$ stat ./testA 
  File: ‘./testA’
  Size: 8         	Blocks: 8          IO Block: 4096   regular file
Device: 803h/2051d	Inode: 408869955   Links: 1
Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2013-01-01 00:05:54.555696792 -0800
Modify: 2013-01-01 01:34:57.612833441 -0800
Change: 2013-01-01 01:34:57.612833441 -0800
 Birth: -

```

## 3. 总结与扩展

我们追溯到linux操作系统的存储机制上, 一个文件在操作系统中存在的形式为: `inode`元数据区+内容数据区, 这两者是分开存储的, `inode`中存放的是文件的属性信息如: 数据区大小, 文件所有者, 所属组, 还有就是我们研究的三个时间属性信息, 数据区存放的即是文件内容.

`mv`, `chown`, `chmod`等操作修改的是目标文件的`inode`元数据区, 变化的是文件属性, 这些操作将会更新`change time`; `vim`, `sed`等编辑命令修改的是文件内容, 变化的是文件数据区的内容, 这些操作将会更新文件的`modify time`.

这样看来, `access time`属性的设置动机就够纯粹的了, 就是记录**文件内容**最近一次被访问的时间. 不只是`cat`, `less`也一样. 但是有一个前提是, **必须访问到文件内容, 对文件属性做的修改(比如修改权限)不会更新这个时间**.

------

然后我们推广到目录, 目录说到底也是文件, 因为在linux下目录与文件的存储形式相同, 都是`inode`元数据区+内容数据区.  它们的属性都包括所属用户, 所属组, 目录权限等, 与普通文件不同之处在于, 目录的内容是**其目录项名称与其对应inode号码的对应关系**.

`ls`, `find`命令等相当于读取了目录的**内容**, 所以会修改其`atime`. 在实际实验中, 短时间内多次使用这些命令只有在第一次时更新了该目录的`atime`, 之后的操作则无效. 关于这一点我猜测可以理解为是操作系统的缓存功能, 将最近的操作存放在内存里, 在目录内容未发生变化时, 直接从内存中获取而不是再次读取硬盘信息. 但是当目录中的内容(比如创建了新文件, 重命名了目录项名称等)有更新时, 才会刷新这个`atime`.

其实任何涉及通过目录项名称进行inode转换的操作都会刷新这个时间, 比如重定向一个字符串到一个子文件中`echo 'string' > 父目录/子文件`, 这条命令执行时会通过子文件的文件名找到其对应的inode编号, 相当于访问了父目录的**内容**, 不过由于上述的缓存问题, 并不一定每次执行都会刷新父目录的`atime`.

对目录文件本身执行`mv`, `chmod`等则修改了目录本身的属性, 会更新其`ctime`, 这个就比较好理解了;

而在目录中创建子项, 修改文件名等操作则被视为修改了目录的**内容**, 将会更新此目录的`mtime`, ~~前者还修改了目录文件的大小, 所以创建子项目还会修改目录文件的`ctime`~~. 呃, 修改子目录项的文件名也会更新父目录的`ctime`, 这不合常理啊...

而**修改文件内容, 子目录内容不会对父目录的三个时间属性造成任何影响**.

还值得注意的是, 修改目录项的权限等类似操作, 改变的目录项inode的**内容**, 并没有改变父目录中存储的文件名与inode编号的**对应关系**, 所以不会更新父目录的`mtime`(实际上不会修改父目录的任何一种时间属性).

需要好好体会. 

## 4. touch命令修改文件时间

文件的时间很重要，因为如果误判文件时间，可能会造成某些程序无法正常运行，万一我们发现一个文件的时间是未来的时间（很多时候会有这个问题，我们在安装 的时候提到的GMT时间就是那个意思），那么怎样才能让次时间变成现在的时间呢？我们只需要一个touch命令即可。

touch的用法为：

```
touch [-actmd] 文件
```
参数：

- -a: 仅修改access time

- -m: 仅修改mtime

- -c: 仅修改时间而不建立文件

- -t: 后面可以接时间，格式为：[[CC]YY]MMDDhhmm[.ss]

```
$ stat ./testA/
  File: ‘./testA/’
  Size: 30        	Blocks: 0          IO Block: 4096   directory
Device: 803h/2051d	Inode: 4811681     Links: 2
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2012-01-01 02:12:25.654001441 -0800
Modify: 2012-01-01 02:03:32.058244782 -0800
Change: 2012-01-01 02:03:32.058244782 -0800
 Birth: -
## 修改testA目录的atime为2012年9月1号23点整
$ touch -a -t '201209012300' ./testA/
$ stat ./testA/
  File: ‘./testA/’
  Size: 30        	Blocks: 0          IO Block: 4096   directory
Device: 803h/2051d	Inode: 4811681     Links: 2
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2012-09-01 23:00:00.000000000 -0700
Modify: 2012-01-01 02:03:32.058244782 -0800
Change: 2012-01-01 02:21:45.967925262 -0800
 Birth: -

```

上面的例子中, 指定`-a`选项可以仅更新目标文件的`atime`, 指定`-m`选项可以仅更新目标文件的`mtime`, 如果不指定则同时更新这两者. 不过好像没有办法更新目标文件的`ctime`.

`-c`选项好像是单独用的, 而且不能跟参数, 它将把目标文件的三个时间属性都改成当前时间...

```
$ date
Sun Jan  1 02:32:16 PST 2012
$ touch -c  ./testA/
$ stat ./testA/
  File: ‘./testA/’
  Size: 30        	Blocks: 0          IO Block: 4096   directory
Device: 803h/2051d	Inode: 4811681     Links: 2
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2012-01-01 02:32:23.881794013 -0800
Modify: 2012-01-01 02:32:23.881794013 -0800
Change: 2012-01-01 02:32:23.881794013 -0800
 Birth: -

```
