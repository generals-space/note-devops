# 直接执行sshd启动服务出错sshd re-exec requires execution with an absolute path

参考文章

1. [sshd re-exec requires execution with an absolute path](https://blog.csdn.net/zgmzyr/article/details/6846070)

环境是centos7的docker容器, 安装完openssh-server后, 由于使用`systemctl start sshd`会出现错误, 如下

```
$ systemctl start sshd
Failed to get D-Bus connection: Operation not permitted
```

尝试直接调用`sshd`命令启动, 但是执行时出现了上述问题

```
$ sshd
sshd re-exec requires execution with an absolute path
```

按照参考文章1所说, sshd执行时需要写全路径, 否则就会出现上述问题

```
/sbin/sshd
```
