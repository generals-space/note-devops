# Linux服务脚本-Systemd(3)参数

参考文章

1. [systemd 的配置文件的编写(一[Unit]和[Install]、通用)](http://www.321211.net/?p=233)

2. [systemd](http://blog.csdn.net/a624731186/article/details/22690947)

装过`tigervnc`, 网上的大多数教程指明将它的启动脚本改名为`vncserver@:1.service`, 一直不太懂这个`$@:1`是什么鬼.

查看vnc服务脚本内容, 如下

```
...
[Service]
Type=forking
User=skypay

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=-/usr/bin/vncserver -kill %i
ExecStart=/usr/bin/vncserver %i
PIDFile=/home/skypay/.vnc/%H%i.pid
ExecStop=-/usr/bin/vncserver -kill %i
...
```

其中有两个变量`%H`与`%i`, 猜测是`systemd`脚本提供的参数机制, 参考文章1和参考文章2中都有提到详细的内置参数表. 如下

