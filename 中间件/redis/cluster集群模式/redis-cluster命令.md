# redis-cluster常用操作命令

参考文章

1. [redis cluster 学习 实战篇(二)](https://cloud.tencent.com/developer/article/1418503)

## meet 添加节点

cluster meet 

## failover 主从切换

只能在 slave 节点上运行.

## replicate 设置主从关系

## forget 解除主从关系, 移除节点

cluster forget nodeid 从集群中移除指定节点, master/slave 都可以.

如果 master 上有 slot, 会直接移除, ta的 slave 会变成孤立的 slave(但数据没有丢失...应该).

由于 redis-cli 是需要指定一个实例进入终端的, 因此不能 forget 自己, 如果自身是 slave, 也不能 forget 自己的 master.

注意, 需要在集群中**所有节点**上执行 forget, 否则其他节点甚至被 forget 的节点自身都还记着原集群信息, 还会加进去.

另外, 被移除的节点再通过 meet 加回来时, 会保留原本的角色和 slot 信息, 可以被恢复.
