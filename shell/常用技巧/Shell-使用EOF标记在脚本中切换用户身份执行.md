# Shell脚本技巧-在脚本中切换用户身份执行

参考文章

[Shell脚本中实现切换用户并执行命令操作](http://www.jb51.net/article/59255.htm)

脚本内部实现切换用户并执行命令操作

## 1. 情景重现

首先来看一下, 不使用任何特殊方法时, 在shell脚本中进行用户切换并执行命令的情况.

```shell
#!/bin/bash

whoami
su - general
whoami
exit
whoami
```

命名为`test1.sh`, 使用root执行.

```
[root@localhost tmp]# ./test1.sh
root
Last login: Sun Nov  6 17:41:10 PST 2016
[general@localhost ~]$ exit
logout
root
[root@localhost tmp]# 
```

执行`test1.sh`, 到`su - general`这一句后会陷入新的shell中, 并脱离原来执行脚本时的shell, 脚本进程被挂起. 在这个shell中执行任何命令都不会影响原来的脚本执行...

**手动执行`exit`**后回到原来的shell, 脚本继续执行. 但是注意, 这里输出的是'root', 说明`exit`命令结束的是`su - general`这条命令, 之后继续执行的代码已经回到原来的shell, 我们使用`su`命令切换用户身份执行命令的目的并没有实现.

脚本中的`exit`直接使脚本退出了, 所以不会看到第3个`whoami`的输出.

------

如果再加上使用类似python中的`virtualenv`包的效果, 这种子shell嵌套就变的更多, 更复杂了.

```shell
#!/bin/bash

whoami
su - general
whoami
source /home/general/virpython/bin/activate
## 在服务器上以general身份, 在virtualenv环境下安装了django, 用以验证是否曾经执行到这一句
pip freeze | grep -i django
exit
whoami
```

将上面的脚本保存为`test2.sh`, 以root身份执行, 结果如下

```
[root@b14e517d408b tmp]# pip freeze | grep -i django
[root@b14e517d408b tmp]# ./test2.sh 
root
[general@b14e517d408b ~]$ exit
logout
root
Django==1.8
[root@b14e517d408b tmp]# 
```

我们看到, 在root下直接执行`pip freeze`是没有输出的, 即root下没有安装django包. 而输出了第2个`whoami`后理论上流程已经回到原shell, 当前用户是root, 但却输出了'Django==1.8'.

原因是, 用root身份执行`source /home/general/virpython/bin/activate`, 也可以查询到该虚拟python环境下的包, 这是没有问题的. 但是, 如果在这样的脚本中执行`pip install`命令, 安装第三方包, 到时general用户就没法卸载了, 因为没有权限. 所以并不是一个好的做法.

------

## 2. 正确实现方法

```shell
#!/bin/bash

whoami
su - general << EOF
pwd
whoami
EOF
whoami
```

```
[root@b14e517d408b tmp]# ./test3.sh 
root
/home/general
general
root
```

切换用户只执行一条命令的可以用`su - 用户名 -c 命令(可用引号包裹)`

切换用户执行一个shell文件可以用: `su - oracle -s /bin/bash 脚本路径`

## 1.3 扩展

尝试执行如下代码

```
#!/bin/bash

whoami
su - general << EOF
whoami
echo 'i am' $(whoami)
pwd
echo 'i am in' $(pwd)
EOF
whoami
```

结果如下

```
root
general
i am root
/home/general
i am in /tmp
root
```

第2个`whoami`与第3个的输入虽然都是在`su - general`后执行的但结果却不同. 使用bash的`-x`选项查看执行过程.

```
$ bash -x ./sus.sh 
+ whoami
root
+ su - general
++ whoami
++ pwd
Last login: Mon Nov  7 00:25:12 PST 2016
general
i am root
/home/general
i am in /tmp
+ whoami
root
```

可以看到, 以`++`开头的行, 虽然在`su - general`后执行, 但却在显示在'Last login: ...'的登录信息之前. 即**这些内联命令都是在原来shell下执行的, 也不能通过对变量赋值取出这些值(在`su`之后执行`var_pwd=$(pwd)`得到的依然是原shell中的值), 目前没有好的解决办法**.

------

## 1.4 更新, 2016-12-03

根据另一篇对`EOF`标记深究的分析文章, 1.3节提到的问题也有了解决办法. 

为了保证在`su`切换用户后执行的命令是在新的shell中, 可以使用以下两种方法

1. 执行的命令前使用反斜线`\`转义

2. 第一个EOF使用`<< 'EOF'`表示

第一种方法的示例

```
#!/bin/bash

whoami
su - general << EOF
whoami
echo 'i am' \$(whoami)
pwd
echo 'i am in' \$(pwd)
EOF
whoami
```

第二种方法的示例

```
#!/bin/bash

whoami
su - general << 'EOF'
whoami
echo 'i am' $(whoami)
pwd
echo 'i am in' $(pwd)
EOF
whoami
```