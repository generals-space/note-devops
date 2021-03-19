# etcdctl获取指定目录内容

参考文章

1. [分布式健值存储etcd 3.1.7](https://segmentfault.com/a/1190000017408481)

> ETCD V3不再使用目录结构, 只保留键. 例如: "/a/b/c/"是一个键, 而不是目录. V3中提供了前缀查询, 来获取符合前缀条件的所有键值, 这变向实现了V2中查询一个目录下所有子目录和节点的功能.  --参考文章1

其实可以说, etcd v3中已经没有目录和文件的区别的, 所有key都放在根目录下(...其实连根目录也没了), 只不过很多应用都喜欢使用`/`作为路径分隔.

`--prefix`也只能作为一种类似通配符的过滤方式, 与v2中的`ls`命令有本质区别.

```bash
dir=""
dir=/registry
dir=/registry/services
etcdctl get --prefix --keys-only $dir | sed -n "s#$dir\/\([^\/]*\).*#\1#p" | uniq
```

```console
$ dir=/registry/services
$ etcdctl get --prefix --keys-only $dir | sed -n "s#$dir\/\([^\/]*\).*#\1#p" | uniq
endpoints
specs
```
