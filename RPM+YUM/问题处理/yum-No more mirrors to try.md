# yum-No more mirrors to try

yum安装时意外中断, 再次运行时出现如下错误

```
yum [Errno 256] No more mirrors to try
```

解决办法

```
yum clean all
```
