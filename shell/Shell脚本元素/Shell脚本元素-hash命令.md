# Shell脚本元素-hash命令

<!tags!>: <!hash!>

参考文章

[<linux下内置命令和外部命令>](http://www.cnblogs.com/linux-super-meng/p/4155000.html)

[hash命令：显示、添加或清除哈希表](http://www.th7.cn/system/lin/201406/60174.shtml)

## 1. 内置命令和外部命令

bash的命令可以分为内置命令和外部命令：

内置命令(如`read`, `source`等)在系统启动时就调入内存，是常驻内存的，所以执行效率高; 外部命令是系统的软件功能, 是单独的可执行文件(如`/bin/ls`, `bin/ps`等), 执行时才从硬盘中读入内存。

内置命令`enable`可以查看可用的内置命令，同时也可以判断是否为内置命令。

```
$ enable
enable .
enable :
enable [
enable alias
enable bg
...

## cd是bash的内置命令
$ enable cd
$ echo $?
0
## ls是外部命令
$ enable ls
-bash: enable: ls: not a shell builtin
$ 
```

------

执行内置命令时系统调用的速度较快, 执行外部命令时, 系统将会读取环境变量文件`.bash_profile`、`/etc/profile`等去找PATH路径。

## 2. hash的作用

为了提高**外部命令**的执行速度, bash内部维护了一个hash表, 其中存放着外部命令的命令名和与之对应的路径. 这样, 在执行外部命令时, 可以在这个hash表中查询, 而不必再去`PATH`中寻找了, 类似于缓存.

> 注意: 每个终端各自维护自己单独的hash表.

hash表在终端连接初始时为空, 使用`hash`或`hash -l`可以查看其中的内容.

```
$ hash 
hash: hash table empty
$ hash -l
hash: hash table empty
```

hash表不存放内置命令, 只存放外部命令的键值对.

```
$ cd
$ ls
anaconda-ks.cfg  Coding  pyadmin  Swap  Work
## hash命令可以查看命中次数(hits).
$ hash
hits	command
   1	/usr/bin/ls
## hash -l 可以查看命令名与路径的对应关系
$ hash -l
builtin hash -p /usr/bin/ls ls
```

------

`hash -t 命令名` 查看指定命令在hash表中缓存的路径

```
$ hash -l
builtin hash -p /usr/bin/ps aa
builtin hash -p /usr/bin/ps ps
builtin hash -p /usr/bin/ls ls
$ hash -t ls
/usr/bin/ls
$ hash -t aa
/usr/bin/ps
```

`hash -r`可以清空hash表, 重新开始缓存(但不会影响到已经打开的其他终端).

`hash -d 命令名`可以删除指定命令的路径缓存.

```
$ hash -l
builtin hash -p /usr/bin/ps ps
builtin hash -p /usr/bin/man man
builtin hash -p /usr/bin/ls ls
$ hash -d man
$ hash -l
builtin hash -p /usr/bin/ps ps
builtin hash -p /usr/bin/ls ls
```

`hash -p 命令路径 命令名`可以手动指定命令与路径.

如下示例中, 将`aa`写到了hash表里, 执行它相当于执行了`ps`命令(当然, 不可以带参数).

```
$ which ps
/usr/bin/ps
$ hash -p /usr/bin/ps aa
$ aa
   PID TTY          TIME CMD
 49155 pts/1    00:00:00 bash
 52639 pts/1    00:00:00 ps
$ hash -l
builtin hash -p /usr/bin/ps aa
builtin hash -p /usr/bin/ps ps
builtin hash -p /usr/bin/ls ls
```