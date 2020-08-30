# es接口使用及参数解释

参考文章

1. [elasticsearch基本接口使用](https://www.cnblogs.com/lichunke/p/9836288.html)

es版本: 7.2.0

## 参数解释 v,pretty,format,h

我试了试, 这几个参数基本对所有接口都通用.

以集群状态接口`/_cat/health`接口为例, 默认为单行结果

```console
$ curl -XGET 'es-cluster:9200/_cat/health'
1592808140 06:42:20 elasticsearch green 3 3 8 4 0 0 0 0 - 100.0%
```

`v`参数, 其实应该是`v=true`, 可打印出各字段标题.

```console
$ curl -XGET 'es-cluster:9200/_cat/health?v'
epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1592808473 06:47:53  elasticsearch green           3         3      8   4    0    0        0             0                  -                100.0%
$ curl -XGET 'es-cluster:9200/_cat/health?v=true'
epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1592808481 06:48:01  elasticsearch green           3         3      8   4    0    0        0             0                  -                100.0%
```

`pretty`参数, 其实应该是`pretty=true`, 输出美化. 单独使用与上面的没区别, 但是配合上`format=json`可以返回缩进式内容.

```console
## 单 pretty
$ curl -XGET 'es-cluster:9200/_cat/health?pretty=true'
1592808232 06:43:52 elasticsearch green 3 3 8 4 0 0 0 0 - 100.0%
## 单 format
$ curl -XGET 'es-cluster:9200/_cat/health?format=json'
[{"epoch":"1592808258","timestamp":"06:44:18","cluster":"elasticsearch","status":"green","node.total":"3","node.data":"3","shards":"8","pri":"4","relo":"0","init":"0","unassign":"0","pending_tasks":"0","max_task_wait_time":"-","active_shards_percent":"100.0%"}]
## 两者配合使用
$ curl -XGET 'es-cluster:9200/_cat/health?pretty=true&format=json'
[
  {
    "epoch" : "1592808276",
    "timestamp" : "06:44:36",
    "cluster" : "elasticsearch",
    "status" : "green",
    "node.total" : "3",
    "node.data" : "3",
    "shards" : "8",
    "pri" : "4",
    "relo" : "0",
    "init" : "0",
    "unassign" : "0",
    "pending_tasks" : "0",
    "max_task_wait_time" : "-",
    "active_shards_percent" : "100.0%"
  }
]
```

`h`参数, 可过滤返回字段, 多字段使用逗号`,`分隔.

```console
$ curl -XGET 'es-cluster:9200/_cat/health?format=json&pretty=true&h=cluster,node.total,shards'
[
  {
    "cluster" : "elasticsearch",
    "node.total" : "3",
    "shards" : "8"
  }
]
```

## 接口列表

### 1. `/_cat/health`

查看集群状态, 主要是 green,yellow,red 3种状态, 另外包含集群名称, 节点数量, 分片数量等信息.

### 2. `/_cat/nodes`

查看集群中各节点信息, 包含各节点的名称, ip地址, cpu内存总量, 3段式负载, 及是否为 master 等信息.

```json
[
  {
    "ip" : "10.254.1.45",
    "heap.percent" : "16",
    "ram.percent" : "97",
    "cpu" : "0",
    "load_1m" : "0.04",
    "load_5m" : "0.07",
    "load_15m" : "0.15",
    "node.role" : "mdi",
    "master" : "*",
    "name" : "es-cluster-1"
  },
  // ...省略
]
```
