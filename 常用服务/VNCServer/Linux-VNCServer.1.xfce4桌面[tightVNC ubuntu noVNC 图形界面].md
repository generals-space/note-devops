# Linux-VNCServer[tigerVNC ubuntu].1

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

ubuntu: 18.04.4 LTS (Bionic Beaver)

## 1. 图形桌面

必须先安装桌面环境, 否则直接安装 VNC server 与 noVNC 后, 在访问 noVNC 时, 会出现如下错误.

![](https://gitee.com/generals-space/gitimg/raw/master/cb94cebf552e347d009d5c6134608121.png)

1. `apt-get install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils`(XFCE桌面, 291 MB)
2. `apt-get install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal`(511 MB)
3. `apt-get install ubuntu-desktop`: (2,004 MB)

> 如果先安装并启动了 VNC server 与 noVNC, 再安装桌面环境, 则需要重启 VNC server 进程.

本文安装第1种.

## 2. 安装启动VNC

参考文章1提到了两种 VNC server, `tightvncserver`与`x11vnc`, 这里只选`tightvncserver`.

```
apt-get -y install tightvncserver
```

在启动VNC之前, 需要创建vnc连接的密码, 使用客户端连接时需要这个密码.

但这个密码不同于系统用户的密码, 使用客户端连接上VNC后会出现系统的登录界面, 那里才是输入系统用户密码的地方.

密码设置的方式为

```log
$ vncpasswd
Using password file /root/.vnc/passwd
Password:
Verify:
```

这个操作会在当前用户的`~/.vnc`目录下生成一个`passwd`文件, 它是经过加密的.

如果不设置密码, 那么在命令行启动`vncserver`时会提示设置, 但如果是通过系统服务启动的话就会失败.

然后启动vnc server.

### 命令行启动

```log
$ vncserver :1
$ ps -ef | grep auth
root      1197     1  0 21:11 pts/0    00:00:00 Xtightvnc :1 -desktop X -auth /root/.Xauthority -geometry 1024x768 -depth 24 -rfbwait 120000 -rfbauth /root/.vnc/passwd -rfbport 5901 -fp /usr/share/fonts/X11/misc/,/usr/share/fonts/X11/Type1/,/usr/share/fonts/X11/75dpi/,/usr/share/fonts/X11/100dpi/ -co /etc/X11/rgb
```

## 3. 安装启动 noVNC

`noVNC`无法通过 apt/yum 源安装, 只能通过源码启动.

```
./utils/launch.sh --vnc localhost:5901 --listen xxxx
```

之后可以访问本地的`xxxx`端口.

## FAQ

### 1. code 400, message Client must support 'binary' or 'base64' protocol

访问本地 noVNC 服务时, 出现如下错误

![](https://gitee.com/generals-space/gitimg/raw/master/057369ecb6b4af897c33912ab628c187.png)

查看服务端日志如下

```log
root@383656098b9e:/usr/local/noVNC# ./utils/launch.sh --vnc localhost:5901 --listen 5037
Warning: could not find self.pem
Using installed websockify at /usr/bin/websockify
Starting webserver and WebSockets proxy on port 5037
WebSocket server settings:
  - Listen on :5037
  - Flash security policy server
  - Web server. Web root: /usr/local/noVNC
  - No SSL/TLS support (no cert file)
  - proxying from :5037 to localhost:5901


Navigate to this URL:

    http://383656098b9e:5037/vnc.html?host=383656098b9e&port=5037

Press Ctrl-C to exit

192.168.99.1 - - [31/Jan/2021 23:24:59] code 400, message Client must support 'binary' or 'base64' protocol
192.168.99.1 - - [31/Jan/2021 23:24:59] code 404, message File not found
handler exception: [Errno 32] Broken pipe
```

按照参考文章5, 需要修改`$novnc/core/websock.js`文件, 将其中的`this._websocket = new WebSocket(uri, protocols);`修改为`this._websocket = new WebSocket(uri, ['binary', 'base64']);`.

再启动即可解决.
