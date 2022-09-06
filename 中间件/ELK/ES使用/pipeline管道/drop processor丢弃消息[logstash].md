# drop processor丢弃消息

参考文章

1. [Drop document in ingest pipeline](https://github.com/elastic/elasticsearch/issues/23726)
2. [Drop document in ingest pipeline](https://discuss.elastic.co/t/drop-document-in-ingest-pipeline/173394)
3. [Elasticsearch Ingest Pipeline 101: Usage & Setup Made Easy](https://hevodata.com/learn/elasticsearch-ingest-pipeline/)


5.x还没有drop处理器, 7.5已经有了.

目前有一个 5.x 的集群, 想要在管道中对logstash写入的消息进行过滤, 将不需要的消息丢弃.

尝试将`ctx._index`改为`null`, 但是logstash在写入时报错

```
[2022-08-23T17:58:07,681][ERROR][logstash.outputs.elasticsearch] Encountered a retryable error. Will Retry with exponential backoff  {:code=>500, :url=>"http://hjl-logstash-0823-03-master-0.hjl-logstash-0823-03-master.zjjpt-es.svc.cs-hua.hpc:9211/_bulk"}
```

尝试将`ctx._index`改成空值(`""`), 还是出错

```
[2022-08-23T17:55:59,608][INFO ][logstash.outputs.elasticsearch] retrying failed action with response code: 500 ({"type"=>"string_index_out_of_bounds_exception", "reason"=>"String index out of range: 0"})
[2022-08-23T17:55:59,608][INFO ][logstash.outputs.elasticsearch] Retrying individual bulk actions that failed or were rejected by the previous bulk request. {:count=>125}
```
