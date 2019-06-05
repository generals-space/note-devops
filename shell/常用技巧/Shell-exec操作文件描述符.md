# Shell脚本技巧-exec操作文件描述符

<!tags!>: <!shell语法!> <!exec!> <!文件描述符!> <!proc!>

参考文章

[[Shell]文件描述符](http://www.dutor.net/index.php/2010/03/shell-file-descriptor/)

[shell脚本之exec操作文件描述符 + 示例](http://blog.csdn.net/donghanhang/article/details/51005972)

[Linux exec与文件描述符](http://www.cnblogs.com/lizhaoxian/p/5294158.html)

Linux系统中, 每当进程打开一个文件时, 系统就为其分配一个 **唯一**的整型文件描述符, 用来标识这个文件. 大家知道, 在C语言中, **每个进程**默认打开的有三个文件, 标准输入、标准输出、标准错误输出, 分别用一个FILE结构的指针来标示, 即stdin、stdout、stderr, 这三个结构中分别维护着三个文件描述符0、1、2. Shell中, 0、1、2也是默认可用的三个文件描述符. 

## 1. 打开文件描述符

为了利用其他文件描述符来标识特定文件, 我们需要使用`exec`命令打开该文件, 并指定一个数字作为描述符: 

```
## 以"只读方式"打开a.txt, 文件描述符对应为3
$ exec 3<a.txt

## 以"只写方式"打开a.txt, 文件描述符对应为3
$ exec 3>a.txt

## 以"读写方式"打开a.txt, 文件描述符对应为3
$ exec 3<>a.txt
```

关于打开文件描述符的方式, 如果`exec <a.txt`不指定打开文件到哪个描述符, 则默认为替换标准输入; 同理, 如果`exec >a.txt`不指定将哪个描述符输出到文件, 则默认为标准输出. 还是挺容易理解的.

```shell
#!/bin/bash
exec < /tmp/numbers
read vars
echo $vars
```

其中`/tmp/numbers`的内容只有一行`1 2 3 4 5 6`

执行这个脚本, 将不再从控制终端读取, 而是直接从`/tmp/numbers`文件中读取. 呃, 当前, 直接写成`read var < /tmp/numbers`好像更直接一点. 不过, 这其实是打开文件描述符的一种内联写法, 也更为常见一点.

```shell
#!/bin/bash
exec > /tmp/ping_log
ping www.baidu.com &
```

`ping`命令的输出都写到`/tmp/ping_log`中了. 同样, `ping www.baidu.com > /tmp/ping_log`也更为常见...

## 2. 复制文件描述符

符号`<&`可以复制一个输入文件描述符, 符号`>&`可以复制一个输出描述符. 

不过, 与其说**复制**, 不如说是**剪切**更贴切一些. 因为, 剪切之后, 原来的文件描述符就废了...其他语言里使用`dup`函数拷贝了文件描述符后还需要将原来的关掉, shell里就不用, 直接就替换了...

```
## 将描述符m表示的文件绑定到描述符n, 两者应该都是表示输入的文件描述符
$ exec n<&m

## 将描述符n表示的文件绑定到描述符m, 此时, 两者应该都是表示输出的文件描述符
$ exec n>&m
```

> ~~注意: 拷贝文件描述符时, 描述符的输入输出属性不能搞错. 比如, 如果对标准输出的复制使用了`exec 1<&4`, 就会出现如下错误.~~ 好吧错了, 只是因为描述符4不存在而已.

```
脚本名称: line 2: 4: Bad file descriptor
```

## 3. 关闭文件描述符

```
## 关闭输入文件描述符
$ exec n<&-
## 关闭输出文件描述符
$ exec m>&-
```

~~同复制(剪切)描述符一样,~~ 关闭输入输出描述符的方法也是不同的, 不然也会出现`Bad file descriptor`的提示.

## 4. 示例

### 4.1 标准输出重定向示例

```shell
#!/bin/bash

exec 100> /tmp/ping_log

exec 1>&100
## 这里就算不关闭描述符1也不会在控制终端的标准输出打印日志, 奇怪了
exec 1>&-

ping www.baidu.com &
```

`ping`命令的输出都写到`/tmp/ping_log`中了.

### 4.2 读写方式打开文件

`/tmp/numbers`的内容为`1 2 3 4 5 6`, 只有这一行

```shell
#!/bin/bash

exec 4<>/tmp/numbers
cat <&4
## 将本该输出到标准输出的信息写到描述符4表示的文件中
echo 7 8 9 >&4
cat /tmp/numbers
```

执行它, 得到输出

```
1 2 3 4 5 6
1 2 3 4 5 6
7 8 9
```

多次执行会多次在文件尾追加`7 8 9`.

> 这样看来, 以读写方式打开的文件, 写入时应该也是追加类型(>>)了.

## 5. 选择可用的文件描述符

对于高级编程语言, 有`fstat`系统调用可使用, 方法可以见man手册, 这里不详细介绍. 在shell中, 则可以通过查看`/proc/self/fd`来查看当前进程(及子进程)打开的文件描述符, 只要是不出现在这里面的数值, 都可以使用, 当然, 不能超过操作系统的limit限制.

如下是在当前终端获取的描述符信息.()

```
general@ubuntu:/tmp$ ls /proc/self/fd
0  1  2  3
general@ubuntu:/tmp$ exec 4< /tmp/numbers 
general@ubuntu:/tmp$ ls /proc/self/fd
0  1  2  3  4
general@ubuntu:/tmp$ exec 4< /tmp/numbers
general@ubuntu:/tmp$ ll /proc/self/fd
total 0
dr-x------ 2 general general  0 Apr 22 10:11 ./
dr-xr-xr-x 9 general general  0 Apr 22 10:11 ../
lrwx------ 1 general general 64 Apr 22 10:11 0 -> /dev/pts/2
lrwx------ 1 general general 64 Apr 22 10:11 1 -> /dev/pts/2
lrwx------ 1 general general 64 Apr 22 10:11 2 -> /dev/pts/2
lr-x------ 1 general general 64 Apr 22 10:11 3 -> /proc/4654/fd/
lr-x------ 1 general general 64 Apr 22 10:11 4 -> /tmp/numbers
```