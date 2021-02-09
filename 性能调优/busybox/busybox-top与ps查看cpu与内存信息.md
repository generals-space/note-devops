# busybox-top与ps查看cpu与内存信息

参考文章

1. [Busybox 里面怎么监控一个进程的 CPU 跟 MEM 得好用的命令](https://www.v2ex.com/t/517986)

busybox 中 ps 和 top 命令都比较弱, 而且由于所有命令都是与 sh 终端绑定的, 所以不能从 centos 中直接拷贝一个 ps 或 top 命令过去.

在 busybox 中要想查看 cpu 和 内存情况, 可能需要使用`top -n1 | grep 目标进程`了.
