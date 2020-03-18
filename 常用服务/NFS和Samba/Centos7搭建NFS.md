# Centos7搭建NFS

参考文章

1. [centos7下NFS使用与配置](https://www.cnblogs.com/jkko123/p/6361476.html)

## 安装依赖

- NFS服务端: `rpcbind`, `nfs-utils`(安装`nfs-utils`会自动安装`rpcbind`);
- NFS客户端: `nfs-utils`;

服务端在启动服务前需要指定共享目录, 可接受客户端IP, 及权限控制等配置.

客户端使用`mount`挂载, 只有在安装`nfs-utils`后, `mount -t`才有nfs选项.

## 服务端配置

默认安装好`nfs-utils`后, 配置文件`/etc/exports`为空. 尝试写入如下配置

```
/mnt/nfsfold 192.168.1.*(rw,sync,no_all_squash)
/mnt/nfsfold 192.168.1.0/24(rw,sync,no_all_squash)
```

格式可规定为: `共享路径 目标网段(权限配置) [目标网段2(权限配置)]`

1. 网段和权限设置之间没有空格.
2. 目标网段格式可以为`192.168.1.*`, 也可以为`192.168.1.0/24`, 两种格式**任选一种**.
3. 括号内权限选项以逗号分隔, 不要加空格.

> 貌似通配符格式容易出问题, 服务端出现过如下错误, 建议使用掩码形式

```
rpc.mountd[29722]: refused mount request from 192.168.7.51 for /mnt/nfsharbor/mysql (/mnt/nfsharbor/mysql): unmatched host
```

`rw`和`ro`, `sync`和`async`的区别很容易, `XXX_squash`应该是与客户端挂载后创建文件/目录的属主有关, 日后再研究.

启动服务

```
systemctl start rpcbind
systemctl start nfs
```

> 注意: 修改配置后最好同时重启`rpcbind`和`nfs`两个服务, 确定新配置生效, 不会出现奇怪的错误.

客户端挂载(需要安装`nfs-utils`), 本地目录需要事先存在.

```
mount -t nfs 服务端IP:共享路径 本地指定目录
```

## 关于权限

客户端在按照上面的步骤挂载好后, 在目录下创建文件会出现`Permission denied`.

```
$ touch abc
touch: 无法创建"abc": 权限不够
```

一般是目录由root用户创建, 且默认权限为755.

可以在服务端将共享目录设置为777, 或是允许`nfsnobody`用户对此目录的写权限(比如用`setfacl`).

此时客户端可成功写入, 且在此目录创建的新文件/目录的属主为`nfsnobody`(不管是在客户端还是服务端看都是`nfsnobody`).
