# es查询-Fielddata is disabled on text fields by default

参考文章

1. [Elasticsearch 6.2.3版本 执行聚合报错 Fielddata is disabled on text fields by default](https://www.cnblogs.com/miracle-luna/p/10989802.html)
     - Elasticsearch 5.x版本以后, 对排序和聚合等操作, 用单独的数据结构(fielddata)缓存到内存里了, 默认是不开启的, 需要单独开启
2. [Elastic报错：Fielddata is disabled on text fields by default](http://www.30daydo.com/article/366)
3. [Elastic Fielddata is disabled on text fields by default](http://fidding.me/article/82)
    - 为解决这个问题提供了两个方案.
4. [ElasticSearch排序引起的all shards failed异常原因分析](https://blog.csdn.net/xaio7biancheng/article/details/82657175)

ES: 5.5.0

在对某索引(其实是全部索引)进行聚合查询时, 出现了错误.

![](https://gitee.com/generals-space/gitimg/raw/master/bc853fbeeb5117968b51c7d323a87a3f.png)

请求

```json
GET /索引名/_search
{
    "aggs": {
        "聚合名称(随便写)": {
            "terms": {
                "filed": "貌似也可以随便写, 不过正常的应该是该索引中的字段名",
                "size": 10
            }
        }
    }
}
```

响应

```json
{
  "error": {
    "root_cause": [
      {
        "type": "illegal_argument_exception",
        "reason": "Fielddata is disabled on text fields by default. Set fielddata=true on [field名称] in order to load fielddata in memory by uninverting the inverted index. Note that this can however use significant memory. Alternatively use a keyword field instead."
      }
    ],
    "type": "search_phase_execution_exception",
    "reason": "all shards failed",
    "phase": "query",
    "grouped": true,
    "failed_shards": [
      {
        "shard": 0,
        "index": "索引名",
        "node": "pUI1S7JwQpSp6-P0wHJRbQ",
        "reason": {
          "type": "illegal_argument_exception",
          "reason": "Fielddata is disabled on text fields by default. Set fielddata=true on [field名称] in order to load fielddata in memory by uninverting the inverted index. Note that this can however use significant memory. Alternatively use a keyword field instead."
        }
      }
    ],
    "caused_by": {
      "type": "illegal_argument_exception",
      "reason": "Fielddata is disabled on text fields by default. Set fielddata=true on [field名称] in order to load fielddata in memory by uninverting the inverted index. Note that this can however use significant memory. Alternatively use a keyword field instead.",
      "caused_by": {
        "type": "illegal_argument_exception",
        "reason": "Fielddata is disabled on text fields by default. Set fielddata=true on [field名称] in order to load fielddata in memory by uninverting the inverted index. Note that this can however use significant memory. Alternatively use a keyword field instead."
      }
    }
  },
  "status": 400
}
```

参考文章3为解决这个问题提供了两个方案, 一是在`field`后添加`.keyword`后缀(叫作关键字, 暂时不知道什么意思), 经实践, 有效.

![](https://gitee.com/generals-space/gitimg/raw/master/f6a569c08911fbd07610d7b492b75acf.png)

另一个方法是在请求前修改该字段的`_mapping`配置, 还未实验, 感觉应该可行.

不过目前这个问题出现的原因还不清楚, 之前ES集群工作正常, 这个问题是突然出现的, 还需要排查一下...

