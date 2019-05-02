# VNC server搭建

参考文章

1. [怎样在 CentOS 7.0 上安装和配置 VNC 服务器](http://www.linuxidc.com/Linux/2015-04/116725.htm)

2. [CentOS 中 YUM 安装桌面环境](http://cnzhx.net/blog/centos-yum-install-desktop/)

3. [（总结）CentOS Linux下VNC Server远程桌面配置详解](http://www.ha97.com/4634.html)

## 1. 图形桌面

首先安装桌面环境, 这个话题参考文章2中讲解的十分清楚, 值得一看.

我们经常见到连接vnc后显示如下窗口, 一般都是因为图形桌面没装.

![](https://gitee.com/generals-space/gitimg/raw/master/41e358070baf3597e9304c4ab6fc496e.png)

安装方法

centos 6

```
$ yum groupinstall -y "X Window System" "Desktop Platform" Desktop
```

centos 7

```
$ yum groupinstall -y "GNOME Desktop"
```

> 参考文章2中说到需要将服务器设置为从图形界面启动, 但是实际实验时发现这一步不是必需的, 从字符界面依然可以启动vnc. 当然, 直连显示器的情况下自然要设置为图形界面启动, 但vnc和那种情况不一样.

## 2. 启动VNC

```
$ yum install -y  tigervnc-server
```

在启动VNC之前, 需要创建vnc连接的密码, 使用客户端连接时需要这个密码.

但这个密码不同于系统用户的密码, 使用客户端连接上VNC后会出现系统的登录界面, 那里才是输入系统用户密码的地方.

密码设置的方式为

```
$ vncpasswd
Password:
Verify:
```

这个操作会在当前用户的`~/.vnc`目录下生成一个`passwd`文件, 它是经过加密的.

如果不设置密码, 那么在命令行启动`vncserver`时会提示设置, 但如果是通过系统服务启动的话就会失败.

然后启动vnc server.

### 2.１. 命令行启动

```
$ vncserver :1
New '服务器IP:1 (启动用户)' desktop is 服务器IP:1
```

如果是首次执行这个操作, 会在用户家目录下创建`.vnc`目录, 其中vnc server实例的日志和pid都在这里, 还有配置文件什么的. 

这个`:1`没有什么特殊的地方, 你可以把它当作**一个vnc server实例的别名**, 一般来说, `:n`就表示其端口为`590n`. 在执行`vncserver`时不显式指定`:n`的话它会自动创建一个合适的.

`vncserver`可以由任意用户启动, 一个用户也可以启动多个vnc server, 配置文件默认就在其用户home目录下的`.vnc`下.

连接上哪一个vnc实例, 就会看到对应用户的登录界面, 登录后获得该用户的会话及相应权限.

> VNC本身不推荐用root启动

### 2.2 系统服务-service命令

除了手动在命令行启动, 一般yum安装的服务都可以通过启动脚本和配置文件完成服务的启动.

查看vncserver对应的启动脚本, centos6下在`/etc/init.d/vncserver`, 其中写了其配置文件在`/etc/sysconfig/vncservers`.

```
# The VNCSERVERS variable is a list of display:user pairs.
...
# VNCSERVERS="2:myusername"
# VNCSERVERARGS[2]="-geometry 800x600 -nolisten tcp -localhost"
```

可以看到, 这个配置文件中设置了实例与用户的对应列表, 通过这个配置文件可以同时设置多个vnc实例, 并且它们之间的配置各自独立.

尝试写入如下配置, 其中`skytest`是一个普通用户, 记得事先创建. 

```
VNCSERVERS="1:skytest"
VNCSERVERARGS[1]="-geometry 1920x1080 -depth 24"
```

现在可以启动vnc服务了.

这种启动方式的好处是同时启动多个vnc实例, 且它们的配置不会相互影响, 但是断开的话还是需要手动断开的, 不然服务停止后所有的示例都将被停掉.

### 2.3 系统服务 - systemctl

~~这个方法我没搞成功, 通过systemctl启动的vnc server, 连接上后背景是黑的, 还没有标题栏...如下~~

~~![](https://gitee.com/generals-space/gitimg/raw/master/fc7dba6a462af812957e9523f1b6f36b.png)~~

首先拷贝服务脚本, 注意这只是模板, 内容需要自己修改. 它其实对应centos6的`/etc/sysconfig/vncservers`配置文件.

```
$ cp /lib/systemd/system/vncserver@.service /usr/lib/systemd/system/vncserver@:1.service
```

把文件中的`<USER>`字段修改成可以通过VNC登录的普通用户名, 该用户需要事先存在于系统中(当然, root也是可以的, 要注意pid文件的路径)

注意, 服务脚本文件名中的`@:1`是必须的. 因为脚本内容中有如下代码

```
ExecStart=/usr/bin/vncserver %i
PIDFile=/root/.vnc/%H%i.pid
ExecStop=-/usr/bin/vncserver -kill %i
```

其中`%H`与`%i`是systemd的内置变量, 前者表示本机`hostname`值, 后者是`systemctl`的内置变量, 表示服务实例的`@`与`.service`后缀之前的值, 正好是`:1`.

然后启动服务.

```
$ systemctl daemon-reload
systemctl enable vncserver@:1.service
systemctl start vncserver@:1.service
```

与centos6中的启动文件相比, 各个实例的配置是分开的, 不再是同时启动多个实例的服务了, 这相当于命令行操作的简化版本. 当然, 分开管理各有好处.

## 3. 基本操作

### 3. 查看/结束进程

`-list`选项可以查看当前用户启动的vnc实例, 通过命令行启动的vnc这个命令十分有用.

```
$ vncserver -list

TigerVNC server sessions:

X DISPLAY #	PROCESS ID
:1		23440
:2		27121
```

`-kill`可以停止目标实例, 如

```
$ vncserver -kill :1
Killing Xvnc process ID 23440
```

### 3.2 关于`xstartup`

关于`xstartup`文件, `vncserver`命令可以通过`-xstartup 文件路径`指定这个文件的路径, 我这边实验的时候没看出加不加这些东西有什么区别. 

这里保留一下, 可以在VNC显示鼠标为黑色叉号时修改一下作为参考.

```
[root@localhost .vnc]# cat xstartup 
#!/bin/sh

# Uncomment the following two lines for normal desktop:
unset SESSION_MANAGER
exec /etc/X11/xinit/xinitrc

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
gnome-session &
#startkde &
```

这里的`gnome-session &`我觉得的是在装多个桌面环境时要加的

### 3.3 分辨率/DPI设置

参考文章3中有详细解释.

最简单的一种

```
$ vncserver :1 -geometry 1920x1080 -depth 24
```

这种需要在实例启动时指定, 也可以写在`/etc/sysconfig/vncserver`中.