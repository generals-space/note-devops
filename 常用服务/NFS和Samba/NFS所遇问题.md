# NFS所遇问题

## Permission denied

如果权限选项是`no_all_squash`和`root_squash`, 可能是因为在服务端`nfsnobody`用户没有指定目录的写入权限(一般是目录由root用户创建, 且默认权限为755).

可以考虑在服务端将共享目录权限设置为777, 或者允许`nfsnobody`用户可写(比如用`setfacl`).

此时客户端可成功写入, 且在此目录创建的新文件/目录的属主为`nfsnobody`(不管是在客户端还是服务端看都是`nfsnobody`).

## Read-only file system

应该是权限选项格式不正确, 网段和权限配置之间不能有空格, 同一个共享目录的不同网段权限配置的格式为`目标网段1(xxx) 目标网段2(xxx)`

## Stale NFS file handle

一般是因为有客户端挂载的情况下, 服务端突然被remove or unexport了, 就会出现此问题.

## access denied by server

```
mount.nfs: access denied by server while mounting 192.168.1.137:/mnt/pgnfs
```

...本机不能挂载自己共享的目录.
