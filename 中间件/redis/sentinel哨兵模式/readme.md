1. [redis-sentinel部署手册及Java代码实现](https://blog.csdn.net/yuyegongcheng/article/details/121371061)
    - jedis 版本有点旧, 如果 sentinel 本身也设置了密码, 那么连接会失败.
2. [【大厂面试】面试官看了赞不绝口的Redis笔记（三）分布式篇](https://blog.csdn.net/qq_42322103/article/details/104172970)
    - 读写分离可能遇到的问题: 数据复制延迟、读到过期数据、从节点故障, 并提供了解决思路
        - 数据复制延迟: 对master和slave的offset值进行监控, 当offset值相差过多时, 可以把读流量转换到master上, 但是这种方式有一定的成本
        - 读到过期数据
    - Sentinel只是配置中心不是代理

