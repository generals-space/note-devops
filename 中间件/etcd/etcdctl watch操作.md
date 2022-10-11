# etcdctl watch操作

参考文章

1. [Etcd 中 Revision, CreateRevision, ModRevision, Version 的含义](https://www.cnblogs.com/FengZeng666/p/16156407.html)
    - etcd 的 mvcc 机制
    - etcd 的 watch 命令及参数使用方法
2. [Kubernetes-resourceVersion机制分析](https://fankangbest.github.io/2018/01/16/Kubernetes-resourceVersion%E6%9C%BA%E5%88%B6%E5%88%86%E6%9E%90/)
    - k8s etcd 客户端如何处理 resourceVersion 信息

```
etcdctl watch '/registry/statefulsets/default/test-sts'
```

watch 操作可以监听任意 key, 即使这个 key 不存在也不会报错.

默认不会在初始时获取全量数据, 只会获取增量数据, 这一点要与 client-go 的 reflector 实现区分开.

watch 选项

OPTIONS:
  -i, --interactive[=false]	Interactive mode
      --prefix[=false]		Watch on a prefix if prefix is set
      --prev-kv[=false]		get the previous key-value pair before the event happens
      --rev=0			Revision to start watching

...还没学会怎么用.

