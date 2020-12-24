# restful api索引操作

参考文章

1. [ElasticStack系列，第一章](https://blog.csdn.net/LeeDemoOne/article/details/103165610)
2. [ElasticSearch第6节 Kibana 的Dev Tool 增删改查ES](https://www.jianshu.com/p/21007d1011ad)
    - 从 ES 7.0.0 开始, 移除**文档类型(type)**这个概念, 在 restful api 中, type 这个位置将使用固定`_doc`代替.

ES: 7.2.0

## 创建索引

创建一个班级表`class`

```json
PUT /class
{
    "settings": { 
        "index": { 
            "number_of_shards": "2",
            "number_of_replicas": "0"
        }  
    }
}
```

- `class`:              索引名称
- `number_of_shards`:   分片数 
- `number_of_replicas`: 副本数

响应

```json
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "class"
}
```

## 删除索引

```json
DELETE /class
{
    "acknowledged": true
}
```

## 索引中插入数据(将要废弃)

在班级中添加学生`student`

```
## POST /class/student/1001
POST /class/student/1001
{ 
    "id":1001, 
    "name":"general", 
    "age":24, 
    "gender":"男"
}
```

- `/class/student/1001`: 这里的`id`为插入表项中的`_id`字段值. 可以为空, es 会自动为其创建一个随机值.

响应

```json
{
    "_index" : "class",     // 索引名称
    "_type" : "student",    // 文档类型
    "_id" : "1001",         // id(类似于主键???)
    "_version" : 1,         // 版本信息
    "result" : "created",   // 操作类型
    "_shards" : {           // 分片信息
        "total" : 1,
        "successful" : 1,
        "failed" : 0
    },
    "_seq_no" : 0,
    "_primary_term" : 1
}
```

但这是 7.0.0 之前的做法, 7.0.0 之后再使用上述方法创建将会得到如下提示(在 kibana 的`Dev Tools`窗口中)

```
#! Deprecation: [types removal] Specifying types in document index requests is deprecated, use the typeless endpoints instead (/{index}/_doc/{id}, /{index}/_doc, or /{index}/_create/{id}).
```

版本 7 兼容了版本 6, 但是已经被弃用了, 文档类型虽然还能用, 但在版本 8 就完全删除了

## 索引中插入数据(新)

```
POST /class/_doc/1002
{ 
    "id":1002, 
    "name":"jiangming", 
    "age":25, 
    "gender":"男"
}
```

```
{
  "_index" : "class",
  "_type" : "_doc",
  "_id" : "1002",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}

```

## 更新


## 删除

删除指定索引

```
curl -XDELETE 'es-cluster:9200/索引名'
```

删除所有索引

```
curl -XDELETE 'es-cluster:9200/*'
```
