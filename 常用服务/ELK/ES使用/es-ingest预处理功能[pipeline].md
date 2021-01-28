# es-ingest预处理功能[pipeline]

参考文章

1. [Elasticsearch Pipeline 详解](https://my.oschina.net/u/4072296/blog/3073345)
    - `ingest`预处理功能
    - es 5.x 内置了部分 logstash 功能, 即 ingest. 通过`node.ingest: true`选项开启(默认为`true`)
    - 在`es`中定义`pipeline`的方法
    - `Simulate Pipeline API`调试接口
    - ES 内置的`Process`类型及使用示例

> 可以这么说, 在`Elasticsearch`没有提供`IngestNode`这一概念时, 我们想对存储在`Elasticsearch`里的数据在存储之前进行加工处理的话, 我们只能依赖`Logstash`或自定义插件来完成这一功能. 但是`在Elasticsearch 5.x`版本中, 官方在内部集成了部分`Logstash`的功能, 这就是`Ingest`, 而具有`Ingest`能力的节点称之为`Ingest Node`.

