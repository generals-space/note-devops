# 分页查询[from size order]

参考文章

1. [Elasticsearch分页查询总结](https://www.jianshu.com/p/4d1bec7bb1a4)
    - `from`+`size`
    - `scroll`游标
    - `search after`
2. [elasticsearch之排序查询](https://www.cnblogs.com/heshun/articles/10657327.html)
    - `order`


```
GET /article/_search
{
    "query": {
        "match": {
            "title": "blog"
        }
    },
    "sort": [
        {
            "age": {
                "order": "desc"
            }
        }
    ]
}
```
