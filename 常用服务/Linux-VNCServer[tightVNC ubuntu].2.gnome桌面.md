# Linux-VNCServer[tightVNC ubuntu].2.gnome桌面

参考文章

1. [novnc安装与使用](https://blog.csdn.net/chao_beyond/article/details/24922397)
    - 两种VNC server: `tightvncserver`与`x11vnc`
2. [linux环境下部署noVNC服务](https://www.jianshu.com/p/1a4fd2774c35)
    - `apt-get install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal`
3. [Ubuntu安装桌面环境](https://www.cnblogs.com/fanqisoft/p/8671166.html)
    - `apt-get install ubuntu-desktop`
4. [给docker中的ubuntu系统安装桌面程序](https://blog.csdn.net/zhang14916/article/details/107593330)
    - `apt-get install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils`
5. [400 Client must support 'binary' or 'base64' protocol](https://github.com/novnc/noVNC/issues/1276)
    - `$novnc/core/websock.js`
    - 由`this._websocket = new WebSocket(uri, protocols);`
    - 改为`this._websocket = new WebSocket(uri, ['binary', 'base64']); //protocols);`
    - 实践有效.
6. [ubuntu使用VNC运行基于docker的桌面系统](https://floodshao.github.io/2020/03/14/docker%E4%B8%8B%E4%BD%BF%E7%94%A8vnc%E5%88%9B%E5%BB%BA%E7%9B%B8%E5%BA%94%E7%89%88%E6%9C%AC%E7%9A%84ubuntu%E6%A1%8C%E9%9D%A2%E7%B3%BB%E7%BB%9F/)
    - 原生的gnome桌面基本带不动vnc, 所以使用其他桌面
7. [VNC远程连接灰屏无法显示gnome桌面](https://blog.csdn.net/chengxi666/article/details/104507720/)
8. [VNC远程桌面连接Ubuntu16.04及灰屏、仅桌面背景无图标问题解决方案](https://blog.csdn.net/zsfcg/article/details/86656084)

ubuntu: 18.04.4 LTS (Bionic Beaver)

在上一篇文章使用`xfce4`桌面, 默认的`/root/.vnc/xstartup`配置即可生效, 如下

```bash
#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession

```

> 解开`x-window-manager &`的注释, 并且在下面追加`xfce4-session &`, 应该也可行, 尤其是在多桌面环境的时候.

我更习惯 gnome 桌面, 使用如下命令安装

```
apt-get install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal
```

为了能使 vnc server 加载 gnome 桌面, 需要修改`xstartup`文件内容如下

```bash
#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work

export XDG_SESSION_TYPE=x11
## 不明白下面这两句有什么区别, 不过都能用.
## exec dbus-launch gnome-session &
gnome-session &
vncconfig -iconic &
gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
gnome-terminal &
```
