# Linux-VNCServer[tightVNC ubuntu].3.extension "RANDR" missing on display[vnc4server]

参考文章

1. [Xlib extension “RANDR” missing on display “:1”](https://stackoverflow.com/questions/21871568/xlib-extension-randr-missing-on-display-99)
    - 建议使用`vnc4server`
2. [Ubuntu18.04 远程命令行下安装并启动x11vnc](https://blog.csdn.net/jiakai82/article/details/103386097)
3. [x11vnc 安装及使用](https://blog.51cto.com/zhubinqiang/2043805)

ubuntu: 18.04.4 LTS (Bionic Beaver)

在使用 tightvncserver 加载 gnome 桌面后, 通过 noVNC 接入, 打开终端, 想启动`scrcpy`来着, 但是却提示如下错误

```
$ scrcpy
...
Xlib:  extension "RANDR" missing on display ":1".
...
```

将`tightvncserver`更换为`vnc4server`后解决.

后者的启动命令如下

```
vnc4server :1
```

------

其实我也试过`x11vnc`, 但是在启动时总提示下面的报错, 没找到解决方法, 放弃了.

```log
$ x11vnc -forever -shared -rfbauth ~/.vnc/passwd -display :1 -rfbport 5901
08/02/2021 10:25:45 passing arg to libvncserver: -rfbauth
08/02/2021 10:25:45 passing arg to libvncserver: /root/.vnc/passwd
08/02/2021 10:25:45 passing arg to libvncserver: -rfbport
08/02/2021 10:25:45 passing arg to libvncserver: 5901
08/02/2021 10:25:45 x11vnc version: 0.9.13 lastmod: 2011-08-10  pid: 16723
08/02/2021 10:25:45 XOpenDisplay(":1") failed.
08/02/2021 10:25:45 Trying again with XAUTHLOCALHOSTNAME=localhost ...

08/02/2021 10:25:45 ***************************************
08/02/2021 10:25:45 *** XOpenDisplay failed (:1)

*** x11vnc was unable to open the X DISPLAY: ":1", it cannot continue.
*** There may be "Xlib:" error messages above with details about the failure.

```
