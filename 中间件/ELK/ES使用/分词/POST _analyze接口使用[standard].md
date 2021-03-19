# _analyze接口使用

参考文章

1. [Elasticsearch之插件Ik分词器详细测试](https://blog.csdn.net/weixin_43871371/article/details/102973708)

ES: 5.5.0

可以通过`POST _analyze`接口, 使用指定的分词器, 对一段内容的进行拆分, 方便地得到拆分的`token`结果.

## standard

`standard`是 es 内置的分词器, 对于英文, ta基本会按空格将语句进行分隔, 而对于中文, 则会逐字拆分.

### 英文

```json
POST _analyze
{
    "analyzer": "standard",
    "text": "general isn't a name"
}
```

结果如下

```
{
    "tokens": [
        {
            "token": "general",
            "start_offset": 0,
            "end_offset": 7,
            "type": "<ALPHANUM>",
            "position": 0
        },
        {
            "token": "isn't",
            "start_offset": 8,
            "end_offset": 13,
            "type": "<ALPHANUM>",
            "position": 1
        },
        {
            "token": "a",
            "start_offset": 14,
            "end_offset": 15,
            "type": "<ALPHANUM>",
            "position": 2
        },
        {
            "token": "name",
            "start_offset": 16,
            "end_offset": 20,
            "type": "<ALPHANUM>",
            "position": 3
        }
    ]
}
```

### 中文

```json
POST _analyze
{
    "analyzer": "standard",
    "text": "中华人民共和国"
}
```

```json
{
    "tokens": [
        {
            "token": "中",
            "start_offset": 0,
            "end_offset": 1,
            "type": "<IDEOGRAPHIC>",
            "position": 0
        },
        {
            "token": "华",
            "start_offset": 1,
            "end_offset": 2,
            "type": "<IDEOGRAPHIC>",
            "position": 0
        },
        {
            "token": "人",
            "start_offset": 2,
            "end_offset": 3,
            "type": "<IDEOGRAPHIC>",
            "position": 2
        },
        {
            "token": "民",
            "start_offset": 3,
            "end_offset": 4,
            "type": "<IDEOGRAPHIC>",
            "position": 3
        },
        {
            "token": "共",
            "start_offset": 4,
            "end_offset": 5,
            "type": "<IDEOGRAPHIC>",
            "position": 4
        },
        {
            "token": "和",
            "start_offset": 5,
            "end_offset": 6,
            "type": "<IDEOGRAPHIC>",
            "position": 5
        },
        {
            "token": "国",
            "start_offset": 6,
            "end_offset": 7,
            "type": "<IDEOGRAPHIC>",
            "position": 6
        }
    ]
}
```
