# settings中analysis包含的analyzer tokenizer filter是什么意思 什么关系

参考文章

1. [Elasticsearch中什么是 tokenizer、analyzer、filter ?](https://cloud.tencent.com/developer/article/1706529)
    - analyzer(分析器) = tokenizer(分词器) + filter[](分词过滤器)
    - analyzer 是由一个 tokenizer 对象, 和一组 filter 列表对象组成的(可为空)
    - 自定义Analyzer
2. [ElasticSearch自定义pinyin和ik分词库](https://blog.51cto.com/u_14693305/5018536)

es: 7.5.1

analyzer 是指, 在信息写入ES时, 将信息文本进行分析处理, 得到一系列token列表(可以理解为"关键字")的过程.

这个过程分为2个阶段, 分别由一个 tokenizer , 和一组 filter 列表完成的(后者列表可为空).

## 1. 极简示例

我们可以创建一个自定义的 analyzer, 假设将其命名为"my_analyzer", 其结构如下

```
analyzer: {
    name: "my_analyzer",
    tokenizer: "Whitespace tokenizer",
    filter: [
        "Lowercase filter"
    ]
}
```

> 其中"Whitespace tokenizer", "Lowercase filter"都是内置的功能.

我们准备将如下文本写入ES索引中的某个字段, 并为其指定"my_analyzer"分析器.

```
Hello, my name's General.
```

这段文本经过了如下过程.

1. "Whitespace tokenizer"分词器: 将文本按照空格进行分隔, 得到最初的 token 列表: ["Hello", "my", "name's", "General"];
2. "Lowercase filter"过滤器: 将token元素全部转换为小写. token 列表变成: ["hello", "my", "name's", "general"];

Input => "Hello, my name's General"
Output => ["hello", "my", "name", "s", "general"]

## 实际操作

上面的 analyzer 分析器是我们自定义的, 从我目前已知的场景来看, 只能在索引范围内生效. 如需验证, 只能先创建一个自定义的索引.

```json
PUT my_test
{
    "settings" : {
        "analysis" : {
            "analyzer" : {
                "my_analyzer" : {
                    "tokenizer" : "whitespace",
                    "filter": [
                        "lowercase"
                        // "my_filter"
                    ]
                }
            },
            // 字定义 filter 实现
            // "filter" : {
            //     "my_filter" : {
            //         "type" : "pinyin"
            //     }
            // }
        }
    }
}
```

写入数据, 进行分析.

```json
GET my_test/_analyze
{
  "text": "Hello, my name's General",
  "analyzer": "my_analyzer"
}
```

结果正如我们预期: ["hello", "my", "name's", "general"], 我们可以使用这个列表中的任一元素作为关键字查询到这个信息所在的记录.

------

那么如何写入数据, 又如何查询呢?

```json
POST my_test/_doc
{
    "name":"general",
    "desc": "Hello, my name's General"
}
POST my_test/_doc
{
    "name":"Jiangming",
    "desc": "Hello, my name's Jiangming"
}
```

查询desc字段, 关键字为"general", 可以查出1条记录.

```json
GET my_test/_search
{
    "query": {
        "match": {
            "desc": "general"
        }
    }
}
```

如果关键字为"name's", 则可以查出2条记录.

------

ok, 看明白了这个过程, 再去看参考文章1和2, 一定会有更多收获.
