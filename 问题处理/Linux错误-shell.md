# Linux 平台错误-shell

## 1. `__vte_prompt_command: command not found`

### 问题表现：

每次登录bash, 而且每次输入命令终端都会有如下输出(命令其实是正常执行的)

```shell
-bash: __vte_prompt_command: command not found
```

### 出现场景:

docker 下启动`CentOS7`原生容器正常, 安装了阿里云的epel源之后关闭容器再次进入容器终端时出现此问题.

### 原因分析:

[参考文章]

[[Bug 248845] New: "\__vte_prompt_command: command not found" on every action in terminal](http://markmail.org/message/2glapefzdi7nwbvt)
[bash: \__vte_prompt_command: command not found](http://stackoverflow.com/questions/22281875/bash-vte-prompt-command-command-not-found)

文中都锁定了`vte`这个程序(`vte`是一个终端软件, 其他几乎所有的终端都是基于`vte`的). `vte`设置bash的环境变量`PROMPT_COMMAND`绑定了它自己的一个叫作`__vte_prompt_command`的函数.

在容器的 `/etc`目录下搜索`PROMPT_COMMAND`与`__vte_prompt_command`字符串, 有如下结果

```shell
...
/etc/bashrc: PROMPT_COMMAND="__vte_prompt_command"
...
```

`PROMPT_COMMAND`这个环境变量定义一个 **每当一条命令执行完毕, 一个提示信息将要显示在屏幕上之前, 就执行某个指定函数** . 注意这句话的定语是函数, 因为它的值就是目标函数的名称. 当这个命令生成了不正常的输出时, 这个环境变量的设置就会让人很反感了...

可以猜测, shell中每执行一条命令都会有提示信息, 虽然大多数很可能是隐藏的, 但每次执行都会调用`PROMPT_COMMAND`所指定的函数.

------

根据参考文章提示, linux下有一个`type`命令, 用以显示bash命令的类型/内容/别名等信息.

在centos7原生docker容器的终端下执行`type __vte_prompt_command` 有如下结果

```shell
[root@localhost Downloads]# type __vte_prompt_command
__vte_prompt_command is a function
__vte_prompt_command ()
{
local command=$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//');
command="${command//;/ }";
local pwd='~';
[ "$PWD" != "$HOME" ] && pwd=${PWD/#$HOME\//\~\/};
printf "\033]777;notify;Command completed;%s\007\033]0;%s@%s:%s\007%s" "${command}" "${USER}" "${HOSTNAME%%.*}" "${pwd}" "$(__vte_osc7)"
}
```

然后安装epel源再次执行

```shell
[root@b129f8c2fa45 ~]# type __vte_prompt_command
-bash: type: __vte_prompt_command: not found
-bash: __vte_prompt_command: command not found
```

...呵呵

### 解决方法

参考文章中的解决办法的确可行, 无论如何, epel源都是要装的.

尝试在终端下定义`__vte_prompt_command`这个函数, 其实是一个空函数...什么事情也没有发生》

```shell
__vte_prompt_command() { true; }
```

再次执行type命令

```shell
[root@460724d0c5e2 /]# type __vte_prompt_command
__vte_prompt_command is a function
__vte_prompt_command ()
{
true
}
```

注意到没有? 现在以前没有之前的错误信息了. 执行其他的命令也一切正常了.

建议还是写到bashrc文件里, 以后就不用在终端里重复定义这个函数了.

## 2. linux 使用退格键时出现^H

[参考文章]

[linux 使用退格键时出现^H解决方法](http://xuqiangqiang.blog.51cto.com/8290140/1336063)

linux 下在终端与脚本进行交互时, 内容输入错误使用`backspace`退格键删除时屏幕上会出现乱码, 如`^[[D^[[C^[[A^[[B^H^[[3~^[OP^[OQ^[OR^[OS^[[15~^[[17~^[[18~^[[19~^[[20~^[[21~^[[23~^[[24~`这样, 其中按下退格键会出现`^H`.

### 解决方法

终端输入`stty erase ^H`, 即可解决. 不过这是暂时的, 下次登录终端还是会出现这个问题, 建议写在`.bash_profile`文件中.

## 4. shell脚本报错

```
    cat  >>... << EOF
        ...
    EOF
```

执行脚本报如下错误

```
./xxx.sh: line 100: warning: here-document at line 72 delimited by end-of-file (wanted `EOF')
./xxx.sh: line 101: syntax error: unexpected end of file
```

解决办法是将第2个`EOF`标记放在行首.

------

同样还是`<< EOF ... EOF`的使用, 脚本如下

```
#!/bin/bash  
whoami  
su - general << ! 
whoami  
exit  
! 
whoami
```

执行时有一个warning如下

```
./sus.sh: line 7: warning: here-document at line 3 delimited by end-of-file (wanted `!')
```

原因是, 第2个`!`前后不能有空格, 当然也不能有其他任何字符.


## 6. scp传输文件夹出错

```
scp: /home/Download/wap: not a regular file
```

问题分析: scp传输目录与单个文件不一样

解决方法: 加上`-r`参数, 即

```
$ scp -r 用户名@IP地址:/home/Download/wap  ./
```