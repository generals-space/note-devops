# es接口使用及参数解释

参考文章

1. [elasticsearch基本接口使用](https://www.cnblogs.com/lichunke/p/9836288.html)
2. [Elasticsearch利用cat api快速查看集群状态、内存、磁盘使用情况](https://www.cnblogs.com/yangwenbo214/p/9832516.html)
3. [ES系列：查看磁盘使用情况API](https://blog.csdn.net/VIP099/article/details/106366421)

es版本: 7.2.0

```console
$ curl -XGET 'es-cluster:9200/_cat/health'
1592808140 06:42:20 elasticsearch green 3 3 8 4 0 0 0 0 - 100.0%
```
