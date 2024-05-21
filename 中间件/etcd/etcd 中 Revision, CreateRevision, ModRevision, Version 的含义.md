# etcd 中 Revision, CreateRevision, ModRevision, Version 的含义

参考文章

1. [Etcd 中 Revision, CreateRevision, ModRevision, Version 的含义](https://www.cnblogs.com/FengZeng666/p/16156407.html)
    - etcd 的 mvcc 机制
    - etcd 的 watch 命令及参数使用方法
2. [Kubernetes-resourceVersion机制分析](https://fankangbest.github.io/2018/01/16/Kubernetes-resourceVersion%E6%9C%BA%E5%88%B6%E5%88%86%E6%9E%90/)
    - k8s etcd 客户端如何处理 resourceVersion 信息

## 结论

etcd mvcc 中的 Version, Revision, ModRevision, CreateRevision 到底都是什么意思？如果服务 watch etcd 订阅消息, 该如何使用呢？

实验部分不想看的, 可以只看结论:

- Revision: 作用域为集群, 逻辑时间戳, 全局单调递增, 任何 key 的增删改都会使其自增
- CreateRevision: 作用域为 key, 等于创建这个 key 时集群的 Revision, 直到删除前都保持不变
- ModRevision: 作用域为 key, 等于修改这个 key 时集群的 Revision, 只要这个 key 更新都会自增
- Version: 作用域为 key, 这个key刚创建时Version为1, 之后每次更新都会自增, 即这个key从创建以来更新的总次数. 

关于 watch 哪个版本: 

watch 某一个 key 时, 想要从历史记录开始就用 CreateRevision, 最新一条(这一条直接返回) 开始就用 ModRevision . 
watch 某个前缀, 就必须使用 Revision. 如果要watch当前前缀后续的变化, 则应该从当前集群的 Revision+1 版本开始watch. 

##

如何查看

```log
$ etcdctl get '/registry/statefulsets/default/test-sts' --write-out="fields" | grep -v Value
"ClusterID" : 6138936026546267994
"MemberID" : 4601696108602649857
"Revision" : 298266
"RaftTerm" : 5
"Key" : "/registry/statefulsets/default/test-sts"
"CreateRevision" : 282406
"ModRevision" : 298164
"Version" : 3
"Lease" : 0
"More" : false
"Count" : 1
```
