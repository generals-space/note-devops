# etcdctl key range从删库到跑路

参考文章

1. [ETCD:etcdctl](https://www.codenong.com/p11934614/)
2. [官方仓库readme etcd-io/etcd/etcdctl](https://github.com/etcd-io/etcd/tree/master/etcdctl)
3. [官方文档 etcd3 API](https://etcd.io/docs/v3.3.12/learning/api/)

etcdctl version: 3.2.24

某天需要手动删除`etcd`中关于 kuber 中某个 Pod 的键, 从我的常用命令库中拷贝出如下命令, 先执行了下, 因为经常用, 所以了解不会有风险.

```console
$ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key put /kube-scheduler-extender/kube-system/mysts/mysts-pod-0 "node-xxx"
$ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key get /kube-scheduler-extender/kube-system/mysts/mysts-pod-0 
"node-xxx"
```

然后将光标移到前面, 把`put`改成`del`后直接就执行了.

```console
$ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key del /kube-scheduler-extender/kube-system/mysts/mysts-pod-0 "node-xxx"
3389
```

打印结果是3389, 感觉有点疑惑, 但没太在意.

结果在 kuber 集群中尝试获取一下 Pod 资源, 发现`No resources found.`, 抚平了下心绪, 发现所有资源都被删除了, 整个集群都毁了, 顿时风中凌乱...

又查询了下etcd(etcd数据被清空, 但是核心进程都还在的, docker容器也还在的, 只是数据关系没有了.), 发现还有数据, 并不是完全被清空, 但基本也没什么用了.

查了查`/var/log/message`, 没什么可疑输出, 不会是底层的错误, 可能那3389条是真的了...

最开始怀疑是由于上面的`put`操作引起了类似 redis **缓存雪崩**的情况, 因为etcd容器的时区与宿主机节点相差8小时, 写入一个新于已有数据的键, 导致原有的键瞬间过期失效而被删除.

本来还打算去官方 issue 中吐个槽, 后来发现了`range_end`这个东西.

```
GET [options] <key> [range_end]
DEL [options] <key> [range_end]
```

我对etcd了解不深, 而且貌似网上的教程从来没有重点介绍过这些参数(`--from-key`, `key_range`), 最多讲个`--prefix`. 所以将`put`改为`del`并执行时并没有那么谨慎, 后面跟了一个串字符串也没怎么在意. 因为最开始我并不知道`range_end`这个概念的存在, 另外, etcd 作为一个键值存储库, 理论上各种操作都是单键的, 就和 redis 一样, 批量删除是需要做额外的选项甚至要使用脚本完成. 

结果悲剧了...
