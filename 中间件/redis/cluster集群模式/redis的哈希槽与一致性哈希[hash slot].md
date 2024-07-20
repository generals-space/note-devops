# redis的哈希槽与一致性哈希[hash slot]

参考文章

1. [一致性哈希和哈希槽](https://www.jianshu.com/p/6ad87a1f070e)
    - 一致性哈希, 数据倾斜
2. [进阶的Redis之哈希分片原理与集群实战](https://zackku.com/redis-cluster/)
    - 参考文章1的源文章
3. [一致性哈希和哈希槽对比](https://www.jianshu.com/p/4163916a2a8a)
4. [redis哈希槽和一致性哈希](http://www.lichenming.cn/topic/5dfb485176ffa1d157913cdf)

常规的一致性哈希算法有一个缺陷: 数据倾斜

redis的哈希槽对一致性哈希做了优化: 16384个槽是可以由用户分配的(每个 master 可以分配多少用管理人员指定和调整), 而且分配时 slot 是可以不用连续的, 这就可以解决数据倾斜的问题.

