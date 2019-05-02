# RSync所遇问题

## 1.

```
@ERROR: chroot failed
rsync error: error starting client-server protocol (code 5) at main.c(1522) [receiver=3.0.3]
```

情境描述: 客户端运行`rsync`命令向备份服务器请求备份时, 出现上述错误;

问题分析: 备份服务器上的(备份)接收目录不存在或无权限;

解决办法: 建立相应目录或赋予相应权限即可;

## 2.

```
rsync: failed to connect to 10.10.10.170: Connection refused (111)
rsync error: error in socket IO (code 10) at clientserver.c(124) [receiver=3.0.5]
```

情境描述: 运行rsync命令向备份服务器请求备份时, 出现上述错误;

问题分析: 服务未启动, (注意分清备份的服务器与客户端的区别);

解决办法: 启动服务端的rsyncd, (注意服务端是接受备份文件的服务器);

## 3.

```
general@172.16.171.132's password: 
sending incremental file list
rsync: connection unexpectedly closed (9 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(600) [sender=3.0.6]
```

情境描述: 使用rsync命令的ssh模式发起数据同步请求, 出现上述错误;

问题分析: 可能是`src/dst`的路径不正确, 重新确认一下;

## 4. 

```
rsync: chgrp "/DISK2_BACKUP/mnt/share4/vmshare/" failed: Operation not permitted (1)
```

可能是`chgrp`也可能是`chroot`, 总之一定和`rsync`的`-a`(归根结底还是`-p`选项)有关. 就是关于同步文件时顺便把文件的权限也同步过去.

如果本地目标下有一个root创建的文件file, 而双方同步使用的是普通用户A, 当文件同步到rsync服务器后, 拥有A用户权限的rsync是没有办法把该文件的属主改成root的, 所以会出错.

## 5.

```
params.c:Parameter() – Ignoring badly formed line in configuration file: ignore errors 
```

同步过程中, 日志文件输出上述警告.

解决方法是, 把出问题的`ignore errors`这一行注释掉即可。网上有很多人问，因为很多人的配置文件里都写了这个忽略错误，结果反而会产生一个错误提示。不过倒不影响同步。不管它也行。可以去掉配置文件中的`ignore errors`