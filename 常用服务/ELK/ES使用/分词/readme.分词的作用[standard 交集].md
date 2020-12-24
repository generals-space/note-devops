# 分词

参考文章

1. [Elasticsearch Reference [5.5] » Analysis](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/analysis.html)
    - 5.5
2. [Elasticsearch Reference [7.5] » Text analysis](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/analysis.html)
    - 7.5
3. [Listing available analyzers via API](https://discuss.elastic.co/t/listing-available-analyzers-via-api/16472)
    - 没办法通过 es http 接口获取集群中所有可用的分词器列表

创建索引及数据

```json
PUT ik_index
POST ik_index/user
{
    "name": "general",
    "age": 24,
    "info": "general comes from China"
}
```

> 在ES中, 可以把"索引(index)"看作是一个数据库, 其中存储的"文档(document)"则可以看作是数据表.

通常查询语句可以写作如下

```json
GET /ik_index/user/_search
{
  "query": {
    "match": {
      "info": "general"
    }
  }
}
```

查询的是`ik_index`库, `user`表中, `info`字段的内容.

上面的查询语句可以匹配到目标记录, 但是如果查询的是`gene`, 则无法匹配.

------

这是因为, ES的默认分词器(`standard`)将该记录的`info`内容分解为了[`general`, `comes`, `from`, `China`] 4个单词进行存储, 术语称为`token`.

之后在查询时, 同样会将我们要查询的内容进行分解, 得到[`general`].

两相对比, 发现在ES记录中存在`general`这个`token`, 于是匹配成功.

如果查询`gene`这个不完整的单词, 用于匹配的列表变成了[`gene`], 但在这条记录中并没有对应的`token`, 于是匹配失败.

所以在查询时, 目标值可以写多个, 如`"info": "general from"`, 只要其中一个匹配到, 就算成功(就跟求两个列表的**交集**一样).

这就是ES默认的存储及查询策略, **分词**就是将一句完整的内容切分为一个`token`列表的过程.

## `analyzer`与`search_analyzer`

按照上述流程, 会发现, **分词**的过程有两处, 一处是存储时, 一处是查询时.

其实最开始创建索引及文档的过程中, 默认有如下配置.

```json
PUT ik_index
{
  "mappings": {
    "user": {
      "properties": {
        "info": {
          "type": "text",
          "index": true,
          "analyzer": "standard",
          "search_analyzer": "standard"
        },
      }
    }
  }
}
```

`mappings`可以看作是建表时的表结构的描述, 如下

```sql
create table user(_id int primary key, age int, info text(500));
```

其中`analyzer`指定了存储时的分词器, `search_analyzer`则指定了查询时的分词器, 这两个的配置是可以不同的.

## 中文内容

上面测试的是`standard`分词器对于英文内容的分词及查询效果(按空格拆分), 如果内容是中文呢?

我们插入下面的内容

```json
PUT ik_index
POST ik_index/user
{
    "name": "小明",
    "age": 24,
    "info": "小明来自中国"
}
```

然后使用如下查询语句

```json
GET /ik_index/user/_search
{
  "query": {
    "match": {
      "info": "小明"
    }
  }
}
```

是可以查询到该记录的, 但是如果把查询语句中的`info`值换成"小华", 也是可以的.

原因在于, `standard`分词器对于中文分词采用的是"逐字拆分"的策略, ta将"小明来自中国"切分为[`小`, `明`, `来`, `自`, `中`, `国`]6个`token`.

在查询时, 同样将"小华"逐字拆分为[`小`, `华`], 然后两相求交集, 发现存在交集, 于是也能匹配成功.

> 可以通过`POST _analyze`接口, 使用指定的分词器, 对一段内容的进行拆分, 方便地得到拆分的`token`结果.

