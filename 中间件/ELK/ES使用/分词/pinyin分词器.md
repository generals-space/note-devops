参考文章

1. [ElasticSearch自定义pinyin和ik分词库](https://blog.51cto.com/u_14693305/5018536)
2. [Elasticsearch中什么是 tokenizer、analyzer、filter ?](https://cloud.tencent.com/developer/article/1706529)
    - analyzer = tokenizer + filter[]
    - analyzer 是由一个 tokenizer 对象, 和一个 filter 列表对象组成的(可为空)

es 7.5.1

## 功能介绍

pinyin分词器, 简单来说就是可以使用"liudehua"(单字拼音), 甚至"ldh"(词组首字母)作为关键字, 查询出"刘德华"相关的记录.

安装好pinyin分词器后, 使用如下语句测试一下.

```json
POST _analyze
{
    "analyzer": "pinyin",
    "text": "我是一只小脑斧"
}
```

```
["wo", "shi", "yi", "zhi", "xiao", "nao", "fu", "wsyzxnf"]
```

这个示例不太合适...pinyin分词器应该是用来查询简短词组的场景, 这种如果目标是这样的短句, 准确率可能不高.

我们跟着官网的示例来操作一下.

## 创建索引级别的分词器配置

```json
PUT pinyin_index
{
    "settings" : {
        "analysis" : {
            "analyzer" : {
                "pinyin_analyzer" : {
                    "tokenizer" : "my_pinyin_tokenizer"
                }
            },
            "tokenizer" : {
                "my_pinyin_tokenizer" : {
                    "type" : "pinyin"
                }
            }
        }
    }
}
```

> 这里`settings`的"analyzer"和"tokenizer"的作用和功能, 建议先查阅同目录的另一文档, 这里不再解释.

使用上面自定义的"pinyin_analyzer"分析器进行分析测试.

```json
GET pinyin_index/_analyze
{
    "text": ["刘德华"],
    "analyzer": "pinyin_analyzer"
}
```

输出的结果中, 得到的token列表如下

```
["liu", "de", "hua", "ldh"]
```

这意味着, 当我们将包含"刘德华"的信息, 写入ES后, 可以使用这其中任一token元素查询到其相关的记录.

### 实际写入查询测试

```json
POST pinyin_index/_mapping 
{
    "properties": {
        "name": {
            "type": "keyword",
            "fields": {
                "pinyin": {
                    "type": "text",
                    "store": false,
                    "term_vector": "with_offsets",
                    "analyzer": "pinyin_analyzer",
                    "boost": 10
                }
            }
        }
    }
}
```

```json
POST pinyin_index/_doc
{"name":"刘德华"}
POST pinyin_index/_doc
{"name":"张学友"}
```

可以使用官网的查询语句

```
curl http://localhost:9200/medcl/_search?q=name:%E5%88%98%E5%BE%B7%E5%8D%8E
curl http://localhost:9200/medcl/_search?q=name.pinyin:%e5%88%98%e5%be%b7
curl http://localhost:9200/medcl/_search?q=name.pinyin:liu
curl http://localhost:9200/medcl/_search?q=name.pinyin:ldh
curl http://localhost:9200/medcl/_search?q=name.pinyin:de+hua
```


也可以使用如下语句

```json
GET pinyin_index/_search
{
    "query": {
        "match": {
            "name.pinyin": "ldh" // 使用["liudehua", "zhangxueyou", "ldh", "zxy"], 都能得到想要的结果.
        }
    }
}
```

------

上面配置pinyin分词器索引的`mapping`的方式与之前配置`ik`分词器时有差异.

```json
PUT ik_index
{
  "mappings": {
    "user": {
      "properties": {
        "info": {
          "type": "text",
          "index": true,
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_smart"
        }
      }
    }
  }
}
```

主要是因为这两个字段类型不一样, `pinyin_index.name`类型是`keyword`, 而`ik_index.info`类型是`text`.

不过为什么会有这样的不同, 目前还不清楚.

## token filter功能

接下来一段示例, 展示了pinyin分词器提供的filter工具的能力, 如果明白了下面3者的关系, 会很好理解.

```
analyzer = tokenizer + filter[]
```

首先创建索引结构

```
PUT pinyin_index2
{
    "settings" : {
        "analysis" : {
            "analyzer" : {
                "user_name_analyzer" : {
                    "tokenizer" : "whitespace",
                    "filter" : "pinyin_first_letter_and_full_pinyin_filter"
                }
            },
            "filter" : {
                "pinyin_first_letter_and_full_pinyin_filter" : {
                    "type" : "pinyin",
                    "keep_first_letter" : true,
                    "keep_full_pinyin" : false,
                    "keep_none_chinese" : true,
                    "keep_original" : false,
                    "limit_first_letter_length" : 16,
                    "lowercase" : true,
                    "trim_whitespace" : true,
                    "keep_none_chinese_in_first_letter" : true
                }
            }
        }
    }
}
```

然后测试

```
GET pinyin_index2/_analyze
{
  "text": ["刘德华 张学友 郭富城 黎明 四大天王"],
  "analyzer": "user_name_analyzer"
}
```

当我们输入"text"文本时, 选用了"user_name_analyzer"分词器.

这里`tokenizer`选用了一个内置的分词器"whitespace", 顾名思义, 就是将文本按照空格分隔. 于是得到token列表: ["刘德华", "张学友", "郭富城", "黎明", "四大天王"].

后面`filter`里选用了很多pinyin分词器提供的功能:

1. `keep_first_letter: true`: 保留每个词组中各单字的首字母, 得到token列表: ["ldh", "zxy", "gfc", "lm", "sdtw"]
2. `keep_full_pinyin" : false`: 如果此值为`true`的话, 会保留每个单字的全拼信息, token列表中还会增加: ["liu", "de", "hua", "zhang", "xue", "you", "guo", "fu", "cheng", "li", "ming"...](不过这里设置为了`false`, 这些都不会有).
3. ...

总之就是对最初的token列表["刘德华", "张学友", "郭富城", "黎明", "四大天王"]进行各种后续操作, 得到最终的列表的过程.

------

后面的示例均是测试各选项的作用, 这里就不说了.
