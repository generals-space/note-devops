# yum安装man手册

参考文章

1. [No manual entry for man](https://unix.stackexchange.com/questions/182500/no-manual-entry-for-man)

有两个情况

一个是阿里云服务器上man手册只能查到bash命令, 不能查到C语言的函数文档. 这个情况直接安装`man-pages`包就能解决.

一个是在centos7的docker容器里, 执行man发现没有此命令. 手动安装`man`和`man-pages`后却出现`No manual entry for XXX`, 连bash命令的文档都不没有.

后来找到了参考文章1. 按照其中所说, 移除了`/etc/yum.conf`文件中`[main]`块下的`tsflags=nodocs`, 卸载`man-pages`并重装后问题解决.
