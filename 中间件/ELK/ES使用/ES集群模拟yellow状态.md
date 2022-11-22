# ES集群模拟yellow状态

参考文章

1. [单节点 Elasticsearch 健康状态为 yellow 问题的解决](https://blog.csdn.net/ale2012/article/details/106992995)
2. [单节点Elasticsearch状态检查为yellow](https://www.cnblogs.com/fat-girl-spring/p/13692593.html)

使用场景中, 需要在 es 集群处于 yellow 状态时进行操作, 需要手动模拟该场景.

green, yellow, red 各表示什么意义这里不再细说, 大致就是 yellow 状态是 分片/副本 有缺失, 但是可以恢复, 或是正在恢复的; red 则是无法恢复的;

ES: 7.5.1 master * 3 + data * 1 (混部类型, master也可存储数据)

## 停止一个节点(失败)

想要模拟 yellow 状态最简单的方法就是重启一个节点(或者干脆直接停掉ta).

这样虽然可行, 但是由于是测试环境, 分片会立刻重新分配, 状态恢复的速度太快了...

## 创建索引 分片数>节点数(失败)

```json
// PUT article
{
    "settings": {
      "index": {
        "number_of_shards": "5",
        "number_of_replicas": "1"
      }
    }
}
```

这种情况主分片无法分配, 得到的是 red 状态...

## 创建索引 副本数 > 节点数(成功)

后来找到了参考文章1和2, ta们提到了一个思路.

主分片无法分配, 得到red, 那么副本无法分配, 不就能得到 yellow 了嘛.

由于同一分片的主分片与副本不能调度到同一台主机, 只要设置合适的副本数, 让主分片不得不与副本出现在同一节点即可.

```
// PUT article
{
    "settings": {
      "index": {
        "number_of_shards": "1",
        "number_of_replicas": "4"
      }
    }
}
```

这样, 必然就会出现某个副本与其主分片被调度到同一台主机.

成功
