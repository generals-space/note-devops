# 清理yum缓存和释放内存方法

参考文章

1. [CentOS7清理yum缓存和释放内存方法](https://www.cnblogs.com/pejsidney/p/8873103.html)
    - `drop_caches`的使用简直一派胡言, 根本就不是用来清除"网页"缓存的

`yum clean`可以清理各种缓存(headers, packages, metadata等), 直接用`all`就可以了.

```
yum clean all
```

