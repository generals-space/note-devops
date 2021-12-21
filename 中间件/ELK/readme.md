参考文章

1. [Kibana 官方文档 Getting Started](https://www.elastic.co/guide/en/kibana/5.5/getting-started.html)
    - 官方提供的测试数据, 进行索引的各种操作, 以熟悉 es 与 kibana 的各种功能.
2. [Kibana 官方文档 Loading Sample Data](https://www.elastic.co/guide/en/kibana/5.5/tutorial-load-dataset.html)
    - 提供了3个数据集, 需要手动创建`mapping`, 再通过 es 的`bulk`接口加载
3. [你所不知道的ndJSON：序列化与管道流](https://cloud.tencent.com/developer/article/1506199)
    - 参考文章2中通过`bulk`加载测试数据集时, 请求头中的`Content-Type`为`application/x-ndjson`.
    - `ndjson`意为`newline delimited json`, 按行对json进行拆分(原生json是单一字符串, 没法搞多行的区分), 作为流式传输的格式.
    - 参考文章2中提供的数据集有几十兆, 如果用原生json进行上传, 对服务器是极大的压力.
4. [分布式之elk日志架构的演进](https://mp.weixin.qq.com/s?__biz=MzU0OTE4MzYzMw==&mid=2247485508&idx=1&sn=44bbea9dd059a0cb48f34790682fdddf)
    - 架构演进, 值得一看

es 其实可以看作一个数据库, logstash 与 kibana 是ta的两个客户端, 只不过 logstash 用于写, 而 kibana 用于读.
