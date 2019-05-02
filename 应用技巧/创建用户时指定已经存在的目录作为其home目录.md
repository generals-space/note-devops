# 创建用户时指定已经存在的目录作为其home目录

创建用户时, 使用`-d`选项为其指定一个已经存在的目录作为home目录而不是自动创建. 但是要知道, 用户home目录的属主是其本身而且权限一般是700. 所以使用`root`执行这样的操作时, 该用户不存在并且就算创建了, 也不见得该用户拥有此目录的读写权限, 因而可能会报如下错误

```
[root@localhost ~]# mkdir /home/general
[root@localhost ~]# useradd -d /home/general general
adduser: warning: the home directory already exists.
Not copying any file from skel directory into it.
```

但是此时`general`已经被创建了, 并且在`/etc/passwd`文件中其home目录的确也已经指定到`/home/general`中, 但是使用`su`且换为`general`用户时, 命令提示符会呈现一个很原始的状态

```
[root@localhost ~]# cat /etc/passwd | grep general
general:x:1001:1001::/home/general:/bin/bash
[root@localhost ~]# su - general
-bash-4.3$
```

这是因为, 创建新用户的操作, 除了在`/etc/passwd`中添加一行外, 还要从`/etc/skel`目录下拷贝`.bashrc`等模板文件到用户home目录. 指定已经存在的目录作为新建用户的home目录时, 没有拷贝这些模板文件.

所以我们要做的是, 将此home目录的属主该为目标用户, 并修改其权限为`700`, 然后拷贝`/etc/skel`下的模板文件到home目录.

```
[root@localhost ~]# cp /etc/skel/* /home/general
[root@localhost ~]# chown -R general:general /home/general
[root@localhost ~]# chmod 700 /home/general
[root@localhost ~]# su - general
[general@localhost ~]$
```
