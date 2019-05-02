# 为普通用户添加sudo权限

<!tags!>: <!sudo!> <!sudoers!>

参考文章

[linux中sudo的用法和sudoers配置详解](http://www.bianceng.cn/OS/Linux/201410/45603.htm)

[linux下sudoers设置方法详解](http://www.ahlinux.com/start/cmd/457.html)

[Linux 下以其他用户身份运行程序—— su、sudo、runuser](http://www.cnblogs.com/bodhitree/p/6018369.html)

本文主要讲解如何通过配置`/etc/sudoers`文件, 让普通用户拥有部分root权限, 甚至拥有其他普通用户权限的方法.

`/etc/sudoers`文件中存在如下行, 定义了root用户有权限以任何用户的身份执行主机上的所有命令, 这个文件由`sudo`工具提供, 大多数linux发行版中都默认安装.

```
root    ALL=(ALL)       ALL
```

> 注意: `sudo`工具提供了一个`visudo`命令对`/etc/sudoers`文件进行编辑, 与vim直接编辑不同的是, visudo在保存退出可以检测文件是否存在语法错误, 如果有错误, 会放弃保存. 使用方法是, 直接运行`visudo`即可.

## 1. 赋予普通用户sudo权限

如果一个用户知道`root`用户的密码, 就可以使用`sudo 命令`以root身份执行, 但如果我们不想这个用户拥有root密码, 并且想要其可以拥有`root`用户的全部权限, 可以在这个文件中添加这样一行

```
general    ALL=(ALL)       ALL
```

这样, 普通用户`general`就拥有了`sudo su -`切换成`root`用户的能力, 并且可以使用`sudo 命令`执行系统上所有命令, 并且只需要输入`general`用户本身的密码即可.

比如, 普通用户(general)本来没有权限为系统新增/删除用户, 如下

```
[general@localhost ~]$ useradd test1
-bash: /usr/sbin/useradd: Permission denied
```

在`/etc/sudoers`文件中添加了上面的一行后, 可以使用`sudo`命令执行`useradd`命令, 而且只需要输入general自己的密码就可以.

```
[general@localhost ~]$ sudo useradd test1
[sudo] password for general: 
[general@localhost ~]$ tail -n 1 /etc/passwd
test1:x:1005:1005::/home/test1:/bin/bash
```

如果希望该用户可以连本身的密码都不用询问, 可以这样写

```
general    ALL=(ALL)       NOPASSWD:ALL
```

------

需要注意的是, 这种方法做让普通用户general有权限执行系统中的任意命令, 包括`su`. 这样, 普通用户就可以通过`sudo su -`直接切换成root管理系统. 

```
general@localhost$ su
Password: 
su: incorrect password
general@localhost$ sudo su -
[sudo] password for general: 
[root@localhost ~]# 
```

这种情况可能不是我们希望看见的, 所以需要对赋予普通用户的命令进行限制.

## 2. 限制普通用户的部分root权限

如果我们希望普通用户general只能执行部分root命令, 不想让他直接切换成root管理系统, 我们可以在`/etc/sudoers`文件为其显式指定可以执行的命令列表.

先分析一下之前那一行配置的格式

```
general    ALL=(ALL)       ALL
```

- general: 表示被授权的用户, 如果是为`/etc/group`文件中存在的组进行授权, 使用`%组名`

- 第一个ALL: 表示所有来源(从任何主机连接进来)

- 第二个ALL: 表示所有用户

- 第三个ALL: 表示所有命令

我们为general添加`useradd`, `userdel`权限, 这样其将拥有权限执行这两条命令, 但无法再使用`sudo su`切换成root了.

```conf
general ALL=(root) /usr/sbin/useradd,/usr/sbin/userdel
```

同样也可以为general使用`NOPASSWD`标记实现免密码执行.

注意: **命令列表要使用绝对路径**, 否则会报如下错误.

```
sudo useradd test2
sudo: >>> /etc/sudoers: syntax error near line 92 <<<
sudo: parse error in /etc/sudoers near line 92
sudo: no valid sudoers sources found, quitting
```

同样, 实际执行时也需要为绝对路径, 即在`/etc/sudoers`中写的路径要与实际执行路径相同, 不然依然会有权限问题.

## 3. 赋予普通用户以其他普通的权限.

假如我想让general拥有以`test1`用户执行`ping`命令的权限... 当然这个想法很无聊, 实际应用中则是希望让开发人员使用log用户就可以重启线上的任意服务, 而这些服务都是以不同的普通用户启动的. 

> 当前也可以写成`ALL=(ALL)`, 小括号内的ALL表示可以以任何用户身份执行命令.

```conf
general ALL=(test1) NOPASSWD:/bin/ping
```

你应该这么用(`sudo`的`-u`选项表示选择以哪一个用户身份执行命令.)

```
[general@localhost ~]$ sudo -u test1 /bin/ping www.baidu.com
```


然后查询系统中的ping进程, 可以得到

```
[root@localhost ~]# ps -ef | grep ping
root      70939  70014  0 21:10 pts/1    00:00:00 sudo -u test1 /bin/ping www.baidu.com
test1     70940  70939  0 21:10 pts/1    00:00:00 /bin/ping www.baidu.com
root      70950  69866  0 21:10 pts/6    00:00:00 grep --color=auto ping
```

这里可以看到, 有两个`ping`, 虽然是在general用户下执行的, 但`sudo -u test1...`的执行用户是`root`, 下面的`/bin/ping...`的执行用户是`test1`. 所以, 使用log重启业务进程的想法应该是可行的.

## 4. 批量授权

如果待授权用户很多且不在同一用户组, 或者指定的命令太多, 这样sudo规则书写起来会很麻烦. 我们可以使用`sudoers`文件中提供的`XXX_Alias`系列命令指定一组变量, 可以是一组用户, 一组权限, 或一组命令等.

Alias使用方法如下

```conf
User_Alias 变量名=变量值
Runas_Alias 变量名=变量值
Host_Alias 变量名=变量值
Cmnd_Alias 变量名=变量值
```

变量名必须要以大写字母开头，而且只能包含有大写字母，数字，下划线.

而变量值是以逗号','分隔的数组，不过这四个别名表示的数组内容都会不同.

比如想要赋予普通用户general以网络配置相关的root级别命令, 可以添加如下行

```conf
Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/iwconfig, /sbin/mii-tool
```

然后使用上面讲到的, 将`NETWORKING`字段添加给general用户

```
general ALL=(root) NETWORKING
```

这样, general就可以拥有root级别的, 执行`NETWORKING`定义的包括`route`, `ifconfig`...等一系列网络相关的命令, 是不是很方便?

------

然后我们看一下这四种类型的字段, 变量值可以取哪些值

```
User：[!][username | #uid | %groupname | +netgroup | %:nonunix_group | User_Alias]
Runas：[!][username| #uid | %groupname | +netgroup | Runas_Alias]
Host：[!][hostname | ip_addr | network(/netmask)? |  netgroup | Host_Alias]
Cmnd：[!][commandname| directory | "sudoedit" | Cmnd_Alias]
```

感叹号`!`表示取反, 比如不包括指定主机, 不包括指定用户, 禁止执行的命令等.

### 5.4 通配符(未验证)

通配符只可以用在`主机名`、`文件路径`、`命令行的参数列表`中。下面是可用的通配符：

- *：匹配任意数量的字符

- ?：匹配一个任意字符

- [...]：匹配在范围内的一个字符

- [!...]：匹配不在范围内的一个字符

- \x：用于转义特殊字符

在使用通配符时有以下的注意点：

1. 使用[:alpha:]等通配符时，要转义冒号':'，如：[\:alpha\:]

2. 当通配符用于文件路径时，不能跨'/'匹配，如：/usr/bin/*能匹配/usr/bin/who但不能匹配/usr/bin/X11/xterm

3. 如果指令的参数列表是""时，匹配不包含任何参数的指令。

4. ALL这个关键字表示匹配所有情况。

### 5.5 更深层的用户规则(未验证)

用户规则定义的语法如下：

```conf
User_List Host_List=(Runas_List1:Runas_List2) SELinux_Spec Tag_Spec Cmnd_List,...
```

下面对上面的语法进行说明一下：

- `User_List`（必填项）：指的是该规则是针对哪些用户的。

- `Host_List`（必填项）：指的是该规则针对来自哪些主机的用户。

- `Runas_List1`（可选项）：表示可以用sudo -u来切换的用户

- `Runas_List2`（可选项）：表示可以用sudo -g来切换的用户组

- `SELinux_Spec`（可选项）：表示SELinux相关的选项，可选值为ROLE=role 或 TYPE=type。本人对SELinux不太熟，以后再补充这里吧。

- `Tag_Spec`（可选项）：用于控制后面Cmnd_List的一些选项啦，可选值有下面这些，具体可以查阅man手册

```
'NOPASSWD:' | 'PASSWD:' | 'NOEXEC:' | 'EXEC:' | 'SETENV:' | 'NOSETENV:' | 'LOG_INPUT:' | 'NOLOG_INPUT:' | 'LOG_OUTPUT:' | 'NOLOG_OUTPUT:'
```

- `...`（可选项）：表示可以有多个(`Runas_List1`:`Runas_List2`) `SELinux_Spec` `Tag_Spec` `Cmnd_List`段的意思。

注意：如果`Runas_List1`和`Runas_List2`都没填的话，默认是以root用户执行
