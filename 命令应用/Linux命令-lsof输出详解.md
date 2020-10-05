# Linux命令-lsof

参考文章

1. [Linux 命令神器：lsof](https://www.jianshu.com/p/a3aa6b01b2e1)
    - lsof常用选项及实现的功能, 用以代替netstat, ps
2. [使用 lsof 查找打开的文件](https://www.ibm.com/developerworks/cn/aix/library/au-lsof.html)
    - 查找应用程序打开的文件
    - 查找打开某个文件的应用程序
    - 恢复删除的文件
    - 查找网络连接

`lsof`: list open files(列出打开的文件). 由于在linux里, "一切皆文件", 所以lsof几乎可以完成所有信息的查看.

```
# lsof | head
COMMAND  PID  TID USER   FD      TYPE DEVICE SIZE/OFF    NODE NAME
bash       1      root  cwd       DIR  0,260     4096  143809 /root
bash       1      root  rtd       DIR  0,260     4096  140971 /
bash       1      root  txt       REG    8,1   964544 1049001 /usr/bin/bash
bash       1      root  mem       REG    8,1    62184 1051010 /usr/lib64/libnss_files-2.17.so
bash       1      root    0u      CHR  136,0      0t0       3 /dev/pts/0
bash       1      root    1u      CHR  136,0      0t0       3 /dev/pts/0
```

`lsof`输出各字段表示的信息

- `COMMAND`: 进程的名称
- `PID`: 进程标识符(进程ID)
- `TID`: 线程标识符(线程ID), 只有多线程应用才有这个值.
- `User`: 所有者名称
- `FD`: 文件描述符
  - cwd: 应用程序的当前工作目录，这是该应用程序启动的目录，除非进程本身对这个目录进行更改
  - txt: 程序代码，如应用程序二进制文件本身或共享库
  - 整型数值[u|r|w], 如`1u`, `2r`: 数值表示进程打开的文件描述符. `u`表示该文件处于读写模式, `r`表示只读而`w`表示只写. (进程开始运行时都会有3个文件描述符: 标准输入, 标准输出和标准错误, 所以程序代码中打开的文件描述符都是从3开始的).
- `Type`: 关于文件格式的更多描述.
  - REG: 常规文件
  - DIR: 常规目录
  - CHR: 字符设备
  - BLK: 块设备
  - UNIX: UNIX域套接字(一般是`*.sock`文件)
  - FIFO: FIFO管道队列
  - IPv4(6): IPv4(6)套接字
- `Device`: 指定磁盘的名称
- `Size/Off`: 文件的大小(网络套接字和字符设备没有这个值, 可能会显示为`0t0`?)
- `Node`: 索引节点(文件在磁盘上的标识) (网络套接字没有这个值, 只是显示为`TCP`)
- `Name`: 打开文件的名称. 如果是网络套接字还会包含IP, 端口和状态信息等.

> 这些字段的详细解释可以见参考文章2.

lsof的各个选项都是作为过滤行为存在的.

lsof查看网络连接信息要比netstat慢很多, `netstat`打印结果为毫秒级, lsof则是秒级.
