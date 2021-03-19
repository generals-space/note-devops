# etcd vs redis.1.数据的存储模式

本文示例中使用的是`ETCDCTL_API=2`.

1. redis中可存储众多数据类型, 如string, list, set, map等, 而etcd中只能存储简单的string;
2. redis中所有的key都存放在同一层级, 而etcd可以将key按照目录结构存储;

在etcd中存在着目录与键值两种概念, etcdctl命令中也存在get/set/rm这种对key的操作和mkdir/setdir/rmdir/ls这种对目录的操作, 一直傻傻分不清楚.

究竟是什么意思呢?

以`/`为根目录, 使用`mkdir`创建一个目录`/dir1`, 然后使用`set`创建一个kv对`/dir1/key1`-> `val1`, 那么使用`ls`查看目录结构时, 就会发现`key1`这个键位于`/dir1`这个目录下.

```console
## 初始根目录为空, ls -r表示递归显示目录中的内容
$ etcdctl ls -r 
## 创建dir1目录
$ etcdctl mkdir /dir1
$ etcdctl ls -r
/dir1
## 创建key1键
$ etcdctl set /dir1/key1 val1
val1
## 查看dir1下的内容
$ etcdctl ls /dir1
/dir1/key1
$ etcdctl ls -r
/dir1
/dir1/key1
```

可以说

- key则可以理解为文件系统中的"文件", value则是文件内容;
- 目录其实是key-value的集合, 不可以直接存储value;

需要注意的是, 不管是dir还是key, 在etcd中的存储都是有序的. 继续上面的实验

```console
$ etcdctl mkdir /dir0
$ etcdctl mkdir /dir1/key0 val0
$ etcdctl ls -r
/dir1
/dir1/key1
/dir1/key0
/dir0
```

可以看到, 如果按照字母排序, `dir0`应该在`dir1`的前面, `key0`也应该在`key1`的前面, 实际上并不是这样.
