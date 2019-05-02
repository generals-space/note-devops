---
title: Linux-ACL应用
tags: [ACL]
categories: general
---

<!--

# Linux-ACL应用

<!tags!>: <!ACL!>

<!keys!>: jgy%G5mBry2cacfj

-->

参考文章

1. [Linux ACL权限规划：getfacl,setfacl使用](http://www.linuxidc.com/Linux/2013-07/88049.htm)

2. [Linux ACL管理详解](http://linuxguest.blog.51cto.com/195664/124107)

## 1. 简单认识

`ACL`即`Access Control List`, 其主要的目的是提供传统的owner, group, others的read, write, execute权限之外的具体权限设置. ACL可以针对单一用户、单一文件或目录来进行r,w,x的权限控制，对于需要特殊权限的使用状况有一定帮助。如，某一个文件，不让单一的某个用户访问。

举个粟子

生产环境中, 为不同项目建立单独的用户, 并将工程放置在此用户的home目录下, 不同项目之间相互隔离.

现在开发人员需要查看各个项目日志的权限, 可以为其创建公用的log用户. 我们知道, 默认创建用户的home目录是700的权限, log用户不属于任何一个项目的组, 所以通过修改项目的组权限以便让开发人员进入是无法满足的, 而修改home目录的other权限更不是一个好办法. 这时可以通过`ACL`完成目录级别, 指定用户的权限控制.

ACL实现权限控制的命令有3个

- setfacl: 设置文件/目录的ACL配置项

- getfacl: 取得文件/目录的ACL配置项

- chacl: 改变文件/目录的ACL配置项

setfacl规则

- -m: 设置后续acl规则 

- -x: 删除后续acl规则  

- -b: 删除全部的acl规则

- -k: 删除默认的acl规则

- -R: 递归设置acl，包括子目录

- -d: 设置默认acl

`getfacl`就没那么多讲究了, 一般就是`getfacl 目标文件/目录`而已, 想要更高深的用法请查看man手册.

## 2. 设置ACL规则

为完成试验, 我们创建两个普通用户`test`与`log`.

```
$ useradd test
$ useradd log
```

首先来查看`test`(或log)用户的home目录的默认权限.

```
[root@localhost home]# ll
total 4
drwx------.  3 log     log       74 Jan 10 23:07 log
drwx------.  3 test    test      74 Jan 10 23:07 test
[root@localhost home]# getfacl log
# file: log
# owner: log
# group: log
user::rwx
group::---
other::---
```

我们想要让log用户能够访问`test`用户的home目录, 可以执行如下命令, 为其添加ACL控制.

```
[root@localhost home]# ls
log  test
[root@localhost home]$ setfacl -m user:log:rx ./test
[root@localhost home]$ getfacl ./test
# file: test
# owner: test
# group: test
user::rwx
user:log:r-x
group::---
mask::r-x
other::---

[root@localhost home]# su - log
[log@localhost ~]$ cd ..
[log@localhost home]$ ls
log  test
[log@localhost home]$ cd test
[log@localhost test]$ ll
total 0
-rw-rw-r--. 1 test test 0 Jan 11 22:24 testfile
```

需要记住的就是`setfacl`中`-m`选项后面的ACL规则格式. `-m 指定ACL`选项表示修改为指定ACL(不是添加也不是减少哦), 如果你再执行`setfacl -m user:log:x ./test`, 那log用户就只能进入test目录但不能读也不能写了...

```
[root@localhost home]# setfacl -m user:log:x ./test
[root@localhost home]# su - log
Last login: Wed Jan 11 22:24:06 CST 2017 on pts/1
[log@localhost ~]$ cd ..
[log@localhost home]$ ls
log  test
[log@localhost home]$ cd test/
[log@localhost test]$ ls
ls: cannot open directory .: Permission denied

```

> 不只`root`用户可以配置ACL, 文件/目录的属主也可以对其进行配置.

------

现在我们还希望`log`用户可以对`test`用户目录下的文件进行修改, 创建等操作, 这就需要为`test`用户目录及其下面的文件赋予`w`权限, 可以使用`-R`选项对目标目录进行递归操作.

```
## 注意: -m选项需要在-R选项之后, 确切地说是-m选项必须与将要定义的ACL规则相邻
[root@localhost home]# setfacl -Rm user:log:rx ./test
```

当然, 用这种方式可以为指定文件/目录设置多个用户的ACL权限, 它们之间不会相互影响.

```
[root@localhost home]# setfacl -Rm user:general:rwx ./test
[root@localhost home]# getfacl ./test
# file: test
# owner: test
# group: test
user::rwx
user:general:rwx
user:log:rwx
group::---
mask::rwx
other::---

```

> 有一种情况需要注意, 如果为`test`用户主目录赋予`rx`权限(非递归操作), 而`test`目录下存在`777`权限的文件(但是没有为其设置对`log`用户的ACL规则), 假设为上述的`testfile`文件, 则`log`用户进入`test`目录, 并对`testfile`文件写入并保存, 则有可能会将这个文件的属主修改为`log`.<???>

<!--

> ~~在线上暗黑遗迹的php文件的确是出现了这种情况, 但是试验时没有重现出来~~

-->

## 3. 删除ACL规则

`setfacl`的`-x`选项可以删除指定的ACL规则, `-b`选项直接清除所有的ACL规则.

`-x`选项的参数格式为`user:log`这种, 后面没有`rwx`这种具体权限. 如下

```
[root@localhost home]# getfacl ./test/
# file: test/
# owner: test
# group: test
user::rwx
user:log:r-x
group::---
mask::r-x
other::---

[root@localhost home]# setfacl -x user:log ./test
[root@localhost home]# getfacl ./test
# file: test
# owner: test
# group: test
user::rwx
group::---
mask::---
other::---

```

`-b`选项就简单了, 直接`setfacl -b ./test`就行了, 必要的时候加上`-R`.