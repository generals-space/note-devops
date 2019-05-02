# Linux应用技巧-删除乱码文件

许多文件的名称显示为乱码, 无法选中也无法删除, 比如:

```
$ ll
total 20
-rw------- 1 root root 19151    Jul  1      20:22 anaconda-post.log
-rw-r--r-- 1 root root     0        Sep 22    05:48 ÿ3Ҩg[1ϕ??????eҬ
-rw------- 1 root root     0        Jul  1      20:20 yum.log
```

这里提供一个方法.

首先使用`ls`的`-i`选项, 取到目标文件的`inode`编号.

```
$ ls -li
total 20
8388946 -rw------- 1 root root 19151 Jul  1   20:22 anaconda-post.log
8427830 -rw-r--r-- 1 root root         0 Sep 22 05:48 ÿ3Ҩg[1ϕ??????eҬ
8388947 -rw------- 1 root root         0 Jul  1   20:20 yum.log
```

然后通过`find`命令删除它

```
$ ls -li
total 20
8388946 -rw------- 1 root root 19151 Jul  1 20:22 anaconda-post.log
8427830 -rw-r--r-- 1 root root     0 Sep 22   05:48 ÿ3Ҩg[1ϕ??????eҬ
8388947 -rw------- 1 root root     0 Jul  1     20:20 yum.log
$ find -inum 8427830 -delete
$ ls
anaconda-post.log  yum.log
```
