# es集群状态为red-no allocations are allowed due to cluster setting [cluster.routing.allocation.enable=none]

参考文章

1. [INDEX_CREATED 集群未分配，RED解决ES](https://zhuanlan.zhihu.com/p/360751267)


```
"allocate_explanation" : "cannot allocate because allocation is not permitted to any of the nodes",

"explanation" : "no allocations are allowed due to cluster setting [cluster.routing.allocation.enable=none]"
```

处理方法

```
PUT _cluster/settings
{
  "transient": {
    "cluster.routing.allocation.enable": "all"
  }
}
```
