# es接口使用及参数解释

参考文章

1. [elasticsearch基本接口使用](https://www.cnblogs.com/lichunke/p/9836288.html)
2. [Elasticsearch利用cat api快速查看集群状态、内存、磁盘使用情况](https://www.cnblogs.com/yangwenbo214/p/9832516.html)
3. [ES系列：查看磁盘使用情况API](https://blog.csdn.net/VIP099/article/details/106366421)

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

根据参考文章2, 其实默认的`_cat/nodes`的响应结果是不完整的, 我们可以通过`h`参数指定要显示的字段, 可选的字段有:

```console
$ curl 'localhost:9200/_cat/nodes?v&h=http,version,jdk,disk.total,disk.used,disk.avail,disk.used_percent,heap.current,heap.percent,heap.max,ram.current,ram.percent,ram.max,master'
http          version jdk       disk.total disk.used disk.avail disk.used_percent heap.current heap.percent heap.max ram.current ram.percent ram.max master
10.0.0.4:9200 6.3.1   1.8.0_181       29gb     3.3gb     25.6gb             11.72        254mb            7    3.3gb       6.2gb          92   6.8gb -
10.0.0.5:9200 6.3.1   1.8.0_181       29gb     3.3gb     25.6gb             11.71      195.5mb            5    3.3gb       6.2gb          91   6.8gb -
10.0.0.6:9200 6.3.1   1.8.0_181       29gb     3.4gb     25.6gb             11.74      293.6mb            8    3.3gb       6.2gb          92   6.8gb *
```

这是对于 7.x 的集群来说的, 5.x 的集群中, `/_cat/nodes`接口是没有 disk 信息的, 需要使用`/_cat/allocation`, 见参考文章3, 如下

```
curl 'localhost:9200/_cat/allocation'
```
