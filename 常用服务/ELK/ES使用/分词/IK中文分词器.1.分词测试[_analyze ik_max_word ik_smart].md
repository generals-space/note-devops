# IK中文分词器.1.分词测试

参考文章

1. [Elasticsearch之插件Ik分词器详细测试](https://blog.csdn.net/weixin_43871371/article/details/102973708)
    - `POST _analyze`接口进行分词测试

本目录的 readme 文章已经演示了默认`standard`分词器的**分词**过程, 对于英文内容就是按空闲

## 环境搭建

ES: 5.5.0

在了解内置分词器`standard`的工作流程的前提下, 对比`IK`中文分词器的处理流程. 

首先创建索引, 通过`mappings`指定某个字段使用哪种分词器.

```json
PUT ik_index
{
  "mappings": {
    "user": {
      "properties": {
        "info01": {
          "type": "text",
          "index": true,
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_smart"
        },
        "info02": {
          "type": "text",
          "index": true,
          "analyzer": "ik_smart",
          "search_analyzer": "ik_max_word"
        }
      }
    }
  }
}
```

`ik_index`可以视作关系型数据库的一个`database`, `user`则中其中一个表, 而`mappings`则可以看作是建表的语句, 类似如下.

```sql
create table department(id int primary key auto_increment, department char(50));
```

------

然后向其中插入数据.

```json
POST /ik_index/user
{
  "name": "小明",
  "age": 24,
  "info01":"小明喜欢喝进口红酒",
  "info02":"小明喜欢喝进口红酒"
}
```

在这段查询语句中, `进口`, `口红`, `红酒`是容易出现歧义的词语, 我们之后将通过对`info01`和`info02`的查询结果, 区分`ik_max_word`和`ik_smart`两种中文分词器的工作机制.

## `info01`字段的查询测试

```json
GET /ik_index/user/_search
{
  "query":{
    "match": {
      "info01": {
        "query":"口红"
      }
    }
  }
}
```

> ...貌似`query.match.info01.query`等同于`query.match.info01`, 其实没必要写内层的`query`结构?

由于`info01`的存储分词器使用的是`ik_max_word`, 这个分词器的作用是把内容中所有可以组成词语的部分全部拆分, 于是得到的`token`列表为:

[`小明`, `喜欢`, `喝进`, `喝`, `进口`, `口红`, `红酒`, `酒`]

> 可以通过`POST _analyze`接口, 使用指定的分词器, 对一段内容的进行拆分, 方便地得到拆分的`token`结果.

可以看到, 上述`token`列表中, 每一个都可以作为词语单独存在.

然后是查询语句, `ik_smart`这个分词器对"口红"这个内容没能体现出作用, 这里我们只要了解ta被拆分为[`口红`]就可以了.

于是再次求交集, 匹配成功, 可以查询到该记录.

## `info02`字段的查询测试

将查询语句中的`info01`修改成`info02`再次查询, 结果查不到了.

这是因为`info02`在存储时使用的是`ik_smart`分词器, ta的内容被拆分为

[`小明`, `喜欢`, `喝`, `进口`, `红酒`]

相比于`ik_max_word`分词器, ta把`喝进`, `口红`和`酒`这几个有歧义的词语移除了, 就像真正读懂了这段内容一样.

而在查询语句中, `ik_max_word`分词器对查询的内容"口红"同样没有多大作用, 还是被拆分为了[`口红`].

于是求交集的时候匹配失败, 没有查询到任何记录.

可以看到, `ik_smart`的作用是将内容进行比较智能的中文语法拆分, 多了一层语义的理解.
