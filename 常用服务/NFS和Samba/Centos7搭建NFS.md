# Centos7搭建NFS

参考文章

1. [centos7下NFS使用与配置](https://www.cnblogs.com/jkko123/p/6361476.html)

NFS服务端需要安装两个包: `rpcbind`, `nfs-utils`.

NFS客户端需要安装一个包: `nfs-utils`.

服务端在启动服务前需要指定共享目录, 可接受客户端IP, 及权限控制等配置.

客户端使用`mount`挂载, 只有在安装`nfs-utils`后, `mount -t`才有nfs选项.

## 服务端配置

默认安装好`nfs-utils`后, 配置文件`/etc/exports`为空. 尝试写入如下配置

```
/mnt/nfsfold 192.168.1.*(rw,sync,no_all_squash)
```

格式可规定为: `共享路径 目标网段(权限配置) [目标网段2(权限配置)]`

1. 网段和权限设置之间没有空格.

2. 目标网段格式可以为`192.168.1.*`, 也可以为`192.168.1.0/24`, 两种格式.

3. 括号内权限选项以逗号分隔, 不要加空格.

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
