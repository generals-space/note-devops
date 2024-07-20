参考文章

1. [Redis进阶实践之十一 Redis的Cluster集群搭建](https://www.cnblogs.com/PatrickLiu/p/8458788.html)
2. [Redis集群——主从复制数据同步](https://zhuanlan.zhihu.com/p/102859170)
3. [【大厂面试】面试官看了赞不绝口的Redis笔记（三）分布式篇](https://blog.csdn.net/qq_42322103/article/details/104172970)
    - 开发中常见的问题: 集群完整性、集群完整性、带宽消耗、数据倾斜
    - 数据倾斜原因: 
        1. 节点和槽分配不均，如果使用redis-trib.rb工具构建集群，则出现这种情况的机会不多
        2. 不同槽对应键值数量差异比较大
        3. 包含bigkey: 例如大字符串，几百万的元素的hash,set等
        4. 内存相关配置不一致
        5. 请求倾斜: 热点key
