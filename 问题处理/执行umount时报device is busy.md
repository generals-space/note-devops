# 执行umount时报device is busy

参考文章

1. [执行umount 的时候却提示:device is busy 的处理方法](https://www.cnblogs.com/xuey/p/7878529.html)

```
$ umount /mnt/cdrom/
umount: /mnt/cdrom: device is busy.
## 强制卸载也不行
$ umount -f /mnt/cdrom/ 
umount: /mnt/cdrom: device is busy.
```

可用`fuser`查看正在使用该挂载点的进程.

```
$ fuser -m /mnt/cdrom/
## 占用进程pid(没错, 后面有1个多余的字母)
/mnt/cdrom/: 1338c 5830c 
```

可以使用`kill -9 1338 5830`手动杀死进程, 也可以使用`fuser`的`-k`选项, 查询的同时杀死进程..

```
$ fuser -m -k /mnt/cdrom/
```

此时占用已解除.