# Linux命令行启动图形程序的问题

许多需要图形界面的桌面程序, 在服务器上只能安装桌面套件, 然后安装VNC, 在图形界面启动. 而也有很多时候我们需要在命令行控制它们的启动与关闭. 

直接通过ssh在命令行执行启动命令, 以virtual box为例, 可能得到如下错误

```
$ virtualbox 
Qt FATAL: QXcbConnection: Could not connect to display 
Aborted (core dumped)
```

这是无法联接到显示桌面的意思.

在VNC图形界面中打开终端, 查看有关display的环境变量, 如下图

![](https://gitee.com/generals-space/gitimg/raw/master/c3b8b294b79463eefdfdec459b620281.png)

得到`DISPLAY=:1`的变量, 而这个变量在ssh命令行中是不存在的. 我们需要手动设置这个变量.

```
$ export DISPLAY=:1 && virtualbox
```

这样就能在对应的VNC桌面上看到程序启动了.

## QXcbConnection: Could not connect to display 

这个问题发生在用普通用户身份下使用同样的方法启动genymotion时, 之前使用root是可以的, 如下

```
QXcbConnection: Could not connect to display 
Aborted (core dumped)
```

查看网上的解决方法, 怀疑过`~/.Xauthority`文件的问题, 把root的这个文件拷贝到这个普通用户下, 也改了权限但是不行. 也以为可能是`ssh -X`选项的问题, 但是加了这个重新登录依然无效.

后来发现, 是vnc启动桌面的问题. 之前vnc是以root用户启动的, 获得的display值也是root用户的桌面, 普通用户是没有图形桌面的, 所以才会报连接不上桌面的错误. 

解决方法是, 再为这个普通用户启动一个vnc桌面, 获取这个桌面的display值, 启动就没问题了.