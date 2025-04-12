# VNC server搭建

参考文章

1. [怎样在 CentOS 7.0 上安装和配置 VNC 服务器](http://www.linuxidc.com/Linux/2015-04/116725.htm)
2. [CentOS 中 YUM 安装桌面环境](http://cnzhx.net/blog/centos-yum-install-desktop/)
3. [（总结）CentOS Linux下VNC Server远程桌面配置详解](http://www.ha97.com/4634.html)

## 1. 查看/结束进程

`-list`选项可以查看当前用户启动的vnc实例, 通过命令行启动的vnc这个命令十分有用.

```log
$ vncserver -list

TigerVNC server sessions:

X DISPLAY #	PROCESS ID
:1		23440
:2		27121
```

`-kill`可以停止目标实例, 如

```log
$ vncserver -kill :1
Killing Xvnc process ID 23440
```

## 2. 关于`xstartup`

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

## 3. 分辨率/DPI设置

参考文章3中有详细解释.

最简单的一种

```
vncserver :1 -geometry 1920x1080 -depth 24
```

这种需要在实例启动时指定, 也可以写在`/etc/sysconfig/vncserver`中.

## 4. 指定端口

`vncserver --help`中一般不会有直接方式指定端口, 比如

```bash
root@e32a946a4618:~/.vnc# vncserver --help
VNC4 server

Usage: vncserver [<OPTIONS>] [:<DISPLAY#>]
       vncserver -kill :<DISPLAY#>

<OPTIONS> are Xvnc4 options, or:

        -name <DESKTOP-NAME>
        -depth <DEPTH>
        -geometry <WIDTH>x<HEIGHT>
        -httpport number
        -basehttpport number
        -alwaysshared
        -nevershared
        -pixelformat rgb<NNN>
        -pixelformat bgr<NNN>
        <Xvnc4-options>...

See vnc4server and Xvnc4 manual pages for more information.
```

端口参数在`<Xvnc4-options>`中, 可以使用`Xvnc4 --help`查看.

```
vnc4server :1 --rfbport=8000
```

