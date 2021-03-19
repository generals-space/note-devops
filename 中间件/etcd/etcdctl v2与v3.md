# etcdctl v2与v3

参考文章

1. [etcdctl v2 v3 使用指南](https://blog.csdn.net/kozazyh/article/details/79586530)
2. [分布式健值存储etcd 3.1.7](https://segmentfault.com/a/1190000017408481)
    - "特性"中对v2和v3的区别值得一看.

我还是觉得v2的版本更容易理解些, 可以直接把**dir, key, value**分别对应文件系统的**目录, 文件和文件内容**. 就是有点麻烦, v2版本对文件和目录的CURD操作都有单独的指令(key的创建不需要dir事先存在, 但是dir的删除的操作需要先将下面的key和子级dir删除).

> ETCD V3不再使用目录结构, 只保留键. 例如: "/a/b/c/"是一个键, 而不是目录. V3中提供了前缀查询, 来获取符合前缀条件的所有键值, 这变向实现了V2中查询一个目录下所有子目录和节点的功能.  --参考文章2

| v3    | v2                                           |
| :---- | :------------------------------------------- |
| `get` | `get`, `ls`                                  |
| `put` | `mk/mkdir`, `set/setdir`, `update/updatedir` |
| `del` | `rm/rmdir`                                   |

可以说, 在v3版本中, 把文件与目录的操作完全统一起来.

这里有一个坑, 在v2中, 通过`mk`创建的key默认位于根目录`/`下. 如下

```console
$ etcdctl mk key1 val1
val1
$ etcdctl get key1
val1
$ etcdctl get /key1
val1
$ etcdctl ls -r
/key1
$ etcdctl ls / -r
/key1
```

但是在v3中创建同样的key, 则不会放在根目录. 如下

```console
$ etcdctl put key1 val1
OK
$ etcdctl get key1
key1
val1
$ etcdctl get / --prefix
## 无输出
```

可以说`key1`与根目录`/`同级, 要获取这样的key, 需要使用如下命令.

```console
$ etcdctl get '' --prefix
key1
val1
```

另外, v3与v2不兼容, 不仅表现在`etcdctl`各命令的使用方法不同, 而且通过v3与v2不同版本的命令写入的数据是隔离的, 通过v2命令无法查询到通过v3命令写入的数据.
