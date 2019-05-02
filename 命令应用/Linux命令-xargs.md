# Linux命令-xargs

参考文章

[Xargs用法详解](http://blog.csdn.net/zhangfn2011/article/details/6776925)

[linux find中的-print0和xargs中-0的奥妙](http://www.jb51.net/LINUXjishu/205761.html)

## 1. Xargs简介

之所以能用到这个命令，关键是由于很多命令不支持管道`|`来传递参数，而日常工作中经常需要这个功能，所以就有了`xargs`命令，例如：

```
## 错误
$ find /sbin -perm +700 | ls -l       
## 正确
$ find /sbin -perm +700 | xargs ls -l   
```

`xargs`可以读取标准输入的内容，并且以空白字符或换行符为分隔，将标准输入的内容分隔成为 arguments. 

## 2. 选项设置及示例

### 2.1 

- -0: 当sdtin含有特殊字符时候，将其当成一般字符，像斜线`/`, 单引号`'`, 空格` `等.

因为是以空白字符作为分隔，所以，如果有一些文件名或者是其他意义的名词内含有空白字符的时候, `xargs`可能就会误判了.

```
## 有两个包含空格的文件
$ ll
total 0
-rw-r--r--. 1 root root 0 Jan  6 12:52 hello kitty
-rw-r--r--. 1 root root 0 Jan  6 12:52 hello world
## 不太好压缩
$ ls | xargs gzip
gzip: hello: No such file or directory
gzip: kitty: No such file or directory
gzip: hello: No such file or directory
gzip: world: No such file or directory
## 单纯使用`-0`参数也不太好使
$ ls | xargs -0 gzip
gzip: hello kitty
hello world
: No such file or directory
```

解决方法是, 使用`find`的`-print0`子选项, 配合`xargs`的`-0`子选项.

```
$ find ./ -print0 | xargs -0 gzip
gzip: ./ is a directory -- ignored
$ ls
hello kitty.gz  hello world.gz
```

`-print0`子选项让`find`每找到一个文件, 不再输出换行符, 而是输出NULL, 然后`xargs`的`-0`就可以将文件名中的空格当成普通字符, 又忽略find结果中的换行符的影响...

### 2.2

- -a 文件名: 从文件中读入内容作为输入, 同管道输入没什么区别.

```
$ cat test 
#!/bin/sh
echo "hello world/n"
$ xargs -a test echo
#!/bin/sh echo hello world/n
```

### 2.3

- -i/-I, 不同的linux发行版应该有所不同. 作用是将每个分隔后的参数赋值给`{}`这个特殊变量, 类似于`find`中的`-exec`子命令.

如下示例, 还是很容易理解的.

```
$ ls | xargs -t -i mv {} {}.bak
```

### 2.4

- -d 指定的分隔符. 默认xargs是通过空格来分割传入的参数的, 使用`-d`可以指定任何单字节字符为分隔符, 类似于`awk`的`-F`选项.

```
## echo的-n选项表示不输出末尾的换行符`\n`
$ echo -n '1#2#3#4#5#6' | xargs -d '#' touch
$ ls
1  2  3  4  5  6 
```